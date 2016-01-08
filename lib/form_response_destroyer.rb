class FormResponseDestroyer
  class << self
    def destroy(user, response)
      if !Permissions.user_can_delete_form_responses_for_form_structure?(user, response.form_structure)
        raise PayloadException.access_denied "You do not have permission to delete responses for this form"
      end
      response.form_answers.each(&:destroy)
      response.destroy
      AuditLogger.remove user, response
    end
  end
end
