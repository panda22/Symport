describe Permissions do
  subject { described_class }
  let (:super_user) { create :user, super_user: true, email: "super@user.com", password: "Complex1" }
  let (:project) { Project.create name: "Test Project" }

  describe 'project permissions' do
    let (:user) { create :user, email: "foo@bar.com", password: "Complex1" }

    describe '.user_can_see_project?' do
      it "allows access for superusers" do
        subject.user_can_see_project?(super_user, project).should be_true
      end

      it "allows access for users in the project" do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_see_project?(user, project).should be_true
      end

      it "denies access for users not in the project" do
        subject.user_can_see_project?(user, project).should be_false
      end
    end

    describe ".user_can_rename_subject_ids_in_project?" do
      it 'allows access for superusers' do
        subject.user_can_rename_subject_ids_in_project?(super_user, project).should be_true
      end

      it 'allows access for admins' do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_rename_subject_ids_in_project?(user, project).should be_true
      end

      it 'rejects access for non-admins' do
        project.team_members << TeamMember.create!(user: user, export: true)
        project.save!
        subject.user_can_rename_subject_ids_in_project?(user, project).should be_false
      end
    end

    describe '.user_can_edit_teams_in_project?' do
      it 'allows access for superusers' do
        subject.user_can_edit_teams_in_project?(super_user, project).should be_true
      end

      it 'allows access for admins' do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_edit_teams_in_project?(user, project).should be_true
      end

      it 'rejects access for non-admins' do
        project.team_members << TeamMember.create!(user: user, export: true)
        project.save!
        subject.user_can_edit_teams_in_project?(user, project).should be_false
      end
    end

    describe '.user_can_delete_form_structure?' do
      let (:structure) { FormStructure.new project: project }
      it 'allows access for superusers' do
        subject.user_can_delete_form_structure?(super_user, structure).should be_true
      end

      it 'allows access for admins' do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_delete_form_structure?(user, structure).should be_true
      end

      it 'rejects access for non-admins' do
        project.team_members << TeamMember.create!(user: user, export: true)
        project.save!
        subject.user_can_delete_form_structure?(user, structure).should be_false
      end
    end

    describe '.user_can_edit_project_settings?' do
      it 'allows access for superusers' do
        subject.user_can_edit_project_settings?(super_user, project).should be_true
      end

      it 'allows access for admins' do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_edit_project_settings?(user, project).should be_true
      end

      it 'rejects access for non-admins' do
        project.team_members << TeamMember.create!(user: user, export: true)
        project.save!
        subject.user_can_edit_project_settings?(user, project).should be_false
      end
    end

    describe '.user_can_delete_project?' do
      it 'allows access for superusers' do
        subject.user_can_delete_project?(super_user, project).should be_true
      end

      it 'allows access for admins' do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_delete_project?(user, project).should be_true
      end

      it 'rejects access for non-admins' do
        project.team_members << TeamMember.create!(user: user, export: true)
        project.save!
        subject.user_can_delete_project?(user, project).should be_false
      end
    end

    describe '.user_can_create_forms_in_project?' do

      it 'allows access for superusers' do
        subject.user_can_create_forms_in_project?(super_user, project).should be_true
      end

      it 'allows access for admins' do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_create_forms_in_project?(user, project).should be_true
      end

      it 'allows access for create_forms permission which are not expired yet' do
        project.team_members << TeamMember.create!(user: user, form_creation: true)
        project.save!
        subject.user_can_create_forms_in_project?(user, project).should be_true
      end

      it 'rejects access for create_forms permission which already are expired' do
        project.team_members << TeamMember.create!(user: user, expiration_date: 1.day.ago, form_creation: true)
        project.save!
        subject.user_can_create_forms_in_project?(user, project).should be_false
      end

      it 'rejects access for non-admins without permission' do
        project.team_members << TeamMember.create!(user: user, export: true)
        project.save!
        subject.user_can_create_forms_in_project?(user, project).should be_false
      end

      it 'rejects access for non-team members' do
        project.team_members << TeamMember.create!(user: User.new, form_creation: true)
        project.save!
        subject.user_can_create_forms_in_project?(user, project).should be_false
      end

    end

    describe '.user_can_access_audit_log_for_project?' do

      it 'allows access for superusers' do
        subject.user_can_access_audit_log_for_project?(super_user, project).should be_true
      end

      it 'allows access for admins' do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_access_audit_log_for_project?(user, project).should be_true
      end

      it 'allows access for audit_log permission if team member is not expired' do
        project.team_members << TeamMember.create!(user: user, audit: true)
        project.save!
        subject.user_can_access_audit_log_for_project?(user, project).should be_true
      end

      it 'rejects access for audit_log permission if team member is expired' do
        project.team_members << TeamMember.create!(user: user, expiration_date: 1.day.ago, audit: true)
        project.save!
        subject.user_can_access_audit_log_for_project?(user, project).should be_false
      end

      it 'rejects access for non-admins without permission' do
        project.team_members << TeamMember.create!(user: user, export: true)
        project.save!
        subject.user_can_access_audit_log_for_project?(user, project).should be_false
      end

      it 'rejects access for non-team members' do
        project.team_members << TeamMember.create!(user: User.new, audit: true)
        project.save!
        subject.user_can_access_audit_log_for_project?(user, project).should be_false
      end

    end

    describe '.user_can_export_responses_for_project?' do

      it 'allows access for superusers' do
        subject.user_can_export_responses_for_project?(super_user, project).should be_true
      end

      it 'allows access for admins' do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_export_responses_for_project?(user, project).should be_true
      end

      it 'allows access for export permission if team member is not expired' do
        project.team_members << TeamMember.create!(user: user, export: true)
        project.save!
        subject.user_can_export_responses_for_project?(user, project).should be_true
      end

      it 'rejects access for export permission if team member is expired' do
        project.team_members << TeamMember.create!(user: user, expiration_date: 1.day.ago, export: true)
        project.save!
        subject.user_can_export_responses_for_project?(user, project).should be_false
      end

      it 'rejects access for non-admins without permission' do
        project.team_members << TeamMember.create!(user: user, form_creation: true)
        project.save!
        subject.user_can_export_responses_for_project?(user, project).should be_false
      end

      it 'rejects access for non-team members' do
        project.team_members << TeamMember.create!(user: User.new, form_creation: true)
        project.save!
        subject.user_can_export_responses_for_project?(user, project).should be_false
      end
    end

    describe '.user_can_view_personally_identifiable_answers_for_project?' do

      it 'allows access for superusers' do
        subject.user_can_view_personally_identifiable_answers_for_project?(super_user, project).should be_true
      end

      it 'allows access for admins' do
        project.team_members << TeamMember.create!(user: user, administrator: true)
        project.save!
        subject.user_can_view_personally_identifiable_answers_for_project?(user, project).should be_true
      end

      it 'allows access for view_personally_identifiable_answers permission if the team member is not expired' do
        project.team_members << TeamMember.create!(user: user, view_personally_identifiable_answers: true)
        project.save!
        subject.user_can_view_personally_identifiable_answers_for_project?(user, project).should be_true
      end

      it 'rejects access for view_personally_identifiable_answers permission if the team member is expired' do
        project.team_members << TeamMember.create!(user: user, expiration_date: 1.day.ago, view_personally_identifiable_answers: true)
        project.save!
        subject.user_can_view_personally_identifiable_answers_for_project?(user, project).should be_false
      end

      it 'rejects access for non-admins without permission' do
        project.team_members << TeamMember.create!(user: user, export: true)
        project.save!
        subject.user_can_view_personally_identifiable_answers_for_project?(user, project).should be_false
      end

      it 'rejects access for non-team members' do
        project.team_members << TeamMember.create!(user: User.new, form_creation: true)
        project.save!
        subject.user_can_view_personally_identifiable_answers_for_project?(user, project).should be_false
      end
    end
  end

  describe 'form structure permissions' do
    let (:form_structure) { FormStructure.create name: "Test Form", project: project }
    let (:admin_user) {
      user = create :user, email: "foo@bar.com", password: "Complex1"
      team_member = TeamMember.create! user: user, project: project, administrator: true
      user
    }
    let (:full_user) {
      user = create :user, email: "foo@bar.com", password: "Complex1"
      team_member = TeamMember.create! user: user, project: project
      form_structure.form_structure_permissions << FormStructurePermission.create!(team_member: team_member, permission_level: "Full")
      form_structure.save!
      user
    }
    let (:readwrite_user) {
      user = create :user, email: "foo2@bar.com", password: "Complex1"
      team_member = TeamMember.create! user: user, project: project
      form_structure.form_structure_permissions << FormStructurePermission.create!(team_member: team_member, permission_level: "Read/Write")
      form_structure.save!
      user
    }
    let (:read_user) {
      user = create :user, email: "foo3@bar.com", password: "Complex1"
      team_member = TeamMember.create! user: user, project: project
      form_structure.form_structure_permissions << FormStructurePermission.create!(team_member: team_member, permission_level: "Read")
      form_structure.save!
      user
    }
    let(:full_expired_user) {
      user = create :user, email: "foo4@bar.com", password: "Complex1"
      team_member = TeamMember.create! user: user, project: project, expiration_date: 1.day.ago
      form_structure.form_structure_permissions << FormStructurePermission.create!(team_member: team_member, permission_level: "Full")
      form_structure.save!
      user
    }

    describe '.user_can_edit_form_structure?' do

      context 'grants access' do
        it 'allows access to superusers' do
          subject.user_can_edit_form_structure?(super_user, form_structure).should be_true
        end

        it 'allows access for admins' do
          subject.user_can_edit_form_structure?(admin_user, form_structure).should be_true
        end

        it 'allows access for "Full" permissions if user is not expired' do
          subject.user_can_edit_form_structure?(full_user, form_structure).should be_true
        end
      end

      context "denies access" do
        it 'rejects access for "Read/Write" permissions' do
          subject.user_can_edit_form_structure?(readwrite_user, form_structure).should be_false
        end

        it 'rejects access for "Read" permissions' do
          subject.user_can_edit_form_structure?(read_user, form_structure).should be_false
        end

        it 'rejects access when no specific permissions are set' do
          subject.user_can_edit_form_structure?(User.new, form_structure).should be_false
        end

        it 'rejects access when the team member is expired even if he has full permission' do
          subject.user_can_edit_form_structure?(full_expired_user, form_structure).should be_false
        end
      end
    end

    describe '.user_can_enter_form_responses_for_form_structure?' do

      context "grants access" do
        it 'allows access for superusers' do
          subject.user_can_enter_form_responses_for_form_structure?(super_user, form_structure).should be_true
        end

        it 'allows access for admins' do
          subject.user_can_enter_form_responses_for_form_structure?(admin_user, form_structure).should be_true
        end

        it 'allows access for "Full" permissions' do
          subject.user_can_enter_form_responses_for_form_structure?(full_user, form_structure).should be_true
        end

        it 'allows access for "Read/Write" permissions' do
          subject.user_can_enter_form_responses_for_form_structure?(readwrite_user, form_structure).should be_true
        end
      end

      context "denies access" do
        it 'rejects access for "Read" permissions' do
          subject.user_can_enter_form_responses_for_form_structure?(read_user, form_structure).should be_false
        end

        it 'rejects access when no specific permissions are set' do
          subject.user_can_enter_form_responses_for_form_structure?(User.new, form_structure).should be_false
        end

        it 'rejects access when the team member is expired even if he has full permission' do
          subject.user_can_enter_form_responses_for_form_structure?(full_expired_user, form_structure).should be_false
        end
      end

    end

    describe '.user_can_delete_form_responses_for_form_structure?' do

      context "grants access" do
        it 'allows access for superusers' do
          subject.user_can_delete_form_responses_for_form_structure?(super_user, form_structure).should be_true
        end

        it 'allows access for admins' do
          subject.user_can_delete_form_responses_for_form_structure?(admin_user, form_structure).should be_true
        end
      end

      context "denies access" do
        it 'allows access for "Full" permissions' do
          subject.user_can_delete_form_responses_for_form_structure?(full_user, form_structure).should be_true
        end

        it 'allows access for "Read/Write" permissions' do
          subject.user_can_delete_form_responses_for_form_structure?(readwrite_user, form_structure).should be_true
        end

        it 'rejects access for "Read" permissions' do
          subject.user_can_delete_form_responses_for_form_structure?(read_user, form_structure).should be_false
        end

        it 'rejects access when no specific permissions are set' do
          subject.user_can_delete_form_responses_for_form_structure?(User.new, form_structure).should be_false
        end

        it 'rejects access when the team member is expired even if he has full permission' do
          subject.user_can_delete_form_responses_for_form_structure?(full_expired_user, form_structure).should be_false
        end
      end
    end

    describe '.user_can_view_form_responses_for_form_structure?' do

      context "grants access" do
        it 'allows access for superusers' do
          subject.user_can_view_form_responses_for_form_structure?(super_user, form_structure).should be_true
        end

        it 'allows access for admins' do
          subject.user_can_view_form_responses_for_form_structure?(admin_user, form_structure).should be_true
        end

        it 'allows access for "Full" permissions' do
          subject.user_can_view_form_responses_for_form_structure?(full_user, form_structure).should be_true
        end

        it 'allows access for "Read/Write" permissions' do
          subject.user_can_view_form_responses_for_form_structure?(readwrite_user, form_structure).should be_true
        end

        it 'allows access for "Read" permissions' do
          subject.user_can_view_form_responses_for_form_structure?(read_user, form_structure).should be_true
        end
      end

      context "denies access" do
        it 'rejects access when no specific permissions are set' do
          subject.user_can_view_form_responses_for_form_structure?(User.new, form_structure).should be_false
        end

        it 'rejects access when the team member is expired even if he has full permission' do
          subject.user_can_view_form_responses_for_form_structure?(full_expired_user, form_structure).should be_false
        end
      end


    end

    describe '.user_can_see_form_structure?' do

      context "grants access" do
        it 'allows access for superusers' do
          subject.user_can_see_form_structure?(super_user, form_structure).should be_true
        end

        it 'allows access for admins' do
          subject.user_can_see_form_structure?(admin_user, form_structure).should be_true
        end

        it 'allows access for "Full" permissions' do
          subject.user_can_see_form_structure?(full_user, form_structure).should be_true
        end

        it 'allows access for "Read/Write" permissions' do
          subject.user_can_see_form_structure?(readwrite_user, form_structure).should be_true
        end

        it 'allows access for "Read" permissions' do
          subject.user_can_see_form_structure?(read_user, form_structure).should be_true
        end
      end

      context "denies access" do
        it 'rejects access when no specific permissions are set' do
          subject.user_can_see_form_structure?(User.new, form_structure).should be_false
        end

        it 'rejects access when the team member is expired even if he has full permission' do
          subject.user_can_see_form_structure?(full_expired_user, form_structure).should be_false
        end
      end
    end

  end

end
