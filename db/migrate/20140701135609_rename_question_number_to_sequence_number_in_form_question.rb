class RenameQuestionNumberToSequenceNumberInFormQuestion < ActiveRecord::Migration
  def change
    rename_column :form_questions, :question_number, :sequence_number
  end
end
