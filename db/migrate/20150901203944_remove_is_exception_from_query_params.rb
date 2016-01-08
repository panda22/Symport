class RemoveIsExceptionFromQueryParams < ActiveRecord::Migration
  def change
    remove_column :query_params, :is_exception, :boolean
  end
end
