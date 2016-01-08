class AddForeignKeysForTeamsAndPermissions < ActiveRecord::Migration
  def change
    add_foreign_key :team_members, :users, dependent: :delete
    add_foreign_key :team_members, :projects, dependent: :delete

    add_foreign_key :form_structure_permissions, :form_structures, depedent: :delete
    add_foreign_key :form_structure_permissions, :team_members, depedent: :delete
  end
end
