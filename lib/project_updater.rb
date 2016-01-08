class ProjectUpdater
  class << self
    def update(updated_attrs, current_user, project)
      if !Permissions.user_can_edit_project_settings? current_user, project
        raise PayloadException.access_denied "You do not have permissions to update this project"
      end

      AuditLogger.surround_edit(current_user, project) do
        project.name = updated_attrs['name'].try(:strip)
        project.attribution = updated_attrs['attribution'].try(:strip)
        project.save!
      end

      project
    end

    def rename_subject_id(current_user, project, old_subject_id, new_subject_id)
      if !Permissions.user_can_rename_subject_ids_in_project? current_user, project
        raise PayloadException.access_denied "You do not have permission to rename Subject IDs"
      end

      if SubjectLookup.project_contains_subject_id? project, new_subject_id
        raise PayloadException.validation_error subject_id: "This subject ID is already in use"
      end

      project.form_responses.where(subject_id: old_subject_id).update_all(subject_id: new_subject_id)

      AuditLogger.record_entry(current_user, project, "edit",
        old_data: {subject_id: old_subject_id},
        data: {subject_id: new_subject_id}
      )
    end
  end
end
