class AuditLogger
  class << self

    # change & save must happen inside block
    # examples:
    #
    # GOOD
    # ----------
    # AuditLogger.surround_edit(user, question) do
    #   question.prompt = "A very good question"
    #   question.save!
    # end
    #
    # BAD
    # ----------
    # question.prompt = "A very good question" # need to update (even in-mem) inside block
    # AuditLogger.surround_edit(user, question) do
    #   question.save!
    # end
    #
    # ###
    #
    # AuditLogger.surround_edit(user, question) do
    #   question.prompt = "A very good question"
    # end
    # question.save! # need to persist inside block
    #
    def surround_edit(user, record) 
      old_data = AuditSupport.serialize(record)
      yield # do your changing and saving
      record.reload # Maybe?
      data = AuditSupport.serialize(record)
      (old_data, data) = diff(old_data, data)
      #if old_data == data && data == {}
      #  return
      #end
      record_entry user, record, "edit", { old_data: old_data, data: data }
    end

    def add(user, record)
      data = AuditSupport.serialize(record)
      record_entry user, record, "add", { data: data }
    end

    def view(user, record)
      record_entry user, record, "view"
    end

    def remove(user, record)
      old_data = AuditSupport.serialize(record)
      record_entry user, record, "remove", { old_data: old_data }
    end

    def export(user, record, file_name, col_heads)
      record_entry user, record, "export", data: { 
        exported: { 
          file_name: file_name,
          columns: col_heads
        }
      }
    end

    def import(user, record, file_name, subjects, variables)
      record_entry user, record, "import", data: {
        imported: {
          file_name: file_name,
          subjects: subjects,
          questions: variables
        }
      }
    end
    def user_entry(user, action, attrs={})
      entry(action, { user: user }.merge(attrs))
    end

    def entry(action, attrs = {})
      # convert old_data and data to json
      attrs[:data] = attrs[:data].to_json if attrs.has_key?(:data)
      attrs[:old_data] = attrs[:old_data].to_json if attrs.has_key?(:old_data)
      AuditLog.create! attrs.merge({ action: action })
    end

    def record_entry(user, record, action, attrs = {})
      user_entry(user, action, attrs.merge(AuditSupport.related_records_for(record)))
    end

    private
    def diff(data_one, data_two)
      new_one = data_one.select do |k| 
        !data_two.keys.include?(k) || (data_one[k] != data_two[k]) 
      end
      new_two = data_two.select do |k| 
        !data_one.keys.include?(k) || (data_one[k] != data_two[k]) 
      end
      [new_one, new_two]
    end

  end
end
