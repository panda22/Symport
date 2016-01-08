describe SubjectLookup do
  subject { described_class }

  describe ".known_subjects_of_project" do
    it "returns an array of subject IDs" do
      project = create :project
      form = create :form_structure, project: project
      response1 = create :form_response, form_structure: form, subject_id: "420"
      response2 = create :form_response, form_structure: form, subject_id: "422"
      response3 = create :form_response, form_structure: form, subject_id: "418"

      other_form = create :structure_research_form_b
      other_form.project = project
      other_form.save!
      other_response1 = create :form_response, form_structure: other_form, subject_id: "422"

      response_for_different_form = create :response_research_form_a

      subject.known_subjects_of_project(project).should =~ ["420", "422", "418"]
    end
  end

  describe ".project_contains_subject_id?" do
    it "returns whether the project has a matching subject ID" do
      project = create :project
      form_a = create :empty_form_structure, project: project, name: "Form A"
      form_b = create :empty_form_structure, project: project, name: "Form B"

      resp1 = create :form_response, form_structure: form_a, subject_id: "Sticky Thread"
      resp2 = create :form_response, form_structure: form_b, subject_id: "Sticky Thread"
      resp3 = create :form_response, form_structure: form_a, subject_id: "Cubism Dream"
      resp4 = create :form_response, form_structure: form_b, subject_id: "World News"

      subject.project_contains_subject_id?(project, "Ceilings").should be_false
      subject.project_contains_subject_id?(project, "Cubism Dream").should be_true
      subject.project_contains_subject_id?(project, "Sticky Thread").should be_true
      subject.project_contains_subject_id?(project, "World News").should be_true
      subject.project_contains_subject_id?(project, "Black Balloons").should be_false
    end
  end

end