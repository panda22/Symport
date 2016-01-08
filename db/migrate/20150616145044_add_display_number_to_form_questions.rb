class AddDisplayNumberToFormQuestions < ActiveRecord::Migration
  def change
    add_column :form_questions, :display_number, :text
  end
end
