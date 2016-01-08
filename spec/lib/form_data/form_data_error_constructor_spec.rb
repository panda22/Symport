describe FormDataErrorConstructor do
  subject { described_class }

  let(:record) { {
      "answer" => "1",
      "question_id" => "2",
      "response_id" => "3",
      "message" => "this is an error",
      "answer_id" => "4",
      "ignore_error" => "f",
      "subject_id" => "subject 1",
      "secondary_id" => "1/1/2001",
      "has_other_type" => "0"
  } }
  let(:rs) { [record] }

  describe "construct_from_questions" do
    it "constructs a hash of question id and an array of error objects from the result set" do
      result = subject.construct_from_questions(rs)
      test_obj = {"2" =>[{
                             responseID: "3",
                             message: "this is an error",
                             questionID: "2",
                             answerID: "4",
                             isActive: true,
                             subjectID: "subject 1",
                             secondaryId: "1/1/2001",
                             answer: "1",
                             otherAnswer: ""
                         }
      ]}
      result.should == test_obj
    end

    it "removes the other part of an other answer" do
      record["has_other_type"] = "1"
      record["answer"] = "x\u200Cy\u200Aother stuff\u200Cz"
      result = subject.construct_from_questions(rs)
      test_obj = {"2" =>[{
                             responseID: "3",
                             message: "this is an error",
                             questionID: "2",
                             answerID: "4",
                             isActive: true,
                             subjectID: "subject 1",
                             secondaryId: "1/1/2001",
                             answer: "x\u200Cy\u200Cz",
                             otherAnswer: "other stuff"
                         }
      ]}
      result.should == test_obj
    end
  end
end