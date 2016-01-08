LabCompass.TeamMember = LD.Model.extend
  id: null
  isCurrentUser: LD.attr "boolean"
  firstName: LD.attr "string"
  lastName: LD.attr "string"
  email: LD.attr "string"
  expirationDate: LD.attr "date"
  administrator: LD.attr "boolean"
  formCreation: LD.attr "boolean"
  auditLog: LD.attr "boolean"
  export: LD.attr "boolean"
  viewPersonallyIdentifiableAnswers: LD.attr "boolean"

  isPending: LD.attr "boolean"

  structurePermissions: LD.hasMany "formStructurePermission"

  expired: false

  fullName: (->
    "#{@get("firstName")} #{@get("lastName")}"
  ).property "firstName", "lastName"

  expirationDateString: (->
    date = @get("expirationDate")
    if date and (new Date(date) < new Date())
      @set("expired", true)
      return "EXPIRED"
    else
      @set("expired", false)
    if date
      date
    else
      "None"
  ).property "expirationDate"

