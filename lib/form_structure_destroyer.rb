class FormStructureDestroyer
  class << self
    def destroy(user, structure)
      if !Permissions.user_can_delete_form_structure?(user, structure)
        raise PayloadException.access_denied "You do not have permission to delete this form"
      end
      QueryChangeUpdater.update_from_form_structure(structure, true)
      structure.form_responses.each do |response| FormResponseDestroyer.destroy user, response end
      structure.form_questions.each(&:destroy) # NOTE do not call FormQuestionDestroyer, it does a bunch of extra stuff
      structure.destroy
      AuditLogger.remove(user, structure)
    end
  end
end
