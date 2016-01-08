describe AuditSupport do
  subject { described_class }
  let (:expir) { Date.today }
  let (:user) {
    create :user, email: "audituser@users.com", password: "Complex1", first_name: "Audit",
      last_name: "User", affiliation: "Scientist", field_of_study: "Biology", phone_number: "1234567890"
  }
  let (:project) { Project.create! name: "My Project" }
  let (:team_member) {
    TeamMember.create! user: user, project: project, administrator: false,
      form_creation: true, audit: true, export: false,
      view_personally_identifiable_answers: true, expiration_date: expir
  }
  let (:form_structure) { FormStructure.create! name: "My Form", project: project }
  let (:form_question) {
    FormQuestion.create! sequence_number: 5, display_number: "5", personally_identifiable: true,
      variable_name: "ivar", prompt: "Who can it be now?", description: "knocking at my door",
      question_type: "text", text_config: text_config, form_structure: form_structure
  }
  let (:text_config) { TextConfig.create! size: "normal" }
  let (:form_structure_permission) {
    FormStructurePermission.create! team_member: team_member,
      form_structure: form_structure, permission_level: "Full"
  }
  let (:form_response) { FormResponse.create! form_structure: form_structure, subject_id: "Patient123" }
  let (:form_answer) { FormAnswer.create! form_response: form_response, form_question: form_question, answer: "Men At Work" }

  describe '.serialize' do
    context 'form structure' do
      it "serializes appropriate fields from the form structure" do
        subject.serialize(form_structure).should == { name: "My Form" }
      end
    end

    context 'form question' do
      it "serializes appropriate fields from the form question" do
        subject.serialize(form_question).should == {
          sequenceNumber: 5, personallyIdentifiable: true, prompt: "Who can it be now?", variableName: "ivar",
          description: "knocking at my door", questionType: "text", config: { size: "normal" }, exceptions: []
        }
      end
    end

    context 'form response' do
      it "serializes appropriate fields from the form response" do
        subject.serialize(form_response).should == { subjectId: "Patient123" }
      end
    end

    context 'form answer' do
      it "serializes appropriate fields from the form answer" do
        serialized_answer = subject.serialize form_answer
        serialized_answer[:answer].should == "Men At Work"
      end
    end

    context 'project' do
      it "serializes appropriate fields from the project" do
        subject.serialize(project).should == { name: "My Project" }
      end
    end

    context 'user' do
      it "serializes appropriate fields from the user" do
        subject.serialize(user).should == {
          email: "audituser@users.com", firstName: "Audit", lastName: "User",
          affiliation: "Scientist", fieldOfStudy: "Biology"
        }
      end
    end

    context 'team member' do
      it "serializes appropriate fields from the team member" do
        res = subject.serialize(team_member)
        res.should == {
          userId: user.id, administrator: false, formCreation: true, expirationDate: expir,
          audit: true, export: false, viewPersonallyIdentifiableAnswers: true
        }
      end
    end

    context 'form structure permission' do
      it "serializes appropriate fields from the form structure permission" do
        subject.serialize(form_structure_permission).should == { permissionLevel: "Full" }
      end
    end
  end

  describe '.related_records_for' do
    context 'form structure' do
      it 'gets related records for form structure' do
        subject.related_records_for(form_structure).should == {
          form_structure: form_structure,
          project: project
        }
      end
    end

    context 'form question' do
      it 'gets related records for form question' do
        subject.related_records_for(form_question).should == {
          form_question: form_question,
          form_structure: form_structure,
          project: project
        }
      end
    end

    context 'form response' do
      it 'gets related records for form response' do
        subject.related_records_for(form_response).should == {
          subject_id: "Patient123",
          secondary_id: nil,
          form_structure: form_structure,
          project: project
        }
      end
    end

    context 'form answer' do
      it 'gets related records for form answer' do
        subject.related_records_for(form_answer).should == {
          subject_id: "Patient123",
          secondary_id: nil,
          form_question: form_question,
          form_structure: form_structure,
          project: project
        }
      end
    end

    context 'project' do
      it 'gets related records for project' do
        subject.related_records_for(project).should == {
          project: project
        }
      end
    end

    context 'user' do
      it 'gets related records for user' do
        subject.related_records_for(user).should == {}
      end
    end

    context 'team member' do
      it 'gets related records for team member' do
        subject.related_records_for(team_member).should == {
          team_member: team_member,
          project: project
        }
      end
    end

    context 'form structure permission' do
      it 'gets related records for form structure permission' do
        subject.related_records_for(form_structure_permission).should == {
          form_structure_permission: form_structure_permission,
          team_member: team_member,
          form_structure: form_structure,
          project: project
        }
      end
    end
  end
end
