class SubjectLookup
  class << self

    def known_subjects_of_project(project)
      project.form_responses.pluck 'DISTINCT subject_id'# :subject_id
    end

    def project_contains_subject_id?(project, subject_id)
      project.form_responses.where(subject_id: subject_id).count > 0
    end

  end
end
