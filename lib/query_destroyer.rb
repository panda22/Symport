class QueryDestroyer
  class << self
    def destroy(query, user)
      unless Permissions.user_can_delete_query?(user, query)
        raise PayloadException.access_denied "invalid query request"
      end
      query.query_params.destroy_all
      query.query_form_structures.destroy_all
      query.destroy!
    end
  end
end