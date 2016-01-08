describe QuerySerializer do
  subject { described_class }

  let (:user) { User.new(id: SecureRandom.uuid, first_name: "Bob", last_name: "Slob") }
  let (:other_user) { User.new(id: SecureRandom.uuid, first_name: "Rob", last_name: "Glob") }



  describe "serialize" do
    before do
      QuerySerializer.stubs(:serialize_params).returns([])
      QuerySerializer.stubs(:serialize_query_forms).returns([])
    end

    it "serializes id" do
      query = Query.new(id: SecureRandom.uuid, owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:id].should == query.id
    end
    it "serializes project id" do
      query = Query.new(project_id: SecureRandom.uuid, owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:projectID].should == query.project_id
    end
    it "serializes ownerName if user is owner" do
      query = Query.new(owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:ownerName].should == "Me"
    end
    it "serializes editorName if user is owner" do
      query = Query.new(owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:editorName].should == "Me"
    end
    it "serializes ownerName if user is not owner" do
      query = Query.new(owner: other_user, editor: user)
      result = subject.serialize(query, user)
      result[:ownerName].should == "Rob Glob"
    end
    it "serializes editorName if user is not owner" do
      query = Query.new(owner: user, editor: other_user)
      result = subject.serialize(query, user)
      result[:editorName].should == "Rob Glob"
    end
    it "serializes created" do
      query = Query.new(created_at: DateTime.new(2001,2,3), owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:created].should == DateTime.new(2001,2,3)
    end
    it "serializes edited" do
      query = Query.new(updated_at: DateTime.new(2001,2,3), owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:edited].should == DateTime.new(2001,2,3)
    end
    it "serializes isShared" do
      query = Query.new(is_shared: true, owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:isShared].should == true
    end
    it "serializes conjunction" do
      query = Query.new(conjunction: "and", owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:conjunction].should == "and"
    end
    it "serializes canEditPermissions" do
      query = Query.new(owner: user, editor: user)
      Permissions.expects(:user_can_update_query_permissions?).with(user, query).returns(true)
      result = subject.serialize(query, user)
      result[:canEditPermissions].should == true
    end
    it "serializes canDelete" do
      query = Query.new(owner: user, editor: user)
      Permissions.expects(:user_can_delete_query?).with(user, query).returns(true)
      result = subject.serialize(query, user)
      result[:canDelete].should == true
    end
    it "serializes changeMessage" do
      query = Query.new(change_message: "stuff got changed", owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:changeMessage].should == "stuff got changed"
    end
    it "serializes isChanged" do
      query = Query.new(is_changed: true, owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:isChanged].should == true
    end
    it "serializes queriedForms" do
      query = Query.new(owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:queriedForms].should == []
    end
    it "serializes queryParams" do
      query = Query.new(owner: user, editor: user)
      result = subject.serialize(query, user)
      result[:queryParams].should == []
    end

  end

  describe "serialize_param" do
    let (:form) {FormStructure.new(id: SecureRandom.uuid, secondary_id: "visit_number", name: "abcde")}
    let (:question) {FormQuestion.new(id: SecureRandom.uuid, question_type: "email", variable_name: "var_name")}

    it "sets type and name for many to one count" do
      param = QueryParam.new(is_many_to_one_count: true, form_structure: form, form_question: question)
      result = subject.serialize_param(param)
      result[:questionName].should == "number of visit_number"
      result[:questionType].should == "numericalrange"
      result[:isManyToOneCount].should == true
    end

    it "sets type and name for many to one instance" do
      param = QueryParam.new(is_many_to_one_instance: true, form_structure: form, form_question: question)
      result = subject.serialize_param(param)
      result[:questionName].should == "visit_number"
      result[:questionType].should == "text"
      result[:isManyToOneInstance].should == true
    end

    it "sets type and name param not dependent on secondary id" do
      param = QueryParam.new(form_structure: form, form_question: question)
      result = subject.serialize_param(param)
      result[:questionName].should == "var_name"
      result[:questionType].should == "email"
    end

    it "serializes id" do
      param = QueryParam.new(form_structure: form, form_question: question, id: SecureRandom.uuid)
      result = subject.serialize_param(param)
      result[:id].should == param.id
    end

    it "serializes operator" do
      param = QueryParam.new(form_structure: form, form_question: question, operator: "=")
      result = subject.serialize_param(param)
      result[:operator].should == "="
    end

    it "serializes value" do
      param = QueryParam.new(form_structure: form, form_question: question, value: "abc")
      result = subject.serialize_param(param)
      result[:value].should == "abc"
    end

    it "serializes formName" do
      param = QueryParam.new(form_structure: form, form_question: question)
      result = subject.serialize_param(param)
      result[:formName].should == "abcde"
    end

    it "serializes sequenceNum" do
      param = QueryParam.new(form_structure: form, form_question: question, sequence_number: 20)
      result = subject.serialize_param(param)
      result[:sequenceNum].should == 20
    end

    it "serializes isLast" do
      param = QueryParam.new(form_structure: form, form_question: question, is_last: true)
      result = subject.serialize_param(param)
      result[:isLast].should == true
    end

    it "serializes exceptions" do
      param = QueryParam.new(form_structure: form, form_question: question, is_regular_exception: true)
      result = subject.serialize_param(param)
      result[:isException].should == true
    end
  end

  describe "serialize_query_forms" do
    let (:project) { Project.create!(name: "proj") }
    let (:form) { FormStructure.create!(name: "abcde", project: project) }
    let (:other_form) { FormStructure.create!(name: "12345", project: project) }
    let (:query_form) { QueryFormStructure.create!(form_structure: form) }

    before do
      project
      form
      other_form
      @query_forms = QueryFormStructure.where(id: query_form.id)
    end

    it "serializes query forms" do
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(user, form).returns true
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(user, other_form).returns true
      result = subject.serialize_query_forms(project.id, @query_forms, user)
      result.should =~ [
          {:formID=>other_form.id, :formName=>"12345", :included=>false, :displayed=>true},
          {:formID=>form.id, :formName=>"abcde", :included=>true, :displayed=>true}
      ]
    end

    it "sets displayed to false if user cannot view form responses for form structure" do
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(user, form).returns false
      Permissions.expects(:user_can_view_form_responses_for_form_structure?).with(user, other_form).returns false
      result = subject.serialize_query_forms(project.id, @query_forms, user)
      result.should =~ [
          {:formID=>other_form.id, :formName=>"12345", :included=>false, :displayed=>false},
          {:formID=>form.id, :formName=>"abcde", :included=>true, :displayed=>false}
      ]
    end
  end


end