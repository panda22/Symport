describe FormQuestion do

  describe 'question_type' do
    it 'must be present' do
      q = FormQuestion.new sequence_number: 5, display_number: "5", prompt: "foo", variable_name: "var1"
      expect { q.save! }.to raise_error { |err|
        err.class.should == ActiveRecord::RecordInvalid
        err.message.should =~ /Question type can't be blank/
      }
    end

    it 'must be in an approved list of values' do
      q = FormQuestion.new sequence_number: 5, display_number: "5", prompt: "foo", variable_name: "var1", question_type: "notpresent"
      expect { q.save! }.to raise_error { |err|
        err.class.should == ActiveRecord::RecordInvalid
        err.message.should =~ /Question type notpresent is not a valid question type/
      }
    end
  end

  describe 'prompt' do
    let (:props_without_prompt) { { sequence_number: 1, variable_name: "foo" } }
    it 'usually requires a prompt' do
      type = "zipcode"
      expect { FormQuestion.create! props_without_prompt.merge(question_type: type, prompt: "Hello", sequence_number: 55, display_number: "55") }.not_to raise_error
      expect { FormQuestion.create! props_without_prompt.merge(question_type: type) }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'allows no prompt if question type is page break' do
      type = "pagebreak"
      expect { FormQuestion.create! props_without_prompt.merge(question_type: type, prompt: "Hello", sequence_number: 55, display_number: "55") }.not_to raise_error
      expect { FormQuestion.create! props_without_prompt.merge(question_type: type, sequence_number: 55, display_number: "55") }.not_to raise_error
    end
  end


  describe 'sequence number' do
    it 'requires a sequence number' do
      q = FormQuestion.new prompt: "foo", variable_name: "var1", question_type: "text"
      expect { q.save! }.to raise_error { |err|
        err.class.should == ActiveRecord::RecordInvalid
        err.message.should =~ /Sequence number must be specified/
      }
    end
  end

end
