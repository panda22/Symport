class FormDataLookup
  class << self
    def get_responses_rs(form_id, can_view_identifiable, is_initial, initial_size)
      identifiable_str = ""
      unless can_view_identifiable
        identifiable_str = "q.personally_identifiable=false AND"
      end
      join_str = (is_initial) ? "INNER JOIN" : "LEFT JOIN"
      exclude_str = (is_initial) ? "" : "AND r_e.id is null"
      sql = <<-SQL
        SELECT r.id AS response_id, a.answer AS answer, r.subject_id AS subject_id,
          a.id AS answer_id, r.secondary_id as secondary_id,
          r.created_at AS response_created_at, r.updated_at AS response_updated_at,
          q.id AS question_id, q.variable_name AS var_name, q.question_type AS question_type,
          CASE WHEN a.answer like '%\u200a%' then 1 -- for other question type
               ELSE 0
          END AS has_other_type
        FROM form_answers a
          inner join form_responses r
            on r.id = a.form_response_id
            and r.form_structure_id = '#{form_id}'
            and r.deleted_at IS NULL
          inner join form_questions q
            on q.id = a.form_question_id
          #{join_str}
          (
             SELECT id
              FROM form_responses r2
              WHERE (
                r2.form_structure_id='#{form_id}' AND
                r2.deleted_at IS NULL
              )
              ORDER BY r2.subject_id, r2.instance_number, r2.created_at
              LIMIT #{initial_size}
          ) r_e
            on r.id = r_e.id -- excluded for left join
        WHERE (
          #{identifiable_str}
          a.deleted_at IS NULL
          #{exclude_str}
         )
        ORDER BY r.subject_id, r.instance_number, r.created_at, q.sequence_number
      SQL
      ActiveRecord::Base.connection.execute(sql)
      #FormResponse.includes(:form_answers).includes(:form_questions).where(:form_structure_id => form_id)
    end

    def get_other_questions_rs(form_id)
      sql = <<-SQL
        select o.form_question_id as question_id, o.other_variable_name as var_name
        from option_configs o
        inner join form_questions q
          on q.id=o.form_question_id
        inner join form_structures f
          on f.id=q.form_structure_id
          and f.id='#{form_id}'
        where o.other_option=true
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end

    def get_form_questions(form_id, can_view_identifiable)
      if can_view_identifiable
        FormQuestion.where(:form_structure_id => form_id).where("question_type != 'header'").order(:sequence_number)
      else
        FormQuestion.where(:form_structure_id => form_id, :personally_identifiable => false).where("question_type != 'header'").order(:sequence_number)
      end
    end

    def get_response_count_by_form(project_id)
      sql = <<-SQL
        SELECT f.id, COUNT(r)
        FROM form_responses r, form_structures f
        WHERE (
          r.form_structure_id = f.id AND
          f.deleted_at IS NULL AND
          f.project_id = '#{project_id}' AND
          r.deleted_at IS NULL
        )
        group by f.id
      SQL
      ActiveRecord::Base.connection.execute(sql).values
    end

    def get_answer_error_by_question(form_id, can_view_identifiable)
      sql = ""
      if can_view_identifiable
        sql = <<-SQL
          SELECT r.subject_id as subject_id, r.secondary_id as secondary_id,
            a.form_response_id as response_id, a.form_question_id as question_id,
            a.error_msg as message, a.ignore_error as ignore_error,
            a.id as answer_id, a.answer as answer,
            CASE WHEN a.answer like '%\u200a%' then 1 -- for other question type
               ELSE 0
            END AS has_other_type
          FROM form_answers a
          INNER JOIN form_responses r on a.form_response_id=r.id and r.form_structure_id='#{form_id}'
          INNER JOIN form_questions q on a.form_question_id=q.id
          WHERE (
            a.error_msg is not null
            and a.deleted_at is null
            and q.deleted_at is null
            and a.ignore_error != true -- remove this line to get ignored errors
          )
          ORDER BY a.form_question_id
        SQL
      else
        sql = <<-SQL
          SELECT a.form_response_id as response_id, a.form_question_id as question_id,
            a.error_msg as message, a.ignore_error as ignore_error
          FROM form_answers a
          INNER JOIN form_responses r on a.form_response_id=r.id and r.form_structure_id='#{form_id}'
          INNER JOIN form_questions q on a.form_question_id=q.id and q.personally_identifiable=false
          WHERE (
            a.error_msg is not null
            and a.deleted_at is null
            and a.ignore_error != true -- remove this line to get ignored errors
          )
          ORDER BY a.form_question_id
        SQL
      end
      ActiveRecord::Base.connection.execute(sql)
    end

  end
end