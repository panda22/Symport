describe FormStructureSerializer do
  subject { described_class }
  describe '.serialize' do
    let(:structure_id) { SecureRandom.uuid }
    let(:user) { User.new }

    before do
      mock_class FormLevelPermissionsSerializer, strict: true
      FormLevelPermissionsSerializer.stubs(:serialize).returns({})
    end

    it 'serializes id field' do
      rec = FormStructure.create! id: structure_id, name: "Structure1"
      serialized_rec = subject.serialize(user, rec, true)
      serialized_rec[:id].should == structure_id
    end

    it 'serializes name field' do
      rec = FormStructure.create id: structure_id, name: 'Structure1'
      serialized_rec = subject.serialize(user, rec, true)
      serialized_rec[:name].should == 'Structure1'
    end

    it 'serializes last edited field' do
      rec = FormStructure.create id: structure_id, name: 'Structure1', updated_at: Time.zone.parse("Jan 24, 2013 13:05")
      serialized_rec = subject.serialize(user, rec, true)
      serialized_rec[:lastEdited].should == "2013-01-24T13:05:00Z"
    end

    it 'serializes responses count' do
      resp1 = FormResponse.create subject_id: "1"
      resp2 = FormResponse.create subject_id: "2"
      rec = FormStructure.create! id: structure_id, name: 'Structure1', form_responses: [resp1, resp2]
      serialized_rec = subject.serialize(user, rec, true)
      serialized_rec[:responsesCount].should == 2
    end

    it 'serializes question field' do
      id1 = SecureRandom.uuid
      id2 = SecureRandom.uuid
      id3 = SecureRandom.uuid
      q1 = FormQuestion.create(id: id1, question_type: "text", variable_name: "v1", prompt: 'Prompt1', text_config: TextConfig.create(size: "large"), sequence_number: 1, display_number: "1")
      q2 = FormQuestion.create(id: id2, question_type: "text", variable_name: "v2", prompt: 'Prompt2', text_config: TextConfig.create(size: "large"), sequence_number: 2, display_number: "2")
      q3 = FormQuestion.create(id: id3, question_type: "text", variable_name: "v3", prompt: 'Prompt3', text_config: TextConfig.create(size: "large"), sequence_number: 3, display_number: "3")
      serialized_q1 = {id: id1, question_type: "text", variable_name: "v1", prompt: 'Prompt1', text_config: {size: "large"}}
      serialized_q2 = {id: id2, question_type: "text", variable_name: "v2", prompt: 'Prompt2', text_config: {size: "large"}}
      serialized_q3 = {id: id3, question_type: "text", variable_name: "v3", prompt: 'Prompt3', text_config: {size: "large"}}
      FormQuestionSerializer.expects(:serialize).with(q1).returns(serialized_q1)
      FormQuestionSerializer.expects(:serialize).with(q2).returns(serialized_q2)
      FormQuestionSerializer.expects(:serialize).with(q3).returns(serialized_q3)
      rec = FormStructure.create id: structure_id, name: 'Structure1', form_questions: [q3, q2, q1]
      serialized_rec = subject.serialize(user, rec, true)
      serialized_rec[:questions].should == [serialized_q1, serialized_q2, serialized_q3]
    end

    it 'ignores questions if not requested' do
      id1 = SecureRandom.uuid
      id2 = SecureRandom.uuid
      id3 = SecureRandom.uuid
      q1 = FormQuestion.create(id: id1, question_type: "text", variable_name: "v1", prompt: 'Prompt1', text_config: TextConfig.create(size: "large"), sequence_number: 1, display_number: "1")
      q2 = FormQuestion.create(id: id2, question_type: "text", variable_name: "v2", prompt: 'Prompt2', text_config: TextConfig.create(size: "large"), sequence_number: 2, display_number: "2")
      q3 = FormQuestion.create(id: id3, question_type: "text", variable_name: "v3", prompt: 'Prompt3', text_config: TextConfig.create(size: "large"), sequence_number: 3, display_number: "3")
      serialized_q1 = {id: id1, question_type: "text", variable_name: "v1", prompt: 'Prompt1', text_config: {size: "large"}}
      serialized_q2 = {id: id2, question_type: "text", variable_name: "v2", prompt: 'Prompt2', text_config: {size: "large"}}
      serialized_q3 = {id: id3, question_type: "text", variable_name: "v3", prompt: 'Prompt3', text_config: {size: "large"}}
      FormQuestionSerializer.expects(:serialize).with(q1).never
      FormQuestionSerializer.expects(:serialize).with(q2).never
      FormQuestionSerializer.expects(:serialize).with(q3).never
      rec = FormStructure.create id: structure_id, name: 'Structure1', form_questions: [q1, q2, q3]
      serialized_rec = subject.serialize(user, rec, false)
      serialized_rec.should_not have_key(:questions)
    end

    it "serialized user permissions" do
      rec = FormStructure.create id: structure_id, name: 'Structure1'
      FormLevelPermissionsSerializer.expects(:serialize).with(user, rec).returns("permissions")
      serialized_rec = subject.serialize(user, rec, false)
      serialized_rec[:userPermissions].should == "permissions"
    end
  end
end
