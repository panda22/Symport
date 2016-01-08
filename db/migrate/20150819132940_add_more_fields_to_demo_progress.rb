class AddMoreFieldsToDemoProgress < ActiveRecord::Migration
  def change
  	add_column :demo_progresses, :form_global, :boolean, default: false
  	add_column :demo_progresses, :team_button, :boolean, default: false
  	add_column :demo_progresses, :add_new_team_member, :boolean, default: false
  	add_column :demo_progresses, :add_team_member_personal_details, :boolean, default: false
  	add_column :demo_progresses, :add_team_member_project_permissions, :boolean, default: false
  	add_column :demo_progresses, :add_team_member_form_permissions, :boolean, default: false
  	add_column :demo_progresses, :import_button, :boolean, default: false
  	add_column :demo_progresses, :import_overlays, :boolean, default: false
  	add_column :demo_progresses, :import_csv_text, :boolean, default: false
  	add_column :demo_progresses, :build_form_button, :boolean, default: false
  	add_column :demo_progresses, :form_builder_info, :boolean, default: false
  	add_column :demo_progresses, :build_form_add_question, :boolean, default: false
  	add_column :demo_progresses, :question_builder_prompt, :boolean, default: false
  	add_column :demo_progresses, :question_builder_variable, :boolean, default: false
  	add_column :demo_progresses, :question_builder_identifying, :boolean, default: false
  end
end
