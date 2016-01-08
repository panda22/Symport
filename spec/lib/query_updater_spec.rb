describe QueryUpdater do
  subject { described_class }

  let (:user) { User.create(email: "2@2.com", password: "Complex1") }
  let (:project) { Project.create(name: "new proj") }
  let (:query_info) { {:name => SecureRandom.urlsafe_base64, :isShared => false, :conjunction => "and"} }
  let (:saved_query) { Query.create(name: "abc", conjunction: "and", is_shared: true) }
  let (:saved_query_info) { {:id => saved_query.id, :name => "xyz", :isShared => false, :conjunction => "or"} }

  before do
    user
    project
    saved_query
  end

  describe "update" do
    it "creates a new query if query_info has no id" do
      Permissions.expects(:user_can_update_query?).returns(true)
      subject.update(query_info, project, user)
      Query.where(:name => query_info[:name]).length.should == 1
    end

    it "raises an error if user does not have permission to update query" do
      Permissions.expects(:user_can_update_query?).returns(false)
      expect {
        subject.update(saved_query_info, project, user)
      }.to raise_error PayloadException
    end

    it "saves an existing query with new info" do
      Permissions.expects(:user_can_update_query?).returns(true)
      saved_query.conjunction.should == "and"
      subject.update(saved_query_info, project, user)
      updated_query = Query.find(saved_query.id)
      updated_query.conjunction.should == "or"
    end
  end

  describe "update_permissions" do
    it "updates the permissions for a query" do
      Permissions.expects(:user_can_update_query_permissions?).returns(true)
      saved_query.is_shared.should == true
      subject.update_permissions(saved_query_info, user)
      updated_query = Query.find(saved_query.id)
      updated_query.is_shared.should == false
    end

    it "raises an error if user does not have permission" do
      Permissions.expects(:user_can_update_query_permissions?).returns(false)
      expect {
        subject.update_permissions(saved_query_info, user)
      }.to raise_error PayloadException
    end
  end

  describe "update_name" do
    it "updates the permissions for a query" do
      Permissions.expects(:user_can_delete_query?).returns(true)
      saved_query.name.should == "abc"
      subject.update_name(saved_query_info, user)
      updated_query = Query.find(saved_query.id)
      updated_query.name.should == "xyz"
    end

    it "raises an error if user does not have permission" do
      Permissions.expects(:user_can_delete_query?).returns(false)
      expect {
        subject.update_name(saved_query_info, user)
      }.to raise_error PayloadException
    end
  end

  describe "create_param" do
    let (:project) { Project.create(name: "project abc") }
    let (:form) { FormStructure.create(name: "form abc", project: project) }
    let (:question) { FormQuestion.create(variable_name: "question_abc",
                                          form_structure: form,
                                          question_type: "timeofday",
                                          sequence_number: 20,
                                          prompt: "hi",
                                          display_number: "21") }
    let (:exception) {QuestionException.create(value: "qqq", form_question: question, exception_type: "timeofday")}
    let (:param_info) { {:operator => "=",
                         :value => "yay",
                         :sequenceNum => 1,
                         :is_last => true,
                         :isManyToOneInstance => false,
                         :isManyToOneCount => false,
                         :formName => form.name,
                         :questionName => question.variable_name} }

    before do
      project
      form
      question
      exception
    end

    it "creates a query param with correct info" do
      saved_param = subject.create_param(param_info, project.id, true)
      saved_param.form_structure_id.should == form.id
      saved_param.form_question_id.should == question.id
      saved_param.value.should == param_info[:value]
      saved_param.operator.should == param_info[:operator]
      saved_param.sequence_number.should == param_info[:sequenceNum]
      saved_param.is_last.should == param_info[:isLast]
      saved_param.is_regular_exception.should == false
      saved_param.is_many_to_one_instance.should == param_info[:isManyToOneInstance]
      saved_param.is_many_to_one_count.should == param_info[:isManyToOneCount]
    end

    it "sets is_exception flag to true if question and param value are exceptions" do
      param_info[:value] = "qqq"
      saved_param = subject.create_param(param_info, project.id, true)
      saved_param.is_regular_exception.should == true
    end
  end

end