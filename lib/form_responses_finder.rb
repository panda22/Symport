class FormResponsesFinder
  class << self
    def find(user, structure_record, page_number, subject_id)
      if !Permissions.user_can_view_form_responses_for_form_structure?(user, structure_record)
        raise PayloadException.access_denied "You do not have access to view responses for this form"
      end
      responses = structure_record.form_responses
      if subject_id.present?
        responses = responses.where("subject_id LIKE :prefix and instance_number=0", prefix: "#{subject_id}%")
      end
      if Integer(page_number) == -1 #set page number to -1 to get all records and not paginate server side
        records = responses
        AuditLogger.view user, structure_record # TODO indicate that this is the responses grid?
        return [records, 1, 1]
      else
        records = responses.order('created_at').page(page_number)
      end

      AuditLogger.view user, structure_record # TODO indicate that this is the responses grid?
      [records, records.current_page.to_i, records.total_pages]
    end
  end
end
