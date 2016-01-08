class AddInitialFieldsToDemoProgress < ActiveRecord::Migration
  def change
  	add_column :demo_progresses, :project_index_global, :boolean, default: false
  	add_column :demo_progresses, :project_index_demo_project, :boolean, default: false
  	add_column :demo_progresses, :form_enter_edit, :boolean, default: false
  	add_column :demo_progresses, :enter_edit_subject_id, :boolean, default: false
  	add_column :demo_progresses, :enter_edit_response, :boolean, default: false
  	add_column :demo_progresses, :enter_edit_save, :boolean, default: false
  	add_column :demo_progresses, :data_tab_emphasis, :boolean, default: false
  	add_column :demo_progresses, :view_data_sort_search, :boolean, default: false
  end
end
