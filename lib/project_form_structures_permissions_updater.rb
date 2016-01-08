class ProjectFormStructuresPermissionsUpdater
  class << self
    def update(current_user, team_member, permissions_data)
      project = team_member.project
      structures = project.form_structures
      team_member.form_structure_permissions.where.not(form_structure_id: structures.map(&:id)).each do |perm|
        perm.delete!
      end
      structures.each do |structure|
        level = "None"
        data = permissions_data.find do |item|
          item["formStructureID"] == structure.id
        end
        perm = team_member.form_structure_permissions.find_by(form_structure: structure)
        if perm.nil?
          perm = TeamRecordCreator.create_form_structure_permission(form_structure: structure, team_member: team_member, permission_level: "None")
        end
        AuditLogger.surround_edit(current_user, perm) do
          perm.permission_level = data["permissionLevel"]
          perm.save!
        end
      end
    end
  end
end
