class AddManyToOneToQueryParams < ActiveRecord::Migration
  def change
    add_column :query_params, :is_many_to_one_instance, :boolean
    add_column :query_params, :is_many_to_one_count, :boolean
    add_column :query_params, :form_structure_id, :uuid

    add_foreign_key :query_params, :form_structures, dependent: :delete
  end
end
