class QueryChangeUpdater
  class << self
    def update_from_form_structure(structure, delete=false)
      params = QueryParam.where(:form_structure_id => structure.id)
      update_change(params,"form", structure.name, delete)
    end

    def update_from_form_question(question, delete=false)
      params = QueryParam.where(:form_question_id => question.id)
      update_change(params, "question", question.variable_name, delete)
    end

    def update_from_secondary_id_change(structure)
      params = QueryParam.where(:form_structure_id => structure.id).
                where("is_many_to_one_instance=true or is_many_to_one_count=true")
      update_change(params, "secondary_id", structure.secondary_id, true)
    end


    private
    def update_change (params, type, name, delete)
      changed_queries = []
      params.each  do |param|
        unless param.query.nil?
          changed_queries.push(param.query)
          if delete
            param.destroy!
          end
        end
      end
      changed_queries.uniq.each do |query|
        query.is_changed = true
        handle_message_string(query, type, name)
        query.save!
      end
    end

    def handle_message_string(query, type, name)
      query_message = JSON.parse(query.change_message) rescue {}
      if query_message.has_key?(type)
        message_arr = query_message[type]
        unless message_arr.include?(name)
          message_arr.push(name)
        end
      else
        query_message[type] = [name]
      end
      unless query_message.empty?
        query.change_message = query_message.to_json
      end
    end

  end
end