describe ProjectViewDataController do 

	before do
		create_users
		sign_in (@user_bob)
		@user = controller.current_user
		@proj = create :project_a
		assign_users_to_team
	end

	describe "#get_forms_and_questions" do
		before do
			create_forms_and_questions
		end
		it "gets all forms and questions for a project" do
			get :get_forms_and_questions, id: @proj.id, format: :json
			response.should be_success
			reply = JSON.parse response.body
			reply["forms"].length.should == 2
			reply["forms"][0]["questions"].length.should == 2
		end

		it "returns error if user is not a team member" do
			sign_in(@user_ed)
			get :get_forms_and_questions, id: @proj.id, format: :json
			response.should_not be_success
		end
	end

	describe "#get_view_data" do
		it "gets a grid of responses" do
			create_forms_and_questions(true)
			get :get_view_data, id: @proj.id, format: :json
			reply = JSON.parse response.body
			reply["gridHeader"].length.should == 6
			reply["grid"].length.should == 2
		end

		it "returns no data error if no forms" do
			new_proj = create_empty_project
			get :get_view_data, id: new_proj.id, format: :json
			reply = JSON.parse response.body
			reply["noDataError"].should == "form"
		end

		it "returns no data error if no questions" do
			new_proj = create_proj_with_no_questions
			get :get_view_data, id: new_proj.id, format: :json
			reply = JSON.parse response.body
			reply["noDataError"].should == "question"
		end

		it "returns no data error if no responses" do
			create_forms_and_questions(false)
			get :get_view_data, id: @proj.id, format: :json
			reply = JSON.parse response.body
			reply["noDataError"].should == "response"
		end

		it "returns no data error if no form access" do
			create_no_form_access
			sign_in(@user_jon)
			get :get_view_data, id: @proj.id, format: :json
			reply = JSON.parse response.body
			reply["noDataError"].should == "formPermission"
		end
		
		it "returns no data error if all responses are phi blocked" do
			create_only_phi_forms
			sign_in(@user_tim)
			get :get_view_data, id: @proj.id, format: :json
			reply = JSON.parse response.body
			reply["noDataError"].should == "questionPermission"
		end

		it "returns partial data if one form is blocked" do
			create_partial_form_access
			sign_in(@user_jon)
			get :get_view_data, id: @proj.id, format: :json
			reply = JSON.parse response.body
			reply["gridHeader"].length.should == 4
			reply["grid"].length.should == 2
		end
	end

	describe "#get_query_data" do

		before do
			forms = create_forms_and_questions(true)
			@form_hash = {forms[0].id => true, forms[1].id => true}
		end

		it "returns the full grid with nothing set" do
			post :get_query_data, proj_id: @proj.id, form_hash: @form_hash, query_params: [], conjunction: "and", format: :json
			reply = JSON.parse response.body
			check_query_response(reply, 100, 2, 6)
		end

		it "returns less columns with a form filtered" do
			@form_hash[@form_hash.keys.first] = false
			post :get_query_data, proj_id: @proj.id, form_hash: @form_hash, query_params: [], conjunction: "and", format: :json
			reply = JSON.parse response.body
			check_query_response(reply, 100, 2, 4)
		end

		it "returns less rows with a param" do
			query_params = [{formName: "form1", operator: "<", questionName: "ques2", questionType: "date", value: "1/1/2015"}]
			post :get_query_data, proj_id: @proj.id, form_hash: @form_hash, query_params: query_params, conjunction: "and", format: :json
			reply = JSON.parse response.body
			check_query_response(reply, 50, 1, 6)
		end

		it "returns result set even when queried question is not in result set" do
			@form_hash[@form_hash.keys.first] = false
			query_params = [{formName: "form1", operator: "<", questionName: "ques2", questionType: "date", value: "1/1/2015"}]
			post :get_query_data, proj_id: @proj.id, form_hash: @form_hash, query_params: query_params, conjunction: "and", format: :json
			reply = JSON.parse response.body
			check_query_response(reply, 50, 1, 4)
		end

		it "returns empty set with conflicting and parameters" do
			query_params = [{formName: "form1", operator: "<", questionName: "ques2", questionType: "date", value: "1/1/2015"},
				{formName: "form1", operator: "≥", questionName: "ques2", questionType: "date", value: "1/1/2015"}]
			post :get_query_data, proj_id: @proj.id, form_hash: @form_hash, query_params: query_params, conjunction: "and", format: :json
			reply = JSON.parse response.body
			check_query_response(reply, 0, 0, 6)
		end

		it "returns non empty result set with conflicting or parameters" do
			query_params = [{formName: "form1", operator: "<", questionName: "ques2", questionType: "date", value: "1/1/2015"},
				{formName: "form1", operator: "≥", questionName: "ques2", questionType: "date", value: "1/1/2015"}]
			post :get_query_data, proj_id: @proj.id, form_hash: @form_hash, query_params: query_params, conjunction: "or", format: :json
			reply = JSON.parse response.body
			check_query_response(reply, 100, 2, 6)
		end
	end

	def create_users
		# admin
		@user_bob = create :user, email: "bob@test.com", password: "Complex1", first_name: "Bob", last_name: "Guy", demo_progress: 6, phone_number: '1234567890'
		# no phi
		@user_tim = create :user, email: "tim@test.com", password: "Complex1", first_name: "Tim", last_name: "Dood", demo_progress: 6, phone_number: '1234567890'
		# not in team
		@user_ed = create :user, email: "ed@test.com", password: "Complex1", first_name: "Ed", last_name: "Mister", demo_progress: 6, phone_number: '1234567890'
		# restricted form access
		@user_jon = create :user, email: "jon@test.com", password: "Complex1", first_name: "Jon", last_name: "Schmidt", demo_progress: 6, phone_number: '1234567890'
	end

	def assign_users_to_team
		@proj.team_members << TeamMember.create!(user: @user_bob, administrator: true, expiration_date: Date.parse("Oct 24, 2020"), view_personally_identifiable_answers: true)
		@proj.team_members << TeamMember.create!(user: @user_tim, view_personally_identifiable_answers: false, expiration_date: Date.parse("Oct 24, 2020"))
		@proj.team_members << TeamMember.create!(user: @user_jon, expiration_date: Date.parse("Oct 24, 2020"), view_personally_identifiable_answers: true)
	end

	def create_empty_project
		new_proj = Project.create(name: "no form test")
		new_proj.team_members << TeamMember.create!(user: @user_bob, administrator: true, expiration_date: Date.parse("Oct 24, 2020"), view_personally_identifiable_answers: true)
		new_proj.save!
		new_proj
	end

	def create_proj_with_no_questions
		new_proj = Project.create(name: "no question test")
		new_proj.team_members << TeamMember.create!(user: @user_bob, administrator: true, expiration_date: Date.parse("Oct 24, 2020"), view_personally_identifiable_answers: true)
		form1 = FormStructure.create(name: "no question 1")
		form2 = FormStructure.create(name: "no question 2")
		new_proj.form_structures << form1
		new_proj.form_structures << form2
		new_proj.save!
		new_proj
	end

	def create_forms_and_questions(include_responses=false)
		form1 = FormStructure.create(name: "form1")
		form2 = FormStructure.create(name: "form2")
		
		ques1 = FormQuestion.create(variable_name: "ques1", prompt: "ques1?", question_type: "text", sequence_number: 1, display_number: "1")
		ques2 = FormQuestion.create(variable_name: "ques2", prompt: "ques2?", question_type: "date", sequence_number: 2, display_number: "2")
		ques3 = FormQuestion.create(variable_name: "ques3", prompt: "ques3?", question_type: "text", sequence_number: 1, display_number: "1")
		ques4 = FormQuestion.create(variable_name: "ques4", prompt: "ques4?", question_type: "date", sequence_number: 2, display_number: "2")
		
		form1.form_questions << ques1
		form1.form_questions << ques2
		form2.form_questions << ques3
		form2.form_questions << ques4

		if include_responses == true
			create_form_responses(form1, form2, ques1, ques2, ques3, ques4)
		end

		@proj.form_structures << form1
		@proj.form_structures << form2
		form1.save!
		form2.save!
		@proj.save!
		return [form1, form2]
	end

	def create_only_phi_forms
		form1 = FormStructure.create(name: "form1")
		form2 = FormStructure.create(name: "form2")
		
		ques1 = FormQuestion.create(variable_name: "ques1", prompt: "ques1?", question_type: "text", sequence_number: 1, display_number: "1", personally_identifiable: true)
		ques2 = FormQuestion.create(variable_name: "ques2", prompt: "ques2?", question_type: "date", sequence_number: 2, display_number: "2", personally_identifiable: true)
		ques3 = FormQuestion.create(variable_name: "ques3", prompt: "ques3?", question_type: "text", sequence_number: 1, display_number: "1", personally_identifiable: true)
		ques4 = FormQuestion.create(variable_name: "ques4", prompt: "ques4?", question_type: "date", sequence_number: 2, display_number: "2", personally_identifiable: true)
		
		form1.form_questions << ques1
		form1.form_questions << ques2
		form2.form_questions << ques3
		form2.form_questions << ques4

		create_form_responses(form1, form2, ques1, ques2, ques3, ques4)

		@proj.form_structures << form1
		@proj.form_structures << form2
		form1.save!
		form2.save!
		@proj.save!
	end

	def create_no_form_access
		create_forms_and_questions(true)
		FormPermissionCreator.create(@proj.form_structures[0], {"userEmail" => "jon@test.com", "permissionLevel" => "None"})
		FormPermissionCreator.create(@proj.form_structures[1], {"userEmail" => "jon@test.com", "permissionLevel" => "None"})
		@proj.save!
	end

	def create_partial_form_access
		create_forms_and_questions(true)
		FormPermissionCreator.create(@proj.form_structures[0], {"userEmail" => "jon@test.com", "permissionLevel" => "None"})
		FormPermissionCreator.create(@proj.form_structures[1], {"userEmail" => "jon@test.com", "permissionLevel" => "Full"})
		@proj.save!
	end

	def create_form_responses (f1, f2, q1, q2, q3, q4)
   resp = FormResponse.create(subject_id: "1", form_structure: f1)
   set_reponse_info(resp, q1, "a")
   set_reponse_info(resp, q2, "12/31/2014")
   resp.save!
   resp = FormResponse.create(subject_id: "2", form_structure: f1)
   set_reponse_info(resp, q1, "b")
   set_reponse_info(resp, q2, "1/1/2015")
   resp.save!
   resp = FormResponse.create(subject_id: "1", form_structure: f2)
   set_reponse_info(resp, q3, "c")
   set_reponse_info(resp, q4, "1/1/2015")
   resp.save!
   resp = FormResponse.create(subject_id: "2", form_structure: f2)
   set_reponse_info(resp, q3, "d")
   set_reponse_info(resp, q4, "12/31/2014")
   resp.save!
	end

	def set_reponse_info (resp, ques, answer_val)
		answer = FormAnswer.create(answer: answer_val, form_question: ques)
		resp.form_answers << answer
	end

	def check_query_response(reply, percentage, rows, cols)
		reply["queryInfo"]["percentage"].to_f.should == percentage
		reply["gridHeader"].length.should == cols
		reply["grid"].length.should == rows
	end

end