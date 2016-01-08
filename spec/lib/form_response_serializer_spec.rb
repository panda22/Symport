describe FormResponseSerializer do
  subject { described_class }
  let(:user) { User.new }
  describe 'serialize' do
    before do
      FormStructureSerializer.stubs(:serialize)
      FormAnswerSerializer.stubs(:serialize)
      @project = Project.create name: "proj"
      @form_structure = FormStructure.create name: 'whatever', project: @project
      Permissions.stubs(:user_can_view_personally_identifiable_answers_for_project?).with(user, @project).returns(true)
    end

    it 'serializes all the form answers objects' do
      question1 = FormQuestion.create! variable_name: 'var1', prompt: 'whatever', display_number: "1", sequence_number: 1, question_type: 'email', form_structure: @form_structure
      question2 = FormQuestion.create! variable_name: 'var2', prompt: 'whatever', display_number: "2", sequence_number: 2, question_type: 'zipcode', form_structure: @form_structure
      question3 = FormQuestion.create! variable_name: 'var3', prompt: 'whatever', display_number: "3", sequence_number: 3, question_type: 'date', form_structure: @form_structure
      resp = FormResponse.create form_structure: @form_structure, subject_id: '123'
      answer1 = FormAnswer.create(form_response: resp, form_question: question1)
      answer2 = FormAnswer.create(form_response: resp, form_question: question2)
      answer3 = FormAnswer.create(form_response: resp, form_question: question3)
      FormAnswerSerializer.expects(:serialize).returns({answer: 'serialized 1'})
      FormAnswerSerializer.expects(:serialize).returns({answer: 'serialized 2'})
      FormAnswerSerializer.expects(:serialize).returns({answer: 'serialized 3'})
      serialized_response = subject.serialize(user, resp)
      serialized_response[:answers].should =~ [{answer: 'serialized 1'}, {answer: 'serialized 2'}, {answer: 'serialized 3'}]
    end

    it 'serializes form structure' do
      structure = FormStructure.create name: 'Fancy Form', project: @project
      resp = FormResponse.create form_structure: structure, subject_id: 'abc'
      FormStructureSerializer.expects(:serialize).with(user, structure, false).returns("serialized version of structure")

      serialized_response = subject.serialize(user, resp)
      serialized_response[:formStructure].should == "serialized version of structure"
    end

    it 'serializes form responses id' do
      response_id = SecureRandom.uuid
      resp = FormResponse.create id: response_id, form_structure: @form_structure, subject_id: 'abc'
      serialized_response = subject.serialize(user, resp)
      serialized_response[:id].should == response_id
    end

    it "serializes form responses subject id" do
      response_id = SecureRandom.uuid
      resp = FormResponse.create id: response_id, form_structure: @form_structure, subject_id: "aaa"
      serialized_response = subject.serialize(user, resp)
      serialized_response[:subjectID].should == "aaa"
    end

    describe "new subject" do

      it "sets newSubject to true when that subject is not yet used in this project" do
        SubjectLookup.expects(:known_subjects_of_project).with(@project).returns(["a","b","c"])
        response_id = SecureRandom.uuid
        resp = FormResponse.create id: response_id, form_structure: @form_structure, subject_id: "aaa"
        serialized_response = subject.serialize(user, resp)
        serialized_response[:newSubject].should be_true
      end

      it "sets newSubject to false when that subject has been used in this project" do
        SubjectLookup.expects(:known_subjects_of_project).with(@project).returns(["a","b","c"])
        response_id = SecureRandom.uuid
        resp = FormResponse.create id: response_id, form_structure: @form_structure, subject_id: "c"
        serialized_response = subject.serialize(user, resp)
        serialized_response[:newSubject].should be_false
      end

    end

    it 'includes questions that were not originally part of the response' do
      resp = FormResponse.create form_structure: @form_structure, subject_id: 'abc'
      question1 = FormQuestion.create! variable_name: 'var1', prompt: 'whatever', display_number: "100", sequence_number: 100, question_type: 'email', form_structure: @form_structure
      question2 = FormQuestion.create! variable_name: 'var2', prompt: 'whatever', display_number: "200", sequence_number: 200, question_type: 'zipcode', form_structure: @form_structure
      question3 = FormQuestion.create! variable_name: 'var3', prompt: 'whatever', display_number: "300", sequence_number: 300, question_type: 'email', form_structure: @form_structure

      answer1 = FormAnswer.create(form_response: resp, form_question: question1, answer: 'first answer')
      answer2 = FormAnswer.create(form_response: resp, form_question: question2, answer: 'second answer')
      FormAnswerSerializer.expects(:serialize).returns({answer: "the third answer!"})
      FormAnswerSerializer.expects(:serialize).returns({answer:  "the second answer!"})
      FormAnswerSerializer.expects(:serialize).returns({answer: "the first answer!"})

      serialized_response = subject.serialize(user, resp)
      serialized_response[:answers].should =~ [{answer: 'the first answer!'}, {answer: 'the second answer!'}, {answer: 'the third answer!'}]
    end

    it "includes formatting questions" do
      resp = FormResponse.create form_structure: @form_structure, subject_id: 'abc'
      question1 = FormQuestion.create variable_name: 'var1', prompt: 'whatever', display_number: "100", sequence_number: 100, question_type: 'email', form_structure: @form_structure
      question2 = FormQuestion.create variable_name: 'var2', prompt: 'whatever', display_number: "200", sequence_number: 200, question_type: 'header', form_structure: @form_structure
      question3 = FormQuestion.create variable_name: 'var3', prompt: 'whatever', display_number: "300", sequence_number: 300, question_type: 'zipcode', form_structure: @form_structure

      answer1 = FormAnswer.create(form_response: resp, form_question: question1, answer: 'first answer')
      answer3 = FormAnswer.create(form_response: resp, form_question: question3, answer: 'third answer')

      FormAnswerSerializer.expects(:serialize).returns({answer: "the first answer!"})
      FormAnswerSerializer.expects(:serialize).returns({})
      FormAnswerSerializer.expects(:serialize).returns({answer: "the third answer!"})

      serialized_response = subject.serialize(user, resp)
      serialized_response[:answers].should =~ [{answer: 'the first answer!'}, {}, {answer: 'the third answer!'}]
    end

    it "includes all_instances of size 1 if form is one to one" do
      SubjectLookup.expects(:known_subjects_of_project).with(@project).returns(["a","b","c"])
      response_id = SecureRandom.uuid
      resp = FormResponse.create id: response_id, form_structure: @form_structure, subject_id: "c"
      serialized_response = subject.serialize(user, resp)
      serialized_response[:allInstances].length.should == 1
    end

    it "includes all_instances in a many to one form with more than one instance for the subject" do
      resp1 = FormResponse.create(form_structure: @form_structure, id: SecureRandom.uuid, subject_id: "a", instance_number: 0, secondary_id: "a")
      resp2 = FormResponse.create(form_structure: @form_structure, id: SecureRandom.uuid, subject_id: "a", instance_number: 1, secondary_id: "b")
      resp3 = FormResponse.create(form_structure: @form_structure, id: SecureRandom.uuid, subject_id: "b", instance_number: 0, secondary_id: "c")
      serialized_response = subject.serialize(user, resp1)
      serialized_response[:allInstances].length.should == 2
      serialized_response[:allInstances].should =~ [{:instanceNumber=>0, :secondaryId=>"a"},
                                                    {:instanceNumber=>1, :secondaryId=>"b"}]
    end
  end
end
