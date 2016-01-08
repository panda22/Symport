class AddSecondaryIdToAudit < ActiveRecord::Migration
  def change
  	add_column :audit_logs, :secondary_id, :string
  end
end
