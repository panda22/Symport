class RenamePatientToSubject < ActiveRecord::Migration
  def change
    rename_column :form_responses, :patient_id, :subject_id
  end
end
