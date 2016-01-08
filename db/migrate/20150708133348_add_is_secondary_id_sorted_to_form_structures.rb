class AddIsSecondaryIdSortedToFormStructures < ActiveRecord::Migration
  def change
    add_column :form_structures, :is_secondary_id_sorted, :boolean
  end
end
