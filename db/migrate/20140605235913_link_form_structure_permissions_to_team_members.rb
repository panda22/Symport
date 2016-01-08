class LinkFormStructurePermissionsToTeamMembers < ActiveRecord::Migration
  def change
    rename_column :form_structure_permissions, :user_id, :team_member_id
  end
end
