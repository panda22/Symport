class TeamRecordCreator
  class << self
    def create_team_member(data)
      attrs = data.slice(:project, :user, :expiration_date, :administrator,
            :form_creation, :audit, :export, :view_personally_identifiable_answers)
      TeamMember.create! attrs
    end

    def create_form_structure_permission(data)
      attrs = data.slice(:team_member, :permission_level, :form_structure)
      record = FormStructurePermission.create! attrs
    end
  end
end