class AddSecondaryIdToFormStructures < ActiveRecord::Migration
  def change
    add_column :form_structures, :secondary_id, :text
  end
end
