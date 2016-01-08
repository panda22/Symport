describe FormRecordCreator do
  subject { described_class }
  describe '.create_structure' do
    let (:data) { { name: 'My Cool Form' } }
    let (:project) { Project.create name: "The TTP Project" }
    it 'creates a saved form structure record' do
      rec = subject.create_structure(project, data)
      rec.should_not be_nil
      rec.id.should_not be_nil
      loaded_rec = FormStructure.find(rec.id)
      loaded_rec.should == rec
      loaded_rec.project.should == project
      project.reload.form_structures.should include(rec)
    end

    it 'removes leading and trailing spaces from structure name before creating one' do
      data = { name: "      My Cool Form     "}
      rec = FormRecordCreator.create_structure(project, data)
      rec.name.should == "My Cool Form"
    end

    it "doesnt' allow creation of two forms with names which are equal after removing leading and trailing spaces" do
      data1 = { name: "      My Cool Form     "}
      data2 = { name: "My Cool Form"}
      rec1 = FormRecordCreator.create_structure(project, data1)
      rec1.name.should == "My Cool Form"

      expect { FormRecordCreator.create_structure(project, data2) }.to raise_error ActiveRecord::RecordInvalid
    end

    it "throws an exception when the record fails to validate" do
      project = Project.create name: "Proj"
      fs = subject.create_structure project, name: "once"
      fs.should_not be_nil

      expect do
        fs2 = subject.create_structure project, name: "once"
      end.to raise_error ActiveRecord::RecordInvalid
    end
  end

  describe '.create_question' do
    it 'creates a question with basic fields (type, variable name, prompt, description, question number, personally identifiable)' do
      structure = FormStructure.create! name: "My Form"
      data = {
        type: 'date',
        variableName: 'my_variable_name',
        prompt: 'What day is it?',
        sequenceNumber: 3,
        displayNumber: "3",
        description: 'today is fine',
        personallyIdentifiable: true
      }
      FormQuestionConditionsCreator.stubs(:create).returns([])
      question = subject.create_question(data, structure)
      question.question_type.should == 'date'
      question.sequence_number.should == 3
      question.prompt.should == 'What day is it?'
      question.description.should == 'today is fine'
      question.variable_name.should == 'my_variable_name'
      question.personally_identifiable.should be_true
      question.form_structure == structure
    end

    it 'rejects to create a question if the new question has the same variable name of an existing question in the same project' do
      project = Project.create! name:"Project1"

      form1 = FormStructure.create! name:"Pretty Form", project: project
      question1 = FormQuestion.create! prompt: "foo", question_type: "text", sequence_number: 1, display_number: "1", variable_name: 'variable_name_1'
      form1.form_questions << question1

      new_question_data = {
        prompt: 'whatever',
        variableName: 'variable_name_1',
        sequenceNumber: 1,
        type: 'text',
        config: { size: 'large' }
      }
      form2 = FormStructure.create! name:"Not Pretty Form", project: project
      FormQuestionConditionsCreator.stubs(:create).returns([])
      expect { subject.create_question new_question_data, form2 }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'rejects a question with variable name which includes other things than digits, letters and underscores' do
      data = {
        prompt: 'whatever',
        variableName: 'variable_name_1#',
        sequenceNumber: 1,
        displayNumber: "1",
        type: 'text',
        config: { size: 'large' }
      }
      FormQuestionConditionsCreator.stubs(:create).returns([])
      expect { subject.create_question data, FormStructure.new }.to raise_error ActiveRecord::RecordInvalid
    end

    describe 'converts config to appropriate model types' do
      before { FormQuestionConditionsCreator.stubs(:create).returns([]) }
      it 'converts text config' do
        data = {
          prompt: 'whatever',
          variableName: 'whatever',
          sequenceNumber: 1,
          displayNumber: "1",
          type: 'text',
          config: { size: 'large' }
        }
        question = subject.create_question data, FormStructure.new
        question.question_type.should == 'text'
        question.text_config.size.should == 'large'
      end

      describe 'converts options config' do
        context 'radio' do
          it 'converts radio config' do
            data = {
              prompt: 'whatever',
              variableName: 'whatever',
              sequenceNumber: 1,
              displayNumber: "1",
              type: 'radio',
              config: {
                selections: [
                  {value: 'one', code: "1"},
                  {value: 'two', code: "2"},
                  {value: 'three', code: "3"},
                ]
              }
            }
            question = subject.create_question data, FormStructure.new
            question.question_type.should == 'radio'
            question.option_configs.sort_by(&:index).map(&:value).should == ['one', 'two', 'three']
          end

          it "doesn't create question if no option is provided" do
            data = {
              prompt: 'whatever',
              variableName: 'whatever',
              sequenceNumber: 1,
              displayNumber: "1",
              type: 'radio',
              config: {
              }
            }
            expect { subject.create_question data, FormStructure.new }.to raise_error ActiveRecord::RecordInvalid
          end

        end

        context "checkbox" do
          it 'converts checkbox config' do
            data = {
              prompt: 'whatever',
              variableName: 'whatever',
              sequenceNumber: 1,
              displayNumber: "1",
              type: 'checkbox',
              config: {
                selections: [
                  {value: 'one', code: "1"},
                  {value: 'two', code: "2"},
                  {value: 'three', code: "3"},
                ]
              }
            }
            question = subject.create_question data, FormStructure.new
            question.question_type.should == 'checkbox'
            question.option_configs.sort_by(&:index).map(&:value).should == ['one', 'two', 'three']
          end

          it "doesn't create question if no option is provided" do
            data = {
              prompt: 'whatever',
              variableName: 'whatever',
              sequenceNumber: 1,
              displayNumber: "1",
              type: 'checkbox',
              config: {
              }
            }
            expect { subject.create_question data, FormStructure.new }.to raise_error ActiveRecord::RecordInvalid
          end
        end

        context "yesno" do
          it 'converts yesno config' do
            data = {
              prompt: 'whatever',
              variableName: 'whatever',
              sequenceNumber: 1,
              displayNumber: "1",
              type: 'yesno',
              config: {
                selections: [
                  {value: 'yes', code: "1"},
                  {value: 'no', code: "2"},
                ]
              }
            }
            question = subject.create_question data, FormStructure.new
            question.question_type.should == 'yesno'
            question.option_configs.sort_by(&:index).map(&:value).should == ['yes', 'no']
          end
        end

        it "doesn't create question if no option is provided" do
          data = {
            prompt: 'whatever',
            variableName: 'whatever',
            sequenceNumber: 1,
            displayNumber: "1",
            type: 'yesno',
            config: {
            }
          }
          expect { subject.create_question data, FormStructure.new }.to raise_error ActiveRecord::RecordInvalid
        end
      end

      it 'converts Number config' do
        data = {
          prompt: 'whatever',
          variableName: 'whatever',
          sequenceNumber: 1,
          displayNumber: "1",
          type: 'numericalrange',
          config: { minValue: '1', maxValue: '10', precision: '3' }
        }
        question = subject.create_question data, FormStructure.new
        question.question_type.should == 'numericalrange'
        question.numerical_range_config.minimum_value.should == 1
        question.numerical_range_config.maximum_value.should == 10
        question.numerical_range_config.precision.should == '3'
      end
    end

    describe 'conditions' do
      let(:q1) { create :question, form_structure: structure, sequence_number: 2, display_number: "2", prompt: "p1", variable_name: "v2"}
      let(:q2) { create :question, form_structure: structure, sequence_number: 3, display_number: "3", prompt: "p2", variable_name: "v3"}
      let(:structure) { FormStructure.create! name: "My Form" }
      let(:qc1) { FormQuestionCondition.new operator: "<>", value: "apple", depends_on: q1 }
      let(:qc2) { FormQuestionCondition.new operator: "<=", value: "10", depends_on: q2 }
      let(:data) {
        {
          prompt: 'whatever',
          sequenceNumber: 4,
          displayNumber: "4",
          variableName: 'whatever',
          type: 'phonenumber',
          conditions: [
            { dependsOn: q1.id, operator: "<>", value: "apple" },
            { dependsOn: q2.id, operator: "<=", value: "10" }
          ]
        }
      }
      it 'translates conditions' do
        FormQuestionConditionsCreator.expects(:create).with(data[:conditions]).returns([qc1, qc2])
        question = subject.create_question(data, structure)
        question.form_question_conditions[0].depends_on.should == q1
        question.form_question_conditions[0].operator.should == "<>"
        question.form_question_conditions[0].value.should == "apple"
        question.form_question_conditions[1].depends_on.should == q2
        question.form_question_conditions[1].operator.should == "<="
        question.form_question_conditions[1].value.should == "10"
      end

      it "rejects invalid conditions" do
        new_question_condition = FormQuestionCondition.new
        FormQuestionConditionsCreator.expects(:create).with(data[:conditions]).raises ActiveRecord::RecordInvalid.new(new_question_condition)
        expect { subject.create_question(data, structure) }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe '.create_answer' do
    it 'creates an answer record from a question' do
      question = FormQuestion.create! prompt: "foo", question_type: "text", sequence_number: 1, display_number: "1", variable_name: 'whatever'
      answer = subject.create_answer question
      FormAnswer.find(answer.id).form_question.prompt.should == "foo"
    end
  end

  describe '.create_response' do
    subject_id = "abc123"
    q1 = FormQuestion.create prompt: "foo"
    q2 = FormQuestion.create prompt: "bar"
    a1 = FormAnswer.new form_question: q1, answer: "food"
    a2 = FormAnswer.new form_question: q2, answer: "barn"
    structure = FormStructure.create form_questions: [q1, q2]

    it 'creates a form response record with a subject id and saves all its answers' do
      response_record = subject.create_response subject_id, structure, [a1, a2], 0
      response_record.reload.form_answers.map(&:answer).sort == ["barn", "food"]
      a1.reload.form_response.should == response_record
      a2.reload.form_response.should == response_record
      response_record.subject_id.should == subject_id
    end
  end

  describe '.new_answer' do
    it 'creates an answer record from a question and does not save it to the DB' do
      question = FormQuestion.create prompt: "foo", question_type: "text", sequence_number: 1, variable_name: 'whatever'
      answer = subject.new_answer question
      raises_not_found do
        FormAnswer.find(answer.id) 
      end
    end
  end

  describe '.new_response and does not save it to the DB' do
    subject_id = "abc123"
    q1 = FormQuestion.create prompt: "foo"
    q2 = FormQuestion.create prompt: "bar"
    a1 = FormAnswer.new form_question: q1, answer: "food"
    a2 = FormAnswer.new form_question: q2, answer: "barn"
    structure = FormStructure.create form_questions: [q1, q2]

    it 'creates a form response record with a subject id and saves all its answers' do
      structure = FormStructure.create form_questions: [q1, q2]
      response_record = subject.new_response subject_id, structure, [a1, a2], 0
      response_record.form_answers.map(&:answer).sort == ["barn", "food"]
      raises_not_found do a1.reload end
      raises_not_found do a2.reload end
      response_record.subject_id.should == subject_id
    end
  end

  def raises_not_found(opts={})
    expect { 
      yield if block_given? 
    }.to raise_error ActiveRecord::RecordNotFound 
  end

end
