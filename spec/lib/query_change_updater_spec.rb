describe QueryChangeUpdater do
  subject { described_class }

  let(:form) { FormStructure.create!(name: "abcde") }
  let(:question) { FormQuestion.create!(form_structure: form, variable_name: "ques_name", question_type: "email", sequence_number: 1, display_number: "1", prompt: "hi") }
  let(:query) { Query.create!(name: "xyz", is_changed: false) }
  let (:param) { QueryParam.create!(form_structure: form, form_question: question, query: query) }
  let (:param_id) { param.id }

  describe "update_from_form_structure" do
    before do
      form
      query
      param
    end

    it "sets the is changed flag to true queries that are in the form" do
      subject.update_from_form_structure(form, false)
      changed_query = Query.find(query.id)
      changed_query.is_changed.should == true
      QueryParam.where(id: param_id).length.should == 1
    end

    it "also deletes the param if delete flag is set to true" do
      subject.update_from_form_structure(form, true)
      changed_query = Query.find(query.id)
      changed_query.is_changed.should == true
      QueryParam.where(id: param_id).length.should == 0
    end
  end

  describe "update_from_form_question" do
    before do
      question
      query
      param
    end

    it "sets the is changed flag to true queries that are in the form" do
      subject.update_from_form_question(question, false)
      changed_query = Query.find(query.id)
      changed_query.is_changed.should == true
      QueryParam.where(id: param_id).length.should == 1
    end

    it "also deletes the param if delete flag is set to true" do
      subject.update_from_form_question(question, true)
      changed_query = Query.find(query.id)
      changed_query.is_changed.should == true
      QueryParam.where(id: param_id).length.should == 0
    end
  end

  describe "update_from_secondary_id_change" do

    let (:param1) { QueryParam.create!(form_structure: form, form_question: question, query: query, is_many_to_one_instance: true) }
    let (:param_id1) { param1.id }
    let (:param2) { QueryParam.create!(form_structure: form, form_question: question, query: query, is_many_to_one_count: true) }
    let (:param_id2) { param2.id }
    let (:param3) { QueryParam.create!(form_structure: form, form_question: question, query: query) }
    let (:param_id3) { param3.id }

    before do
      form
      query
      param1
      param2
      param3
    end

    it "deletes any parameters dependent on a form's secondary id" do
      subject.update_from_secondary_id_change(form)
      changed_query = Query.find(query.id)
      changed_query.is_changed.should == true
      QueryParam.where(id: param_id1).length.should == 0
      QueryParam.where(id: param_id2).length.should == 0
      QueryParam.where(id: param_id3).length.should == 1
    end
  end





end