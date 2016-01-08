class ProjectFormStructuresPermissionsBuilder
  class << self
    def build(creator, project, team_member, permissions_data)
      project.form_structures.map do |structure|
        level = "None"
        data = permissions_data.find do |item|
          item["formStructureID"] == structure.id
        end
        if data
          level = data["permissionLevel"]
        end
        permission = TeamRecordCreator.create_form_structure_permission team_member: team_member,
                                                                        permission_level: level,
                                                                        form_structure: structure
        AuditLogger.add(creator, permission)
        permission
      end
    end
  end
end
