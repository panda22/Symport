class AddPatientIdToFormResponse < ActiveRecord::Migration
  def change
    add_column :form_responses, :patient_id, :string
    add_index :form_responses, :patient_id
  end
end
