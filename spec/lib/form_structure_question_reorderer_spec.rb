describe FormStructureQuestionReorderer do
  subject { described_class }
  describe '.reorder' do
    let (:question_1) { FormQuestion.create variable_name: 'variable_name_1', prompt: 'whatever', sequence_number: 2, display_number: "2", question_type: 'date' }
    let (:question_2) { FormQuestion.create variable_name: 'variable_name_2', prompt: 'whatever', sequence_number: 3, display_number: "3", question_type: 'date' }
    let (:question_3) { FormQuestion.create variable_name: 'variable_name_3', prompt: 'whatever', sequence_number: 4, display_number: "4", question_type: 'date' }
    let (:question_4) { FormQuestion.create variable_name: 'variable_name_4', prompt: 'whatever', sequence_number: 5, display_number: "5", question_type: 'date' }
    let (:structure) { FormStructure.create name: 'whatever', form_questions: [question_1, question_2, question_3, question_4] }

    it 're-sorts question numbers based on current question numbers' do
      FormStructure.any_instance.expects(:reload)
      reordered_structure = subject.reorder(structure)
      question_1.sequence_number.should == 1
      question_2.sequence_number.should == 2
      question_3.sequence_number.should == 3
      question_4.sequence_number.should == 4
      # make sure everything was saved
      question_1.changed?.should be_false
      question_2.changed?.should be_false
      question_3.changed?.should be_false
      question_4.changed?.should be_false
    end

    it 're-sorts question number if we just have one question in structure' do
      FormStructure.any_instance.expects(:reload)
      question_1 = FormQuestion.create variable_name: 'variable_name_1', prompt: 'whatever', sequence_number: 5, display_number: "5", question_type: 'date'
      structure = FormStructure.create name: 'whatever', form_questions: [question_1]
      subject.reorder(structure)
      question_1.sequence_number.should == 1
    end

    describe 'prefers to keep the question number of the new question intact' do
      it 'moves the question up' do
        FormStructure.any_instance.expects(:reload)
        question_4.sequence_number = 3
        subject.reorder(structure, question_4)
        question_1.sequence_number.should == 1
        question_2.sequence_number.should == 2
        question_4.sequence_number.should == 3
        question_3.sequence_number.should == 4
        # make sure everything was saved
        question_1.changed?.should be_false
        question_2.changed?.should be_false
        question_3.changed?.should be_false
        question_4.changed?.should be_false
      end

      it 'moves the question down' do
        FormStructure.any_instance.expects(:reload)
        question_1.sequence_number = 3
        subject.reorder(structure, question_1)
        question_2.sequence_number.should == 1
        question_3.sequence_number.should == 2
        question_1.sequence_number.should == 3
        question_4.sequence_number.should == 4
        # make sure everything was saved
        question_1.changed?.should be_false
        question_2.changed?.should be_false
        question_3.changed?.should be_false
        question_4.changed?.should be_false
      end

    end

    describe "it updates all questions in a transaction" do
      it "rejects updates when questions cannot be saved" do
        FormStructure.any_instance.expects(:reload).never
        question_3.variable_name = "inv@l!d"
        expect { subject.reorder(structure) }.to raise_error ActiveRecord::RecordInvalid
        question_1.reload.sequence_number.should == 2
        question_2.reload.sequence_number.should == 3
        question_3.reload.sequence_number.should == 4
        question_4.reload.sequence_number.should == 5
      end

      it "rejects updates when conditions become invalid" do
        FormStructure.any_instance.expects(:reload).never
        question_3.form_question_conditions << FormQuestionCondition.create(depends_on: question_4, operator: ">=", value: "10")
        expect { subject.reorder(structure) }.to raise_error ActiveRecord::RecordInvalid
        question_1.reload.sequence_number.should == 2
        question_2.reload.sequence_number.should == 3
        question_3.reload.sequence_number.should == 4
        question_4.reload.sequence_number.should == 5
      end
    end
    
  end
end
