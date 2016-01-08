class AddExecptionTypesToQueryParams < ActiveRecord::Migration
  def change
    add_column :query_params, :is_regular_exception, :boolean
    add_column :query_params, :is_year_exception, :boolean
    add_column :query_params, :is_month_exception, :boolean
    add_column :query_params, :is_day_exception, :boolean
  end
end
