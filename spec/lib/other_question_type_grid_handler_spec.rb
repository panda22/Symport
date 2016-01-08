describe OtherQuestionTypeGridHandler do
  subject { described_class }

  let (:form) { FormStructure.new(name: "abcde", id: SecureRandom.uuid) }

  let (:check_box_question) { FormQuestion.new(id:SecureRandom.uuid, question_type: "checkbox", form_structure_id: form.id) }
  let (:checkbox_normal_config) { OptionConfig.new(form_question_id: check_box_question.id, other_option: false, value: "123") }
  let (:checkbox_other_config) { OptionConfig.new(form_question_id: check_box_question.id, other_option: true, other_variable_name: "a", value: "456") }

  let (:radio_box_question) { FormQuestion.new(id:SecureRandom.uuid, question_type: "radio", form_structure_id: form.id) }
  let (:radio_normal_config) { OptionConfig.new(form_question_id: check_box_question.id, other_option: false, value: "234") }
  let (:radio_other_config) { OptionConfig.new(form_question_id: check_box_question.id, other_option: true, other_variable_name: "a", value: "567") }

  describe "add_other_question_to_form_hash" do
    it "adds the associated form to the question to form hash for an other question" do
      hash = {}
      index = 100
      check_box_question.expects(:option_configs).returns([checkbox_normal_config, checkbox_other_config])
      check_box_question.expects(:form_structure).returns(form)
      subject.add_other_question_to_form_hash(check_box_question, hash, index)
      result = hash[checkbox_other_config.other_variable_name]
      result.should == {name: "abcde", index: 100}
    end

    it "does not input a hash index if the question is not checkbox or radio" do
      hash = {}
      index = 100
      check_box_question.question_type = "text"
      subject.add_other_question_to_form_hash(check_box_question, hash, index)
      result = hash[checkbox_other_config.other_variable_name]
      result.should == nil
      hash.should == {}
      check_box_question.question_type = "checkbox"
    end

    it "does not input a hash index if the question has no other option configs" do
      hash = {}
      index = 100
      check_box_question.expects(:option_configs).returns([checkbox_normal_config])
      subject.add_other_question_to_form_hash(check_box_question, hash, index)
      result = hash[checkbox_other_config.other_variable_name]
      result.should == nil
      hash.should == {}
    end
  end

  describe "get_and_push_other_questions" do
    it "returns configs for an other question and pushes to heading" do
      heading = []
      num_instances = 4
      instance_number = 2
      check_box_question.expects(:option_configs).returns([checkbox_normal_config, checkbox_other_config])
      result = subject.get_and_push_other_questions(check_box_question, heading, num_instances, instance_number)
      heading.length.should == 1
      heading[0].should == {
          value: "#{checkbox_other_config.other_variable_name}_#{instance_number+1}",
          type: "text"
      }
      result.should == [checkbox_other_config]
    end

    it "omits the _instance_number if there is only one max instance" do
      heading = []
      num_instances = 1
      instance_number = 0
      check_box_question.expects(:option_configs).returns([checkbox_normal_config, checkbox_other_config])
      result = subject.get_and_push_other_questions(check_box_question, heading, num_instances, instance_number)
      heading.length.should == 1
      heading[0].should == {
          value: "#{checkbox_other_config.other_variable_name}",
          type: "text"
      }
      result.should == [checkbox_other_config]
    end

    it "returns an empty array if no configs with other_options" do
      heading = []
      num_instances = 4
      instance_number = 2
      check_box_question.expects(:option_configs).returns([checkbox_normal_config])
      result = subject.get_and_push_other_questions(check_box_question, heading, num_instances, instance_number)
      heading.length.should == 0
      result.should == []
    end
  end

  describe "push_other_question_answers" do
    it "pushes an other_question answer of radio type to the grid" do
      other_columns = [radio_other_config]
      answer = "567\u200Aother answer"
      index = 0
      grid = [[]]
      subject.push_other_question_answers(other_columns, answer, index, grid)
      grid.length.should == 1
      grid[0].length.should == 1
      grid[0][0].should == {value: "other answer", exception: false}
    end

    it "pushes an other_question answer of checkbox type to the grid with both answers selected" do
      other_columns = [checkbox_other_config]
      answer = "123\u200C456\u200Aother answer"
      index = 0
      grid = [[]]
      subject.push_other_question_answers(other_columns, answer, index, grid)
      grid.length.should == 1
      grid[0].length.should == 1
      grid[0][0].should == {value: "other answer", exception: false}
    end

    it "pushes an empty string if other is selected but no answer entered" do
      other_columns = [checkbox_other_config]
      answer = "123\u200C456\u200A"
      index = 0
      grid = [[]]
      subject.push_other_question_answers(other_columns, answer, index, grid)
      grid.length.should == 1
      grid[0].length.should == 1
      grid[0][0].should == {value: "", exception: false}
    end

    it "pushes the default blocked code if the answer wasn't the one with the other question type" do
      other_columns = [checkbox_other_config]
      answer = "123"
      index = 0
      grid = [[]]
      subject.push_other_question_answers(other_columns, answer, index, grid)
      grid.length.should == 1
      grid[0].length.should == 1
      grid[0][0].should == {value: "\u200D", exception: false}
    end

    it "pushes the specified empty code if other is selected but no answer entered" do
      other_columns = [checkbox_other_config]
      answer = "123\u200C456\u200A"
      index = 0
      grid = [[]]
      empty_code = "EMPTY"
      blocked_code = "BLOCKED"
      subject.push_other_question_answers(other_columns, answer, index, grid, empty_code, blocked_code)
      grid.length.should == 1
      grid[0].length.should == 1
      grid[0][0].should == {value: "EMPTY", exception: false}
    end

    it "pushes the specified blocked code if the answer wasn't the one with the other question type" do
      other_columns = [checkbox_other_config]
      answer = "123"
      index = 0
      grid = [[]]
      empty_code = "EMPTY"
      blocked_code = "BLOCKED"
      subject.push_other_question_answers(other_columns, answer, index, grid, empty_code, blocked_code)
      grid.length.should == 1
      grid[0].length.should == 1
      grid[0][0].should == {value: "BLOCKED", exception: false}
    end
  end
end