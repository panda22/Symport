moduleForController "project", "the project controller",
  model: "project"

test "breadcrumb", ->
  @subject().set("model.name", "my project")
  equal "Project Home - my project", @subject().get("breadCrumb")
