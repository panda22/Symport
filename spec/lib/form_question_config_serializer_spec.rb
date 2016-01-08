require 'spec_helper'

describe FormQuestionConfigSerializer do
  subject { described_class }

  describe '.validation_errors' do
    it 'serializes the errors in the Number question' do
      question = FormQuestion.new question_type: 'numericalrange'
      question.numerical_range_config = NumericalRangeConfig.new
      question.numerical_range_config.errors[:minimum_value] <<  "Can't be empty!"
      serialized_errors = subject.validation_errors(question)
      serialized_errors.should == {"minValue" => ["Can't be empty!"] }
    end

    it 'serializes the errors in the text config question' do
      question = FormQuestion.new question_type: 'text'
      question.text_config = TextConfig.new
      question.text_config.errors[:size] << "Can't be blank!"
      serialized_errors = subject.validation_errors(question)
      serialized_errors.should == {size: ["Can't be blank!"] }
    end

    it "handles selection types" do
      question = FormQuestion.new question_type: "radio"
      o1 = OptionConfig.new index: 2, code: "2", value: ""
      o2 = OptionConfig.new index: 0, code: "0", value: nil
      o3 = OptionConfig.new index: 1, code: "1", value: "bananas"
      question.option_configs = [o1, o2, o3]
      o1.errors[:value] << "can't be blank!"
      o2.errors[:value] << "can't be blank!"

      serialized_errors = subject.validation_errors question
      serialized_errors.should == {selections: {
        0 => ["can't be blank!"],
        2 => ["can't be blank!"]
      }}
    end
  end

  describe '.serialize' do
    it 'serializes a text type' do
      config = TextConfig.new id: 1, size: 'normal'
      question = FormQuestion.new id: 1, question_type: 'text', text_config: config
      serialized_config = subject.serialize(question)
      serialized_config.should == {size: 'normal'}
    end

    it 'serializes a numericalrange type' do
      config = NumericalRangeConfig.new id: 1, minimum_value: 10, maximum_value: 100, precision: '2'
      question = FormQuestion.new id: 1, question_type: 'numericalrange', numerical_range_config: config
      serialized_config = subject.serialize(question)
      serialized_config.should == {minValue: 10,  maxValue: 100, precision: '2'}
    end

    describe 'selection types' do
      let(:config1) { OptionConfig.new(index: 3, code: "3", value: 'apple') }
      let(:config2) { OptionConfig.new(index: 1, code: "1", value: 'orange') }
      let(:config3) { OptionConfig.new(index: 2, code: "2", value: 'banana') }
      it 'serializes a checkbox type' do
        configs = [config1, config2, config3]
        question = FormQuestion.new id: SecureRandom.uuid, question_type: 'checkbox', option_configs: configs
        serialized_config = subject.serialize(question)
        serialized_config.should == {
          selections: [
            {:value=>"orange", id: nil, otherOption: false, otherVariableName: nil, code: "1"}, 
            {:value=>"banana", id: nil, otherOption: false, otherVariableName: nil, code: "2"}, 
            {:value=>"apple", id: nil, otherOption: false, otherVariableName: nil, code: "3"}
          ]
        }
      end

      it 'serializes a radio type' do
        configs = [config3, config1, config2]
        question = FormQuestion.new id: SecureRandom.uuid, question_type: 'radio', option_configs: configs
        serialized_config = subject.serialize(question)
        serialized_config.should == {
          selections: [
            {:value=>"orange", id: nil, otherOption: false, otherVariableName: nil, code: "1"}, 
            {:value=>"banana", id: nil, otherOption: false, otherVariableName: nil, code: "2"}, 
            {:value=>"apple", id: nil, otherOption: false, otherVariableName: nil, code: "3"}
          ]
        }
      end

      it 'serializes a dropdown type' do
        configs = [config3, config1, config2]
        question = FormQuestion.new id: SecureRandom.uuid, question_type: 'dropdown', option_configs: configs
        serialized_config = subject.serialize(question)
        serialized_config.should == {
          selections: [
            {:value=>"orange", id: nil, otherOption: false, otherVariableName: nil, code: "1"}, 
            {:value=>"banana", id: nil, otherOption: false, otherVariableName: nil, code: "2"}, 
            {:value=>"apple", id: nil, otherOption: false, otherVariableName: nil, code: "3"}
          ]
        }
      end

      it 'serializes a yesno type' do
        config1 = OptionConfig.new(index: 2, code: "2", value: 'no')
        config2 = OptionConfig.new(index: 1, code: "1", value: 'yes')
        configs = [config1, config2]
        question = FormQuestion.new id: SecureRandom.uuid, question_type: 'yesno', option_configs: configs
        serialized_config = subject.serialize(question)
        serialized_config.should == {
          selections: [
            {value: "yes", id: nil, otherOption: false, otherVariableName: nil, code:"1"}, 
            {value: "no", id: nil, otherOption: false, otherVariableName: nil, code:"2"}
          ]
        }
      end
    end

    describe 'empty configs' do
      it 'serializes a date type' do
        question = FormQuestion.new question_type: 'date'
        subject.serialize(question).should == {}
      end

      it 'serializes a zipcode type' do
        question = FormQuestion.new question_type: 'zipcode'
        subject.serialize(question).should == {}
      end

      it 'serializes a email type' do
        question = FormQuestion.new question_type: 'email'
        subject.serialize(question).should == {}
      end

      it 'serializes a time of day type' do
        question = FormQuestion.new question_type: 'timeofday'
        subject.serialize(question).should == {}
      end

      it 'serializes a time duration type' do
        question = FormQuestion.new question_type: 'timeduration'
        subject.serialize(question).should == {}
      end

      it 'serializes a header type' do
        question = FormQuestion.new question_type: 'header'
        subject.serialize(question).should == {}
      end

      it 'serializes a phone number type' do
        question = FormQuestion.new question_type: 'phonenumber'
        subject.serialize(question).should == {}
      end
    end
  end
end