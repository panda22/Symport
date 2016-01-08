target =
  send: -> {}
  transitionToRoute: -> {}
tMock = null

moduleForController "projectIndex", "project index controller tests",
  model: "project"
  needs: [
    "model:formStructure"
    "model:teamMember"
    "model:projectLevelPermissions"
    "model:teamLevelPermissions"
  ]
  target: target
  setup: ->
    tMock = sinon.mock(target)
      
test "manage team", ->
  tMock.expects('transitionToRoute').withArgs 'team-members.index', @subject().get('model')
  @subject().send("manageTeam")
  tMock.verify()

test "update project settings", ->
  proj = @subject().get("content")
  iface = { saveProject: (-> {}) }
  @subject().set("storage.interface", iface)
  ifaceMock = sinon.mock(iface)
  proj.set("id", "abc123")
  proj.set("name", "My Project")
  ifaceMock.expects('saveProject').withArgs(
    id: "abc123"
    name: "My Project"
  ).returns Ember.RSVP.resolve(name: "My Updated Project")
  @subject().send("updateProjectSettings", proj)
  # promise we return above defers this behavior, TODO a better way
  Ember.run.later =>
    equal proj.get('name'), "My Updated Project"
    equal @subject().get('model.name'), "My Updated Project"
    tMock.verify()
    ifaceMock.verify()

