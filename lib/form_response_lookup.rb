class FormResponseLookup
  class << self
    def find_many_responses_in_form_structure_by_subject_ids(user, structure, subjectids)
      if structure.is_many_to_one
        raise PayloadException.new 422, "Incompatible server lib call find_many_responses_in_form_structure_by_subject_ids for many to on form"
      end
      if !Permissions.user_can_view_form_responses_for_form_structure?(user, structure)
        raise PayloadException.access_denied "You do not have access to responses for this form"
      end

      if subjectids == [] || subjectids == nil
        return []
      end

      all_responses_hash = {}
      all_responses = FormResponse.where(form_structure_id: structure.id) 
      all_responses.each do |r|
        all_responses_hash[r.subject_id] = r
      end

      subjectids.map do |id|
        all_responses_hash[id]
      end
    end

    def find_many_responses_in_form_structure_by_subject_and_secondary_ids(user, structure, subject_second_tuples)
      if !structure.is_many_to_one
        raise PayloadException.new 422, "Incompatible server lib call find_many_responses_in_form_structure_by_subject_and_secondary_ids for not many to on form"
      end
      if !Permissions.user_can_view_form_responses_for_form_structure?(user, structure)
        raise PayloadException.access_denied "You do not have access to responses for this form"
      end

      if subject_second_tuples == [] || subject_second_tuples == [[]] || subject_second_tuples == nil
        return []
      end

      all_responses_hash = {}
      all_responses = FormResponse.where(form_structure_id: structure.id) 
      all_responses.each do |r|
        if all_responses_hash[r.subject_id] == nil
          all_responses_hash[r.subject_id] = {}
        end
        all_responses_hash[r.subject_id][r.secondary_id] = r
      end

      subject_second_tuples.map do |id_pair|
        if !all_responses_hash[id_pair[0]]
          nil
        else
          all_responses_hash[id_pair[0]][id_pair[1]]
        end
      end
    end

    def find_response(user, id)
      FormResponse.find(id).tap do |resp| 
        verify_response_access user, resp 
      end
    end

    def find_response_by_subject_id(user, structure_id, subject_id, instance_number=0)
      FormResponse.find_by(subject_id: subject_id, form_structure_id: structure_id, instance_number: instance_number).tap do |resp|
        verify_response_access user, resp
      end
    end

    def get_max_instances_in_form(structure_id)
      sql = "select max(subject_count) from " +
              "(select count(*) as subject_count, r.subject_id " +
              "from form_responses r " +
              "where r.form_structure_id=" +
              ActiveRecord::Base::sanitize(structure_id) +
              " and r.deleted_at is null " +
              " group by r.subject_id) " +
              "as form_counts "
      rs = ActiveRecord::Base.connection.execute(sql).values
      return rs.first.first.to_i
    end

    def get_subjects_by_form(form_structure)
      form_id = form_structure.id
      project_id = form_structure.project_id
      responses_rs = get_subjects_by_form_rs(form_id, project_id)
      aggregate_responses_by_form(responses_rs)
    end



    private
    def verify_response_access(user, response)
      if response.present? 
        if !Permissions.user_can_view_form_responses_for_form_structure?(user, response.form_structure)
          raise PayloadException.access_denied "You do not have access to responses for this form"
        end
      end
    end

    def get_subjects_by_form_rs(form_id, project_id)
      sql = <<-SQL
        SELECT r.subject_id AS subject_id,
               r2.id AS response_id,
               r2.secondary_id AS secondary_id
        FROM form_responses r
        INNER JOIN form_structures f
          ON f.id=r.form_structure_id
          AND f.project_id=#{ActiveRecord::Base::sanitize(project_id)}
          AND f.deleted_at IS NULL
        LEFT JOIN form_responses r2
          ON r2.form_structure_id=#{ActiveRecord::Base::sanitize(form_id)}
          AND r2.id=r.id
          AND r2.deleted_at IS NULL
        WHERE r.deleted_at IS NULL
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end

    def aggregate_responses_by_form(rs)
      result_hash = {}
      rs.each do |record|
        subject_id = record["subject_id"]
        response_id = record["response_id"]
        secondary_id = record["secondary_id"]
        unless result_hash.has_key?(subject_id)
          result_hash[subject_id] = []
        end
        unless response_id.nil?
          obj = {
              responseID: response_id,
              secondaryID: secondary_id
          }
          result_hash[subject_id].push(obj)
        end
      end
      result_hash
    end

  end
end
