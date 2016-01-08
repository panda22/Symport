class AddVariableNameToFormQuestions < ActiveRecord::Migration
  def change
    add_column :form_questions, :variable_name, :string
  end
end
