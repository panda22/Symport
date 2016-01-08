describe VariableNameValidator do
  subject { described_class }

  context "presence" do
    it "requires variable name in most cases" do
      expect { FormQuestion.create! question_type: "date", sequence_number: 1, display_number: "1", prompt: "bar", variable_name: "foo" }.not_to raise_error
      expect { FormQuestion.create! question_type: "date", sequence_number: 2, display_number: "2", prompt: "bar" }.to raise_error ActiveRecord::RecordInvalid

      expect { FormQuestion.create! question_type: "zipcode", sequence_number: 3, display_number: "3", prompt: "bar", variable_name: "foo" }.not_to raise_error
      expect { FormQuestion.create! question_type: "zipcode", sequence_number: 4, display_number: "4", prompt: "bar" }.to raise_error ActiveRecord::RecordInvalid
    end

    it "does not require variable name for headers or pagebreaks" do
      expect { FormQuestion.create! question_type: "header", sequence_number: 1, display_number: "1", prompt: "bar" }.not_to raise_error
      expect { FormQuestion.create! question_type: "pagebreak", sequence_number: 2, display_number: "2", prompt: "bar" }.not_to raise_error
    end
  end

  context "new record" do
    it 'rejects updating a question if the new value for variable name is already used by another question on that project' do
      project = Project.create! name:"Project1"

      form1 = FormStructure.create! name:"Pretty Form", project: project
      question1 = FormQuestion.create! prompt: "foo", question_type: "text", sequence_number: 1, display_number: "1", variable_name: 'variable_name_1'
      question2 = FormQuestion.create! prompt: "bar", question_type: "text", sequence_number: 2, display_number: "2", variable_name: 'variable_name_2'
      form1.form_questions << [question1, question2]

      expect { 
        form1.form_questions << build(:question, variable_name: "variable_name_2") 
        form1.save!
      }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'allows updating a question if the new value for variable name is not used in another question on that project' do
      project = Project.create! name:"Project1"

      form1 = FormStructure.create! name:"Pretty Form", project: project
      question1 = FormQuestion.create! prompt: "foo", question_type: "text", sequence_number: 1, display_number: "1", variable_name: 'variable_name_1'
      question2 = FormQuestion.create! prompt: "bar", question_type: "text", sequence_number: 2, display_number: "2", variable_name: 'variable_name_2'
      form1.form_questions << [question1, question2]

      expect { 
        form1.form_questions << build(:question, prompt: "foobar", question_type: "text", sequence_number: 3, display_number: "3",variable_name: "variable_name_3") 
        form1.save!
      }.not_to raise_error
    end

    it 'allows updating a question if the new value for variable name is used in another project' do
      project1 = Project.create! name:"Project1"
      project2 = Project.create! name:"Project2"

      form1 = FormStructure.create! name:"Pretty Form", project: project1
      question1 = FormQuestion.create! prompt: "foo", question_type: "text", sequence_number: 1, display_number: "1", variable_name: 'variable_name_1'
      question2 = FormQuestion.create! prompt: "bar", question_type: "text", sequence_number: 2, display_number: "2", variable_name: 'variable_name_2'
      form1.form_questions << [question1, question2]

      form2 = FormStructure.create! name:"Pretty Form 2", project: project2
      question3 = FormQuestion.create! prompt: "foo", question_type: "text", sequence_number: 3, display_number: "3", variable_name: 'variable_name_3'
      question4 = FormQuestion.create! prompt: "bar", question_type: "text", sequence_number: 4, display_number: "4", variable_name: 'variable_name_4'
      form1.form_questions << [question3, question4]

      expect { 
        form2.form_questions << [build(:question, prompt: "new", question_type: "text", sequence_number: 100, display_number: "100", variable_name: "variable_name_1")] 
        form2.save!
      }.not_to raise_error
    end
  end

  context "existing record" do
    it 'rejects updating a question if the new value for variable name is already used by another question on that project' do
      project = Project.create! name:"Project1"

      form1 = FormStructure.create! name:"Pretty Form", project: project
      question1 = FormQuestion.create! prompt: "foo", question_type: "text", sequence_number: 1, display_number: "1", variable_name: 'variable_name_1'
      question2 = FormQuestion.create! prompt: "bar", question_type: "text", sequence_number: 2, display_number: "2", variable_name: 'variable_name_2'
      form1.form_questions << [question1, question2]

      expect { question2.update_attributes! variable_name: 'variable_name_1' }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'allows updating a question if the new value for variable name is not used in another question on that project' do
      project = Project.create! name:"Project1"

      form1 = FormStructure.create! name:"Pretty Form", project: project
      question1 = FormQuestion.create! prompt: "foo", question_type: "text", sequence_number: 3, display_number: "3", variable_name: 'variable_name_1'
      question2 = FormQuestion.create! prompt: "bar", question_type: "text", sequence_number: 4, display_number: "4", variable_name: 'variable_name_2'
      form1.form_questions << [question1, question2]

      expect { question2.update_attributes! variable_name: 'variable_name_3' }.not_to raise_error
    end
  end
end
