describe QueriesController do

  let (:project) { Project.new(id: SecureRandom.uuid) }
  let (:query_info) { {name: "abcde", projectID: project.id}.stringify_keys! }
  let (:query) { Query.new }
  let (:output) { {hello: "world"} }
  let (:order) { "a-z" }

  before do
    sign_in
    @user = controller.current_user
    @user.id = SecureRandom.uuid
  end

  describe "#create" do
    it "creates a new query" do
      do_update
    end

    it "raises an error if user does not have permission to view project" do
      do_update_error
    end
  end

  describe "#update" do
    it "updates a query" do
      do_update(false)
    end

    it "raises an error if user does not have permission to view project" do
      do_update_error(false)
    end
  end

  describe "#destroy" do
    it "calls destroyer on a query" do
      query_id = SecureRandom.uuid
      Query.expects(:find).with(query_id).returns(query)
      QueryDestroyer.expects(:destroy).with(query, @user)
      delete :destroy, id: query_id
      response.should be_success
      response.body.should == {:success => true}.to_json
    end
  end

  describe "#show" do
    it "gets a query" do
      query_id = SecureRandom.uuid
      Query.expects(:find).with(query_id).returns(query)
      Permissions.expects(:user_can_view_query?).with(@user, query).returns true
      QuerySerializer.expects(:serialize).with(query, @user).returns(output)
      get :show, id: query_id
      response.should be_success
      response.body.should == output.to_json
    end

    it "raises an error if user does not have permissions to view query" do
      query_id = SecureRandom.uuid
      Query.expects(:find).with(query_id).returns(query)
      Permissions.expects(:user_can_view_query?).with(@user, query).returns false
      get :show, id: query_id
      response.should_not be_success
      response.body.should == {message: "invalid query request"}.to_json
    end
  end

  describe "#get_all_queries" do
    it "gets all valid queries for the user" do
      Project.expects(:find).with(project.id).returns(project)
      Permissions.expects(:user_can_see_project?).with(@user, project).returns(true)
      QueryOrderer.expects(:order).with([], order).returns([query])
      Permissions.expects(:user_can_view_query?).with(@user, query).returns(true)
      QuerySerializer.expects(:serialize).with(query, @user).returns(output)
      QueryValidator.expects(:get_errors).with(query).returns({})
      get :get_all_queries, project_id: project.id, order: order
      response.should be_success
      response.body.should == {queries: [output], paramErrors: [{}]}.to_json
    end

    it "raises an error if user cannot view project" do
      Project.expects(:find).with(project.id).returns(project)
      Permissions.expects(:user_can_see_project?).with(@user, project).returns(false)
      get :get_all_queries, project_id: project.id, order: order
      response.should_not be_success
      response.body.should == {message: "you do not have access to this project"}.to_json
    end

    it "blocks a query if user cannot view it" do
      other_query = Query.new
      Project.expects(:find).with(project.id).returns(project)
      Permissions.expects(:user_can_see_project?).with(@user, project).returns(true)
      QueryOrderer.expects(:order).with([], order).returns([query, other_query])
      Permissions.expects(:user_can_view_query?).with(@user, query).returns(false)
      Permissions.expects(:user_can_view_query?).with(@user, other_query).returns(true)
      QuerySerializer.expects(:serialize).with(other_query, @user).returns(output)
      QueryValidator.expects(:get_errors).with(other_query).returns({})
      get :get_all_queries, project_id: project.id, order: order
      response.should be_success
      response.body.should == {queries: [output], paramErrors: [{}]}.to_json
    end
  end

  private
  def do_update(is_create = true)
    Project.expects(:find).with(project.id).returns(project)
    QueryValidator.expects(:validate).with(query_info, project.id, @user).returns(nil)
    Permissions.expects(:user_can_see_project?).with(@user, project).returns(true)
    QueryUpdater.expects(:update).with(query_info, project, @user).returns(query)
    QuerySerializer.expects(:serialize).with(query, @user).returns(output)
    if is_create
      post :create, query: query_info, format: :json
    else
      put :update, id: SecureRandom.uuid, query: query_info, format: :json
    end
    response.should be_success
    response.body.should == output.to_json
  end

  def do_update_error(is_create = true)
    Project.expects(:find).with(project.id).returns(project)
    QueryValidator.expects(:validate).with(query_info, project.id, @user).returns(nil)
    Permissions.expects(:user_can_see_project?).with(@user, project).returns(false)
    if is_create
      post :create, query: query_info, format: :json
    else
      put :update, id: SecureRandom.uuid, query: query_info, format: :json
    end
    response.should_not be_success
    response.body.should == {message: "you do not have access to this project"}.to_json
  end

end