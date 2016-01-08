class ProjectGridLookup
  class << self

    def get_project_rs(proj_id)
      project = Project.includes(:form_structures).
        includes(:form_questions).
        includes(:option_configs).
        where("projects.id=?", proj_id).
        first
      if project.form_structures.length == 0
        no_data_error = "form"
      elsif project.form_questions.length == 0
        no_data_error = "question"
      end
      return project, no_data_error
    end

    def get_max_instances_by_form(proj_id)
      sql = "select max(subject_count), form_id from " +
              "(select count(*) as subject_count, f.id as form_id, r.subject_id " +
              "from form_structures f, form_responses r " +
              "where f.project_id=" + ActiveRecord::Base::sanitize(proj_id) +
              " and r.form_structure_id=f.id and f.is_many_to_one=true " +
              "and r.deleted_at is null " +
              "and f.deleted_at is null " +
              "group by f.id, r.subject_id) " +
              "as form_counts " +
            "group by form_counts.form_id"
      rs = ActiveRecord::Base.connection.execute(sql).values
      instances = {}
      rs.each do |tuple|
        form_id = tuple[1]
        num_instances_str = tuple[0]
        instances[form_id] = num_instances_str.to_i
      end
      instances
    end

    def get_secondary_id_names_by_form(proj_id)
      sql = "select f.id, r.secondary_id from " +
            "form_structures f, form_responses r " +
            "where f.id=r.form_structure_id and f.is_many_to_one=true " +
            "and f.project_id = " + ActiveRecord::Base::sanitize(proj_id) +
            "and f.deleted_at is null and r.deleted_at is null"
      rs = ActiveRecord::Base.connection.execute(sql).values
      names = {}
      rs.each do |tuple|
        form_id = tuple[0]
        secondary_id = tuple[1]
        unless names.has_key?(form_id)
          names[form_id] = []
        end
        names[form_id].push(secondary_id)
      end
      names
    end

    def get_team_member_rs(proj_id, user)
      rs = TeamMember.where("project_id=? and user_id=?", proj_id, user.id).first
      if rs == nil
        raise PayloadException.access_denied "user is not a valid team member"
      end
      rs
    end

    def get_form_permission_rs(proj_id, user)
      join_string = "inner join team_members on team_members.project_id=" +
        ActiveRecord::Base::sanitize(proj_id) +
        " and team_members.user_id='#{user.id}'"
      result = FormStructurePermission.where("form_structures.project_id=?", proj_id).
        joins("inner join form_structures on form_structures.id = form_structure_permissions.form_structure_id").
        joins(join_string)
      result
    end

    def get_form_responses_rs(proj_id)
      # TODO: add error_msg to result set
      sql = <<-SQL
        SELECT r.id AS response_id, a.answer AS answer, r.subject_id AS subject_id,
          f.id AS form_id, r.instance_number AS instance_number, r.secondary_id as secondary_id,
          r.created_at AS response_created_at, r.updated_at AS response_updated_at,
          a.form_question_id AS question_id, a.regular_exception AS regular_exception,
          a.year_exception AS year_exception, a.month_exception AS month_exception,
          a.day_exception AS day_exception, a.error_msg AS error_message
        FROM form_answers a, form_responses r, form_structures f
        WHERE (
          a.form_response_id=r.id AND
          r.form_structure_id=f.id AND
          f.project_id='#{proj_id}' AND
          a.deleted_at IS NULL AND
          r.deleted_at IS NULL AND
          f.deleted_at IS NULL
        )
        ORDER BY r.form_structure_id, r.subject_id, r.instance_number, r.id
      SQL
      ActiveRecord::Base.connection.execute(sql)
      #return FormResponse.includes(:form_answers).
      #    where("form_structures.project_id=?", proj_id).
      #    joins("inner join form_structures on form_structures.id=form_responses.form_structure_id").
      #    order(:form_structure_id, :subject_id, :instance_number)
    end

  end
end
