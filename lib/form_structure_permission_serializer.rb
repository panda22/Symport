class FormStructurePermissionSerializer
  class << self
    def serialize(permissions)
      {
        id: permissions.id,
        formStructureID: permissions.form_structure.id,
        formStructureName: permissions.form_structure.name,
        permissionLevel: permissions.permission_level || "None"
      }
    end
  end
end
