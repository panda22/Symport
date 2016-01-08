describe FormDataAnswerFormatter do
  subject { described_class }

  let(:row) { [] }
  let(:reg_record) { {"answer" => "a", "var_name" => "b", "answer_id" => "c", "has_other_type" => "0"} }
  let(:checkbox_record) { {"answer" => "x\u200Cy\u200Cz", "var_name" => "b", "answer_id" => "c", "has_other_type" => "0"} }
  let(:other_reg_record) { {"answer" => "a\u200Aother stuff", "var_name" => "b", "answer_id" => "c", "has_other_type" => "1"} }
  let(:other_checkbox_record) { {"answer" => "x\u200Cy\u200Aother stuff\u200Cz", "var_name" => "b", "answer_id" => "c", "has_other_type" => "1"} }
  let(:other_question_hash) { {"abc" => "def"} }

  describe "format_and_push normal" do
    before do
      row = []
    end

    it "pushes a normal non-checkbox answer on the grid" do
      subject.format_and_push(row, reg_record, {})
      row.should == [{variableName: "b", value: "a", answerID: "c"}]
    end

    it "pushes a normal checkbox answer on the grid" do
      subject.format_and_push(row, checkbox_record, {})
      row.should == [{variableName: "b", value: "x ● y ● z", answerID: "c"}]
    end
  end

  describe "format_and_push other" do
    before do
      row = []
      other_reg_record["question_id"] = "abc"
      other_checkbox_record["question_id"] = "abc"
    end

    it "pushes a normal non-checkbox answer on the grid" do
      subject.format_and_push(row, other_reg_record, other_question_hash)
      row.should == [{variableName: "b", value: "a", answerID: "c"}, {variableName: "def", value: "other stuff"}]
    end

    it "pushes a normal checkbox answer on the grid" do
      subject.format_and_push(row, other_checkbox_record, other_question_hash)
      row.should == [{variableName: "b", value: "x ● y ● z", answerID: "c"}, {variableName: "def", value: "other stuff"}]
    end
  end
end