describe FormDataGridConstructor do
  subject { described_class }

  let(:response) { {
                         "response_id" => "1",
                         "response_created_at" => Date.new,
                         "response_updated_at" => Date.new,
                         "secondary_id" => "1/1/2001",
                         "subject_id" => "subject 1",
                     }

  }
  let(:responses){ [response] }
  let(:form) { FormStructure.new(is_many_to_one: false, secondary_id: "visit date") }

  let(:response_obj) { {
      variableName: "subjectID",
      value: "subject 1",
      responseID: "1",
      created: Date.new.to_time.to_i,
      updated: Date.new.to_time.to_i
  } }

  let(:secondary_obj) { {
      variableName: "visit_date",
      value: "1/1/2001"
  } }

  describe "construct_body" do
    it "returns an array of rows of grid objects" do
      FormDataAnswerFormatter.expects(:format_and_push).with([response_obj], response, {}).returns(nil)
      result = subject.construct_body(form, responses, {})
      result.should == [[response_obj]]
    end

    it "adds a response object for a many to one form" do
      form.is_many_to_one = true
      FormDataAnswerFormatter.expects(:format_and_push).with([response_obj, secondary_obj], response, {}).returns(nil)
      result = subject.construct_body(form, responses, {})
      result.should == [[response_obj, secondary_obj]]
      form.is_many_to_one = false
    end

    it "returns an empty array if responses is empty" do
      result = subject.construct_body(form, [], {})
      result.should == []
    end
  end
end