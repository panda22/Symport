class FormResponsesTableGeneratorBuilder
  class << self
#    def build(include_phi, user, form_structure)

#      include_phi &&= Permissions.user_can_view_personally_identifiable_answers_for_project?(user, form_structure.project)

#      id_column = ExportColumnGenerator.new "Subject", ->(r) { r.subject_id }
#      questions = form_structure.answerable_questions.order("sequence_number ASC")
#      question_columns = questions.map do |question|
#        ExportColumnGenerator.new question.variable_name, ->(r) { 
#          if !question.personally_identifiable || include_phi
#            answer = r.form_answers.find_by(form_question: question).try(:answer) 
#            answer.gsub!("\u200C", "|") if answer.present? && question.question_type == "checkbox"
#            answer
#          else
#            nil
#          end
#        }
#      end
#      time = Time.now.strftime("%m/%d/%yT%I:%M:%S")
#      ExportTableGenerator.new "#{form_structure.project.name}-#{form_structure.name}-#{time}", ([id_column] + question_columns)
#    end
  end
end
