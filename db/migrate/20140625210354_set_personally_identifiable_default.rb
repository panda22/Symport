class SetPersonallyIdentifiableDefault < ActiveRecord::Migration
  def change
    change_column :form_questions, :personally_identifiable, :boolean, default: false
  end
end
