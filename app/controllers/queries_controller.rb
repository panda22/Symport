class QueriesController < ApplicationController
  def create
    do_update
  end

  def update
    do_update
  end

  def destroy
    query_record = Query.find(params[:id])
    QueryDestroyer.destroy(query_record, current_user)
    render json: {:success => true}
  end

  def show
    query_record = Query.find(params[:id])
    unless Permissions.user_can_view_query?(current_user, query_record)
      raise PayloadException.access_denied "invalid query request"
    end
    render json: QuerySerializer.serialize(query_record, current_user)
  end

  def get_all_queries
    project = Project.find(params[:project_id])
    unless Permissions.user_can_see_project?(current_user, project)
      raise PayloadException.access_denied "you do not have access to this project"
    end
    order_type = params[:order]
    query_records = Query.where(:project_id => params[:project_id])
    query_records = QueryOrderer.order(query_records, order_type)
    viewable_queries = []
    param_errors = []
    query_records.each do |query_record|
      unless Permissions.user_can_view_query?(current_user, query_record)
        next
      end
      #errors = QueryValidator.validate
      viewable_queries.push(QuerySerializer.serialize(query_record, current_user))
      param_errors.push(QueryValidator.get_errors(query_record))
    end
    render json: {queries: viewable_queries,
                  paramErrors: param_errors}
  end

  def edit_permissions
    query_info = params[:query]
    query = Query.find(query_info[:id])
    query_record = nil
    (query_info[:isShared] != query.is_shared) ?
        query_record = QueryUpdater.update_permissions(query_info, current_user) :
        query_record = QueryUpdater.update_name(query_info, current_user)
    result = QuerySerializer.serialize(query_record, current_user)
    render json: result
  end

  def validate
    query_info = params[:query]
    project_id = params[:project_id]
    QueryValidator.validate(query_info, project_id, current_user)
    render json: {result: true}
  end

  private
  def do_update
    query_info = params[:query]
    project = Project.find(query_info[:projectID])
    QueryValidator.validate(query_info, project.id, current_user)
    unless Permissions.user_can_see_project?(current_user, project)
      raise PayloadException.access_denied "you do not have access to this project"
    end
    updated_query = QueryUpdater.update(query_info, project, current_user)
    render json: QuerySerializer.serialize(updated_query, current_user)
  end
end

