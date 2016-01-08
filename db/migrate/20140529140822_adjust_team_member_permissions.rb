class AdjustTeamMemberPermissions < ActiveRecord::Migration
  def change
    remove_column :team_members, :permission_level, :text
    add_column :team_members, :administrator, :boolean, default: false
    add_column :team_members, :form_creation, :boolean, default: false
    add_column :team_members, :audit, :boolean, default: false
    add_column :team_members, :export, :boolean, default: false
  end
end
