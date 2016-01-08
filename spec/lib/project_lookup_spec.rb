describe ProjectLookup do
  subject { described_class }

  before do
    Permissions.stubs(:user_can_see_project?).returns(true)
  end

  let(:current_user) { User.new }

  describe '.find_project' do
    it "returns a project" do
      project = Project.create(name: "whatever")
      subject.find_project(current_user, project.id).should == project
    end

    it "denies access if you are not on the project" do
      project = Project.create(name: "whatever")
      Permissions.expects(:user_can_see_project?).with(current_user, project).returns false
      expect {
        subject.find_project(current_user, project.id)
      }.to raise_error PayloadException
    end
  end

  describe ".find_projects_for_user" do
    let (:regular_user_1) { create :user, email: "any@where.com", password: "Complex1" }
    let (:regular_user_2) { create :user, email: "any2@where.com", password: "Complex1" }
    let (:super_user) { create :user, email: "su@where.com", password: "Complex1", super_user: true}
    let (:project_1) { Project.create name: "first" }
    let (:project_2) { Project.create name: "second" }
    let (:project_3) { Project.create name: "third" }
    let (:project_4) { Project.create name: "fourth" }

    before do
      TeamMember.create project: project_1, user: regular_user_1, administrator: true
      TeamMember.create project: project_1, user: regular_user_2, administrator: true
      TeamMember.create project: project_1, user: super_user, administrator: true
      TeamMember.create project: project_2, user: regular_user_1, administrator: true
      TeamMember.create project: project_2, user: regular_user_2, administrator: true
      TeamMember.create project: project_3, user: regular_user_1, administrator: true
      TeamMember.create project: project_3, user: super_user, administrator: true
      TeamMember.create project: project_4, user: regular_user_2, administrator: true
    end

    it "returns projects with user on the team" do
      subject.find_projects_for_user(regular_user_1).should =~ [ project_1, project_2, project_3 ]
      subject.find_projects_for_user(regular_user_2).should =~ [ project_1, project_2, project_4 ]
    end

    it "returns all projects for super users" do
      subject.find_projects_for_user(super_user).should =~ [ project_1, project_2, project_3, project_4 ]
    end

    it "returns nothing for no user" do
      subject.find_projects_for_user(nil).should be_empty
    end
  end

  describe '.find_team_member' do
    it 'finds a team member based on id' do
      project = Project.create! name: "Test Proj"
      user = create :user, email: "foo@bar.com", password: "Complex1"
      team_member = TeamMember.create! user: user, project: project
      subject.find_team_member(current_user, team_member.id).should == team_member
    end

    it "denies access if you are not on the team member's project" do
      project = Project.create! name: "Test Proj"
      user = create :user, email: "foo@bar.com", password: "Complex1"
      team_member = TeamMember.create! user: user, project: project
      Permissions.expects(:user_can_see_project?).with(current_user, project).returns(false)
      expect {
        subject.find_team_member(current_user, team_member.id)
      }.to raise_error PayloadException
    end
  end
end
