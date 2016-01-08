class FormStructureUpdater
  class << self
    def update(user, structure_record, data)
      default_secondary_id = "1"

      if !Permissions.user_can_edit_form_structure?(user, structure_record)
        raise PayloadException.access_denied "You do not have permission to update this form"
      end
      responses_to_save = []
      max_num_secondary_id_tries = 10
      index = 1
      while structure_record.valid? == false and structure_record.errors.messages.has_key?(:secondary_id)
        structure_record.secondary_id += " (copy)"
        if index == max_num_secondary_id_tries
          structure_record.secondary_id = "Secondary ID (#{SecureRandom.urlsafe_base64})"
        end
        index += 1
      end
      num_instances = FormResponseLookup::get_max_instances_in_form(structure_record.id)
      old_structure = structure_record.dup
      if old_structure.is_many_to_one == true and data[:isManyToOne] == false
        QueryChangeUpdater.update_from_secondary_id_change(structure_record)
        responses = FormResponse.where(:form_structure_id => structure_record.id)
        if num_instances > 1
          raise PayloadException.validation_error({
            isManyToOne: "This form cannot be converted because there are subjects with multiple #{structure_record.secondary_id}"
            })
        end
        responses_to_save = responses.map do |response|
          response.secondary_id = nil
          response
        end
      end
      AuditLogger.surround_edit(user, structure_record) do
        structure_record.update_attributes!(
          name: data[:name].try(:strip),
          is_many_to_one: data[:isManyToOne],
          secondary_id: data[:secondaryId].try(:strip),
          is_secondary_id_sorted: data[:isSecondaryIdSorted],
          description: data[:description]
        )
      end
      if old_structure.is_many_to_one == false and data[:isManyToOne] == true
        if num_instances > 0
          responses = FormResponse.where(:form_structure_id => structure_record.id)
          responses.each do |response|
            response.secondary_id = default_secondary_id
            response.save!
          end
          raise PayloadException.validation_error({
            isManyToOne: "form has existing responses and no default name"
          })
        end

      end
      responses_to_save.each do |response|
        response.save!
      end
      structure_record
    end
  end
end
