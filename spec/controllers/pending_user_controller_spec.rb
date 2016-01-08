require 'spec_helper'

describe PendingUserController do
  let (:user) { User.new(id: SecureRandom.uuid) }
  let (:pending_user) { PendingUser.new(id: SecureRandom.uuid) }
  let (:response_json) { {hello: "everyone"} }

  before do
    user
    pending_user
    MailSender.stubs(:send).returns(true)
    MailSender.stubs(:send).returns(true)
  end

  describe "#sign_in" do

    it "signs in a valid pending user" do
      pending_user.expires = DateTime.now + 2.days
      PendingUser.expects(:find_by).with(:id => pending_user.id, :user_id => user.id).returns(pending_user)
      User.expects(:find).with(user.id).returns(user)
      UserSerializer.expects(:serialize).with(user).returns(response_json)
      get :sign_in, user_id: user.id, id: pending_user.id
      response.should be_success
      response.body.should == {user: response_json, id: pending_user.id}.to_json
    end

    it "raises an error if pending_user cannot be found" do
      PendingUser.expects(:find_by).with(:id => pending_user.id, :user_id => user.id).returns(nil)
      get :sign_in, user_id: user.id, id: pending_user.id
      response.should_not be_success
      response.body.should == {message: "invalid invite request"}.to_json
    end

    it "sets the user to null if pending user is expired" do
      pending_user.expires = DateTime.now - 2.days
      PendingUser.expects(:find_by).with(:id => pending_user.id, :user_id => user.id).returns(pending_user)
      get :sign_in, user_id: user.id, id: pending_user.id
      response.should be_success
      response.body.should == {user: nil, id: pending_user.id}.to_json
    end
  end

  describe "#validate" do
    let (:user_info) { {created_at: Time.now.utc.to_s, first_name: "hi", last_name: "bye", password: "StrongPass1", password_confirmation: "StrongPass1", phone_number: "1234567890"} }
    let (:camelized_info) { {firstName: "hi", lastName: "bye", password: "StrongPass1", passwordConfirmation: "StrongPass1", phoneNumber: "1234567890"} }

    it "creates a session and returns user" do
      pending_user.expires = DateTime.now + 2.days
      token = SessionToken.new(id: SecureRandom.uuid)
      PendingUser.expects(:find_by).with(:id => pending_user.id, :user_id => user.id).returns(pending_user)
      User.expects(:find).with(user.id).returns(user)
      user.expects(:update_attributes!).with(user_info).returns(user)
      PendingUser.expects(:where).with(:user_id => user.id).returns([])
      SessionTokenTools.expects(:create_token).with(user).returns(token)
      UserSerializer.expects(:serialize).with(user).returns(response_json)
      post :validate, user_id: user.id, id: pending_user.id, user_info: camelized_info
      response.should be_success
      response.body.should == {sessionToken: token.id, user: response_json}.to_json
    end

    it "raises an error if pending user is not found" do
      PendingUser.expects(:find_by).with(:id => pending_user.id, :user_id => user.id).returns(nil)
      User.expects(:find).with(user.id).returns(user)
      post :validate, user_id: user.id, id: pending_user.id, user_info: camelized_info
      response.should_not be_success
      response.body.should == {message: "invalid invite request"}.to_json
    end

    it "raises an error if user is not found" do
      PendingUser.expects(:find_by).with(:id => pending_user.id, :user_id => user.id).returns(pending_user)
      User.expects(:find).with(user.id).returns(nil)
      post :validate, user_id: user.id, id: pending_user.id, user_info: camelized_info
      response.should_not be_success
      response.body.should == {message: "invalid invite request"}.to_json
    end
  end

  describe "#resend" do
    let (:email) { "2@2.com" }
    let (:project) { Project.new(id: SecureRandom.uuid) }
    let (:team_member) { TeamMember.new(id: SecureRandom.uuid, project_id: project.id) }
    let (:first_name) { "a" }
    let (:last_name) { "b" }
    let (:message) { "welcome" }

    before do
      sign_in
      project
      team_member
      user.email = email

    end
    it "resends emails for a valid pending user" do
      User.expects(:find_by).with(:email => email).returns(user)
      PendingUser.expects(:find_by).with(:user_id => user.id, :team_member_id => team_member.id).returns(pending_user)
      user.expects(:update_attributes!).with(first_name: first_name, last_name: last_name).returns(user)
      pending_user.expects(:save!).returns(pending_user)
      TeamMember.expects(:find_by).with(:id => team_member.id).returns(team_member)
      Project.expects(:find_by).with(:id => team_member.project_id).returns(project)
      post :resend, user_email: email, teamMemberID: team_member.id, firstName: first_name, lastName: last_name, message: message
      response.should be_success
      response.body.should == {success: true}.to_json
    end

    it "raises an error if pending user is not found" do
      User.expects(:find_by).with(:email => email).returns(user)
      PendingUser.expects(:find_by).with(:user_id => user.id, :team_member_id => team_member.id).returns(nil)
      post :resend, user_email: email, teamMemberID: team_member.id, firstName: first_name, lastName: last_name, message: message
      response.should_not be_success
      response.body.should == {message: "pending user does not exist"}.to_json
    end

    it "raises an error if pending user is not found" do
      User.expects(:find_by).with(:email => email).returns(nil)
      post :resend, user_email: email, teamMemberID: team_member.id, firstName: first_name, lastName: last_name, message: message
      response.should_not be_success
      response.body.should == {message: "pending user is not a user"}.to_json
    end
  end

  describe "#get_from_team_member" do
    let (:email) { "2@2.com" }
    let (:team_member) { TeamMember.new(id: SecureRandom.uuid) }

    before do
      sign_in
      user.email = email
      user.first_name = "a"
      user.last_name = "b"
      pending_user.message = "welcome"
      pending_user.team_member_id = team_member.id
    end

    it "gets the requested pending user for the team member" do
      team_member.administrator = true
      User.expects(:find_by).with(:email => user.email).returns(user)
      TeamMember.expects(:find_by).returns(team_member)
      PendingUser.expects(:find_by).with(:user_id => user.id, :team_member_id => team_member.id).returns(pending_user)
      post :get_from_team_member, email: email, team_member_id: team_member.id
      response.should be_success
      response.body.should == {
          firstName: user.first_name,
          lastName: user.last_name,
          message: pending_user.message,
          email: user.email,
          teamMemberID: team_member.id
      }.to_json
    end

    it "raises an error if inviting team member is not administrator" do
      team_member.administrator = false
      User.expects(:find_by).with(:email => user.email).returns(user)
      TeamMember.expects(:find_by).returns(team_member)
      post :get_from_team_member, email: email, team_member_id: team_member.id
      response.should_not be_success
      response.body.should == {message: "inviting member does not have permission to invite"}.to_json
    end

    it "raises an error if inviting team member is not found" do
      team_member.administrator = true
      User.expects(:find_by).with(:email => user.email).returns(user)
      TeamMember.expects(:find_by).returns(nil)
      post :get_from_team_member, email: email, team_member_id: team_member.id
      response.should_not be_success
      response.body.should == {message: "inviting member does not have permission to invite"}.to_json
    end

    it "raises an error if user_for_invite is null" do
      team_member.administrator = true
      User.expects(:find_by).with(:email => user.email).returns(nil)
      post :get_from_team_member, email: email, team_member_id: team_member.id
      response.should_not be_success
      response.body.should == {message: "pending user is not a user"}.to_json
    end

    it "creates a new PendingUser if one does not exist" do
      team_member.administrator = true
      User.expects(:find_by).with(:email => user.email).returns(user)
      TeamMember.expects(:find_by).returns(team_member)
      PendingUser.expects(:find_by).with(:user_id => user.id, :team_member_id => team_member.id).returns(nil)
      PendingUser.expects(:create!).returns(pending_user)
      pending_user.expects(:save!).returns(true)
      post :get_from_team_member, email: email, team_member_id: team_member.id
      response.should be_success
      response.body.should == {
          firstName: user.first_name,
          lastName: user.last_name,
          message: pending_user.message,
          email: user.email,
          teamMemberID: team_member.id
      }.to_json
    end
  end

  describe "#create_as_team_member" do
    let (:first_name) { "a" }
    let (:last_name) { "b" }
    let (:email) { "2@2.com" }
    let (:project) { Project.new(id: SecureRandom.uuid) }
    let (:team_member) { TeamMember.new(id: SecureRandom.uuid, project_id: project.id) }
    let (:team_member_data) { {} }
    let (:message) { "welcome" }

    before do
      sign_in
      project
      team_member
      pending_user.message = "welcome"
      pending_user.team_member_id = team_member.id
      team_member_data["email"] = email
    end

    it "creates a PendingUser as a TeamMember" do
      TeamMember.expects(:find_by).with(:user_id => controller.current_user.id, :project_id => project.id).returns(team_member)
      User.expects(:create).returns(user)
      Project.expects(:find_by).with(:id => project.id).returns(project)
      PendingUserUpdater.expects(:create_temp).returns(pending_user)
      TeamMemberCreator.expects(:create).with(team_member_data, controller.current_user, project).returns(team_member)
      team_member.expects(:save!).returns(true)
      TeamMemberSerializer.expects(:serialize).returns(response_json)
      post(:create_as_team_member,
           project_id: project.id,
           first_name: first_name,
           last_name: last_name,
           team_member: team_member_data,
           message: message)
      response.should be_success
      response.body.should == {success: true, team_member: response_json}.to_json
    end

    it "raises an error if first_name is empty string" do
      post(:create_as_team_member,
           project_id: project.id,
           first_name: "",
           last_name: last_name,
           team_member: team_member_data,
           message: message)
      response.should_not be_success
      response.body.should == {validations: {firstName: "Please enter a first name"} }.to_json
    end

    it "recovers a previously deleted user" do
      user.update_attributes!(
              first_name: first_name,
              last_name: last_name,
              phone_number: "1234567890",
              password: "StrongPass1",
              email: email,
              deleted_at: DateTime.now
      )
      TeamMember.expects(:find_by).with(:user_id => controller.current_user.id, :project_id => project.id).returns(team_member)
      Project.expects(:find_by).with(:id => project.id).returns(project)
      PendingUserUpdater.expects(:create_temp).returns(pending_user)
      TeamMemberCreator.expects(:create).with(team_member_data, controller.current_user, project).returns(team_member)
      team_member.expects(:save!).returns(true)
      TeamMemberSerializer.expects(:serialize).returns(response_json)
      post(:create_as_team_member,
           project_id: project.id,
           first_name: first_name,
           last_name: last_name,
           team_member: team_member_data,
           message: message)
      response.should be_success
      response.body.should == {success: true, team_member: response_json}.to_json
    end
  end
end

