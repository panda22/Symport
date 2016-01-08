class AddFormStructurePermissionsToAuditLog < ActiveRecord::Migration
  def change
    add_column :audit_logs, :form_structure_permission_id, :uuid
    add_index :audit_logs, :form_structure_permission_id
    add_foreign_key :audit_logs, :form_structure_permissions, dependent: :delete
  end
end
