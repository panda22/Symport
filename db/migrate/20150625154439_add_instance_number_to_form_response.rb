class AddInstanceNumberToFormResponse < ActiveRecord::Migration
  def change
    add_column :form_responses, :instance_number, :integer
    add_column :form_responses, :secondary_id, :text
    add_column :form_structures, :is_many_to_one, :boolean
  end
end
