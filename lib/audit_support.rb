class AuditSupport
  class << self
    # serialize for audit log
    def serialize(record)
      serializers[record.class].(record)
    end

    # get all related records (including "subjects") that will be helpful in the audit log
    def related_records_for(record, key = nil)
      key ||= record.class.to_s.underscore.to_sym
      related = [related_records[record.class] || []].flatten
      include_self = ((!record.is_a?(ActiveRecord::Base)) || (!related.delete(:self).nil?))
      recs = related.map do |r|
        related_records_for(record.send(r), r)
      end.reduce({}) do |acc, h|
        acc.merge h
      end
      if include_self
        recs = recs.merge(
        {
          key => record
        })
      end
      recs
    end

    private
    def serializers
      @@serializers ||= {
        FormStructure => shallow_serializer(:name),
        FormQuestion => ->(r) {
          ShallowRecordSerializer.serialize(r, :sequence_number, :personally_identifiable,
            :variable_name, :prompt, :description, :question_type).merge({
            config: FormQuestionConfigSerializer.serialize(r),
            exceptions: QuestionExceptionsSerializer.serialize(r, false)
          })
        },
        Project => shallow_serializer(:name),
        TeamMember => shallow_serializer(:user_id, :administrator, :form_creation, :expiration_date, :audit, :view_personally_identifiable_answers, :export),
        FormStructurePermission => shallow_serializer(:permission_level),
        User => shallow_serializer(:email, :first_name, :last_name, :affiliation, :field_of_study),
        FormResponse => shallow_serializer(:subject_id, :secondary_id),
        FormAnswer => shallow_serializer(:answer)
      }
    end

    def shallow_serializer(*attrs)
      ->(r) { ShallowRecordSerializer.serialize(r, *attrs) }
    end

    def related_records
      @@related_record_types ||= {
        Project => :self,
        FormStructure => [:self, :project],
        FormQuestion => [:self, :form_structure],
        TeamMember => [:self, :project],
        FormStructurePermission => [:self, :team_member, :form_structure],
        FormResponse => [:form_structure, :subject_id, :secondary_id],
        FormAnswer => [:form_response, :form_question]
      }
    end
  end
end
