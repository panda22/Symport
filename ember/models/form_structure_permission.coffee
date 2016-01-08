LabCompass.FormStructurePermission = LD.Model.extend
  id: null
  formStructureID: LD.attr "string"
  formStructureName: LD.attr "string"
  permissionLevel: LD.attr "string"

LabCompass.FormStructurePermissionLevels = ["Full", "Read/Write", "Read", "None"]
LabCompass.FormStructPermsDisplay = [
      display: "Enter/Edit & Build"
      value: "Full"
    ,
      display: "Enter/Edit Data"
      value: "Read/Write"
    ,
      display: "View Data"
      value: "Read"
    ,
      display: "No Access"
      value: "None"
  ]



