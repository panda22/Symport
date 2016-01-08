class TeamMemberSerializer
  class << self
    def serialize(current_user, team_member)
      is_pending = (PendingUser.find_by(:user_id => team_member.user_id) != nil)
      {
        id: team_member.id,
        isCurrentUser: team_member.user == current_user,
        firstName: team_member.user.first_name,
        lastName: team_member.user.last_name,
        email: team_member.user.email,
        expirationDate: team_member.expiration_date.try(:strftime, "%-m/%-d/%Y"),
        administrator: team_member.administrator,
        formCreation: (team_member.administrator || team_member.form_creation),
        auditLog: (team_member.administrator || team_member.audit),
        viewPersonallyIdentifiableAnswers: (team_member.administrator || team_member.view_personally_identifiable_answers),
        export: (team_member.administrator || team_member.export),
        isPending: is_pending,
        structurePermissions: team_member.project.form_structures.map do |structure|
          perm = structure.form_structure_permissions.find_by(team_member: team_member)
          if perm.nil?
            perm = FormStructurePermission.new(team_member: team_member, form_structure: structure, permission_level: "None")
          end
          FormStructurePermissionSerializer.serialize perm 
        end
      }
    end
  end
end
