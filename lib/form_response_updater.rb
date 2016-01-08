class FormResponseUpdater
  class << self
    def update(user, response_record, data)
      structure = response_record.form_structure
      if !Permissions.user_can_enter_form_responses_for_form_structure?(user, structure)
        raise PayloadException.access_denied "You do not have access to edit responses for this form"
      end
      FormResponseAnswersUpdater.update(user, response_record, data[:answers])
      unless ENV["RAILS_ENV"] == "test"
        response_record.touch
      end
      if structure.is_many_to_one and structure.is_secondary_id_sorted
        FormResponseOrderer.order(response_record)
      end
      response_record
    end

    def get_errors(user, response_record, data)
      FormResponseAnswersUpdater.get_errors(user, response_record, data[:answers])
      response_record
    end

  end
end
