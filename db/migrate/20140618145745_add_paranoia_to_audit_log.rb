class AddParanoiaToAuditLog < ActiveRecord::Migration
  def change
    add_column :audit_logs, :deleted_at, :datetime
    add_index :audit_logs, :deleted_at
  end
end
