class DemoProjectCreator
  class << self
    def create_demo_project_for_user(user)
	    project = ProjectCreator.create(user, nil, true)
	    structure = FormStructureCreator.create({id: nil, name: "Demo Form", isManyToOne: false, secondaryId: nil, isSecondaryIdSorted: false}, user, project)
	    question_data1 = {
	      prompt: "What was the purpose of your visit?", type: "radio", variableName: "purpose_of_visit", description: "Select the best option below", personallyIdentifiable: false, sequenceNumber: 1, displayNumber: "1",
	      config: { 
	        selections: [
	          { value: "Emergency", code: "1" },
	          { value: "Screening", code: "2" },
	          { value: "Checkup", code: "3" },
	          { value: "Treatment", code: "4" }
	        ]
	      } 
	    }
	    question_data2 = {
	      prompt: "What is your age?", type: "numericalrange", variableName: "age", description: "in years", personallyIdentifiable: false, sequenceNumber: 2, displayNumber: "2",
	      config: { 
	        minValue: "18",
	        maxValue: "100",
	        precision: 6
	      } 
	    }
	    question_data3 = {
	      prompt: "Were you satisfied with your care?", type: "yesno", variableName: "satisfied", personallyIdentifiable: false, sequenceNumber: 3, displayNumber: "3",
	      config: { 
	        selections: [
	          {value: "Yes", code: "1"},
	          {value: "No", code: "2"}
	        ]
	      } 
	    }
	    q1 = FormRecordCreator.create_question(question_data1, structure)
	    q2 = FormRecordCreator.create_question(question_data2, structure)
	    q3 = question = FormRecordCreator.create_question(question_data3, structure)
	    rows = [
	      {sub_id: "100", a1: "Checkup", a2: "29", a3: ""}, 
	      {sub_id: "101", a1: "Emergency", a2: "55", a3: "Yes"}, 
	      {sub_id: "102", a1: "Screening", a2: "79", a3: "No"}, 
	      {sub_id: "103", a1: "Treatment", a2: "34", a3: "Yes"}, 
	      {sub_id: "104", a1: "Screening", a2: "48", a3: "Yes"}, 
	      {sub_id: "105", a1: "Emergency", a2: "57", a3: "No"}, 
	      {sub_id: "106", a1: "Checkup", a2: "49", a3: "Yes"}, 
	      {sub_id: "107", a1: "Treatment", a2: "67", a3: "Yes"}, 
	      {sub_id: "108", a1: "Treatment", a2: "50", a3: "Yes"}, 
	      {sub_id: "109", a1: "Treatment", a2: "53", a3: "No"}
	    ]
	    i = 0
	    new_answers_data = []
	    rows.each do |row|
	      response = FormResponse.create!(form_structure_id: structure.id, subject_id: row[:sub_id], instance_number: 0)
	      new_answers_data[i] = "'#{response.id}', '#{q1.id}', '#{row[:a1]}'"
	      i = i + 1
	      new_answers_data[i] = "'#{response.id}', '#{q2.id}', '#{row[:a2]}'"
	      i = i + 1
	      new_answers_data[i] = "'#{response.id}', '#{q3.id}', '#{row[:a3]}'"
	      i = i + 1
	    end
	    sql = "INSERT INTO form_answers (form_response_id, form_question_id, answer) VALUES (#{new_answers_data.join("), (")})"
	    FormAnswer.connection.execute sql
	    DemoProgress.create!(project_id: project.id, user_id: user.id, demo_form_id: structure.id, demo_question_id: q3.id)
    end
  end
end
