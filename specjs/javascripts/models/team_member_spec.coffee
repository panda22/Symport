moduleForLDModel "teamMember", "team member tests",
  needs: ["model:formStructurePermission"]

test "expired", ->
  today = new Date()
  @subject().set "expirationDate", new Date(today.getTime() + (24 * 60 * 60 * 1000)).toString()
  ok !@subject().get("expired")
  @subject().set "expirationDate", new Date(today.getTime() - (24 * 60 * 60 * 1000)).toString()
  ok @subject().get("expired")

test "storage usage", ->
  permission = @subject().get('storage').createModel "formStructurePermission", permissionLevel: "Full"
  @subject().get('structurePermissions').addObject permission
  equal permission, @subject().get('structurePermissions.firstObject')

test "starting attributes / fullname", ->
  @subject
    firstName: "Matt"
    lastName: "Smith"
  equal "Matt Smith", @subject().get('fullName')
    

