class AddSecondaryFieldsToDemoProgress < ActiveRecord::Migration
  def change
  	add_column :demo_progresses, :create_new_query, :boolean, default: false
  	add_column :demo_progresses, :build_query_info, :boolean, default: false
  	add_column :demo_progresses, :build_query_params, :boolean, default: false
  	add_column :demo_progresses, :query_results_download, :boolean, default: false
  	add_column :demo_progresses, :query_results_breadcrumbs, :boolean, default: false
  end
end
