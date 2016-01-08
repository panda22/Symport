class ProjectsController < ApplicationController
  skip_before_filter :header_authenticate!, only: [:codebook, :query_details]
  before_filter :form_authenticate!, only: [:codebook, :query_details]

  def index
    projects = ProjectLookup.find_projects_for_user current_user
    serialized_projects = projects.map do |project|
      ProjectSerializer.serialize current_user, project, false
    end
    render json: { projects: serialized_projects }
  end

  def update_demo_progress
    demo_data = params[:demoProgress]
    progress = DemoProgress.find(demo_data[:id])
    progress.project_index_global = demo_data[:projectIndexGlobal]
    progress.project_index_demo_project = demo_data[:projectIndexDemoProject]
    progress.form_enter_edit = demo_data[:formEnterEdit]
    progress.enter_edit_subject_id = demo_data[:enterEditSubjectId]
    progress.enter_edit_response = demo_data[:enterEditResponse]
    progress.enter_edit_save = demo_data[:enterEditSave]
    progress.data_tab_emphasis = demo_data[:dataTabEmphasis]
    progress.view_data_sort_search = demo_data[:viewDataSortSearch] 
    progress.create_new_query = demo_data[:createNewQuery]
    progress.build_query_info = demo_data[:buildQueryInfo]
    progress.build_query_params = demo_data[:buildQueryParams]
    progress.query_results_download = demo_data[:queryResultsDownload]
    progress.query_results_breadcrumbs = demo_data[:queryResultsBreadcrumbs]
    progress.form_global = demo_data[:formGlobal]
    progress.team_button = demo_data[:teamButton]
    progress.add_new_team_member = demo_data[:addNewTeamMember]
    progress.add_team_member_personal_details = demo_data[:addTeamMemberPersonalDetails]
    progress.add_team_member_project_permissions = demo_data[:addTeamMemberProjectPermissions]
    progress.add_team_member_form_permissions = demo_data[:addTeamMemberFormPermissions]
    progress.import_button = demo_data[:importButton]
    progress.import_overlays = demo_data[:importOverlays]
    progress.import_csv_text = demo_data[:importCsvText]
    progress.build_form_button = demo_data[:buildFormButton]
    progress.form_builder_info = demo_data[:formBuilderInfo]
    progress.build_form_add_question = demo_data[:buildFormAddQuestion]
    progress.question_builder_prompt = demo_data[:questionBuilderPrompt]
    progress.question_builder_variable = demo_data[:questionBuilderVariable]
    progress.question_builder_identifying = demo_data[:questionBuilderIdentifying]
    progress.save!
    render json: { progress: progress }
  end

  def create_structure
    project = ProjectLookup.find_project current_user, params[:id]
    structure = FormStructureCreator.create(params[:form_structure], current_user, project)
    payload = FormStructureSerializer.serialize current_user, structure, true
    render json: { formStructure: payload }
  end

  def import_sample_data_1
    q_cols = []
    ids = [{sub_id: '1023'}, {sub_id: '1024'}, {sub_id: '1025'}, {sub_id: '1026'}, {sub_id: '1027'}, {sub_id: '1028'}, {sub_id: '1029'}, {sub_id: '1030'}, {sub_id: '1031'}, {sub_id: '1032'}, {sub_id: '1033'}, {sub_id: '1034'}, {sub_id: '1035'}, {sub_id: '1036'}, {sub_id: '1037'}, {sub_id: '1038'}, {sub_id: '1039'}, {sub_id: '1040'}, {sub_id: '1041'}, {sub_id: '1042'}, {sub_id: '1043'}, {sub_id: '1044'}, {sub_id: '1045'}, {sub_id: '1046'}, {sub_id: '1047'}, {sub_id: '1048'}, {sub_id: '1049'}, {sub_id: '1050'}, {sub_id: '1051'}, {sub_id: '1052'}, {sub_id: '1053'}, {sub_id: '1054'}, {sub_id: '1055'}, {sub_id: '1056'}, {sub_id: '1057'}, {sub_id: '1058'}, {sub_id: '1059'}, {sub_id: '1060'}, {sub_id: '1061'}, {sub_id: '1062'}, {sub_id: '1063'}, {sub_id: '1064'}, {sub_id: '1065'}, {sub_id: '1066'}, {sub_id: '1067'}, {sub_id: '1068'}, {sub_id: '1069'}, {sub_id: '1070'}, {sub_id: '1071'}] 
    headers = ['Children' ,'Email', 'Attmited', 'Income', 'Anxiety_Level', 'Ethnicity', 'Marital_Status', 'Resting_Heart_Rate', 'Hemoglobin_Level_Grams_Per_Deciliter', 'Blood_Pressure_Systolic', 'Blood_Pressure_Diastolic', 'Education', 'Zip_Code', 'Average_Sleep_Duration', 'Phone_Number', 'Gender', 'Health_Insurance']
    answer_columns = [
      ['4','6','4','6','4','6','4','2','2','4','2','1','5','5','1','3','4','2','2','5','2','4','1','2','5','6','5','5','3','3','4','2','4','3','1','1','4','2','5','2','3','1','2','4','3','3','5','3','2'],
      ['alexgmail.com','david@yahoo.com','jennifer@bing.com','jane@godaddy.com','john@gmail.com','lisa@yahoo.com','susan@yahoo.com','bob@gmailcom','harry@yahoo.com','carol@bing.com','fatima@icloud.com','claudia@umich.edu','jason@uic.edu','jerry@icloud.com','rain@gmail.com','symport@mntnlabs.com','ben@gmail.com','rufus@yahoo.com','buster@yahoo.com','ken@gmail.com','shane@icloud.com','sherry@','baldwin@gmail.com','paul@yahoo.com','kip@gmail.com','drake@bing.com','jay@bing.com','connor@yahoo.com','dre@me.com','tyler@yahoo.com','tracy@gmail.com','zach@yahoo.com','neil@icloud.com','barret@bing.com','wesley@yahoo.com','gabe@umich.edu','gary@gmail.com','nelson@google.com','dominic@gmail.com','nathan@me.com','valentine@yahoo.net','tate@gmail.com','terrance@yahoo.com','rudolph@gmail.com','royce@rolls.com','frank@yahoo.com','alvin@gmail.com','barb@gmail.com','help@desk.com'],
      ['No','Yes','Yes','Yes','No','No','No','Yes','No','Yes','No','No','Yes','Yes','Yes','No','No','No','Yes','No','Yes','No','No','Yes','Yes','Yes','No','No','No','Yes','No','Yes','No','No','Yes','Yes','Yes','No','No','No','Yes','No','Yes','No','No','Yes','Yes','Yes','No'],
      ['$79,210.47','$82,789.00','$93,397.08','$93,217.24','$73,764.11','$83,699.66','$99,771.34','$85,500.23','$89,412.36','$79,555.27','$91,197.88','$81,632.13','$90,135.51','$96,491.48','$83,723.96','$89,497.65','$88,580.75','$77,855.00','$88,888.34','$74,979.46','$81,543.42','$87,878.36','$98,721.05','$97,548.17','$81,669.41','$78,504.78','$82,032.14','$90,413.35','$85,616.84','$96,406.30','$86,334.55','$85,885.98','$74,723.30','$83,501.33','$91,681.13','$91,215.15','$81,410.26','$82,404.33','$93,480.54','$85,407.54','$89,041.82','$93,125.77','$84,506.29','$97,283.43','$83,738.06','$74,072.00','$71,605.47','$75,512.41','$82,333.56'],
      ['4','3','5','9','4','6','4','8','10','5','2','10','5','5','1','3','7','2','1','3','3','9','10','6','1','1','10','8','9','3','3','9','6','6','9','2','6','4','7','5','2','4','7','6','5','2','7','8','3'],
      ["African American","Caucasian","Caucasiaan","Hispanic or Latino","Asian or Pacific Islander","Hispanic or Latino","Hispanic or Latino","Caucasian","African American","Native American or American Indian","Native American or American Indian","African American","Caucasian","Hispanic or Latino","Caucasian","Asian or Pacific Islander","Caucasian","African American","Caucasian","Native American or American Indian","Asian or Pacific Islander","Hispanic or Latino","Native American or American Indian","Asian or Pacific Islander","Africaan American","Assian or Pacific Islander","Native American or American Indian","African American","Hispanic or Latino","Caucasian","African American","Caucasian","Caucasian","Hispanic or Latino","Asian or Pacific Islander","Caucasian","Caucasian","Native American or American Indian","African American","Asian or Pacific Islander","Asian or Pacific Islander","Asian or Pacific Islander","Caucasian","African American","Asian or Pacific Islander","Asian or Pacific Islander","Hispanic or Latino","Asian or Pacific Islander","Caucasian"],
      ['Married','Common-Law','Married','Single','Married','Common-Law','Common-Law','Divorced','Common-Law','Single','Common-Law','Divorced','Common-Law','Single','Divorced','Divorced','Common-Law','Divorced','Married','Single','Married','Single','Common-Law','Divorced','Common-Law','Single','Divorced','Married','Single','Common-Law','Married','Married','Divorced','Single','Married','Common-Law','Single','Divorced','Common-Law','Common-Law','Divorced','Married','Divorced','Single','Single','Single','Single','Common-Law','Married'],
      ['98','79','74','84','82','76','79','86','78','96','68','71','83','74','84','70','72','70','89','94','73','76','91','80','96','70','99','68','60','99','85','74','97','79','69','66','91','62','99','63','60','81','100','84','78','75','98','91','66'],
      ['13','13','14','12','17','13','15','14','12','18','13','13','17','12','14','12','12','15','12','18','18','16','13','17','17','17','17','12','13','15','17','17','18','18','13','16','15','18','15','16','18','13','16','15','16','12','14','18','14'],
      ['60','94','81','57','120','101','102','58','75','111','60','86','112','76','115','69','84','72','73','50','53','87','73','53','107','106','59','84','69','93','84','86','54','110','89','112','82','78','83','44','68','106','91','86','57','62','53','51','64'],
      ['80','68','51','51','62','75','64','58','78','65','77','62','66','72','57','77','75','69','65','62','54','55','80','75','63','64','63','56','67','54','77','70','70','75','65','79','79','67','56','65','66','56','52','72','77','77','75','80','54'],
      ["Master's Degree","Bachelor's Degree","High School/GED","Master's Degree","Master's Degree","High School/GED","Some College","Some College","Some College","Some College","Bachelor's Degree","Ph.D.","Bachelor's Degree","Some College","Bachelor's Degree","Bachelor's Degree","Some College","Master's Degree","High School/GED","High School/GED","Ph.D.","High School/GED","High School/GED","Some College","Some College","Master's Degree","Ph.D.","High School/GED","Ph.D.","Bachelor's Degree","Master's Degree","Bachelor's Degree","Some College","Bachelor's Degree","Ph.D.","High School/GED","Some College","Some College","Master's Degree","Ph.D.","Some College","Some College","Some College","High School/GED","Bachelor's Degree","Ph.D.","Ph.D.","High School/GED","High School/GED"],
      ['88544','12300','87630','21925','3812','88544','12300','87630','21925','88544','12300','87630','21925','472','88544','12300','87630','21925','88544','12300','87630','21925','8582','88544','12300','87630','21925','88544','12300','87630','21925','87630','88544','12300','87630','21925','88544','12300','87630','21925','912','88544','12300','87630','21925','88544','12300','87630','21925'],
      ['12','6','7','10','13','4','2','5','5','3','3','6','9','5','10','4','12','9','5','13','5','10','4','13','1','4','9','3','5','4','1','5','5','12','2','12','3','11','2','10','3','5','8','8','8','6','12','9','7'],
      ['406-721-6479','645-987-3940','374-946-2553','564-420-5297','387-868-3467','609-645-6210','678-696-4768','453-771-6068','472-457-5137','674-567-1877','134-202-6660','662-198-1962','820-882-4075','984-641-4314','850-115-9018','788-996-1594','514-323-1345','406-721-6479','645-987-3940','374-946-2553','564-420-5297','387-868-3467','609-645-6210','678-696-4768','453-771-6068','472-457-5137','674-567-1877','134-202-6660','662-198-1962','820-882-4075','984-641-4314','850-115-9018','788-996-1594','514-323-1345','406-721-6479','645-987-3940','374-946-2553','564-420-5297','387-868-3467','609-645-6210','678-696-4768','453-771-6068','472-457-5137','674-567-1877','134-202-6660','662-198-1962','820-882-4075','984-641-4314','850-115-9018'],
      ['Other','Female','Female','Male','Female','Other','Male','Male','Male','Male','Female','Female','Other','Other','Male','Female','Female','Female','Other','Male','Other','Male','Male','Female','Female','Other','Other','Female','Male','Male','Other','Male','Female','Female','Male','Female','Female','Male','Female','Female','Male','Other','Male','Male','Other','Male','Female','Other','Male'],
      ['No','No','No','Yes','Yes','Yes','No','Yes','Yes','No','Yes','No','No','Yes','No','Yes','No','Yes','No','Yes','No','No','Yes','Yes','No','Yes','Yes','No','No','No','Yes','Yes','No','No','Yes','Yes','No','Yes','No','No','Yes','No','No','No','Yes','Yes','Yes','No','Yes']]
    i = 0
    headers.each do |h|
      q_cols.push({question_id: nil, question_type: nil, header: h, other_option_header: nil, other_option_value: nil, answers: answer_columns[i]})
      i = i + 1
    end
    params[:import_struct][:subject_ids] = ids
    params[:import_struct][:question_columns] = q_cols
    import_responses()
  end

  def import_sample_data_2
    q_cols = []
    ids = [{sub_id: '1023', sec_id: '1/12/2015'},{sub_id: '1023', sec_id: '2/13/2015'},{sub_id: '1025', sec_id: '1/12/2015'},{sub_id: '1025', sec_id: '2/13/2015'},{sub_id: '1027', sec_id: '1/12/2015'},{sub_id: '1027', sec_id: '2/13/2015'},{sub_id: '1027', sec_id: '5/12/2015'},{sub_id: '1030', sec_id: '1/12/2015'},{sub_id: '1030', sec_id: '2/13/2015'},{sub_id: '1032', sec_id: '1/12/2015'},{sub_id: '1032', sec_id: '2/13/2015'},{sub_id: '1034', sec_id: '1/12/2015'},{sub_id: '1034', sec_id: '2/13/2015'},{sub_id: '1036', sec_id: '1/12/2015'},{sub_id: '1036', sec_id: '5/12/2015'},{sub_id: '1038', sec_id: '1/12/2015'},{sub_id: '1038', sec_id: '2/13/2015'},{sub_id: '1038', sec_id: '5/12/2015'},{sub_id: '1040', sec_id: '1/12/2015'},{sub_id: '1040', sec_id: '2/13/2015'},{sub_id: '1040', sec_id: '5/12/2015'},{sub_id: '1040', sec_id: '6/13/2015'},{sub_id: '1042', sec_id: '1/12/2015'},{sub_id: '1042', sec_id: '2/13/2015'},{sub_id: '1042', sec_id: '5/12/2015'},{sub_id: '1042', sec_id: '6/14/2015'},{sub_id: '1050', sec_id: '1/12/2015'},{sub_id: '1050', sec_id: '2/13/2015'},{sub_id: '1050', sec_id: '5/12/2015'},{sub_id: '1052', sec_id: '1/12/2015'},{sub_id: '1052', sec_id: '2/13/2015'},{sub_id: '1054', sec_id: '1/12/2015'},{sub_id: '1054', sec_id: '2/13/2015'},{sub_id: '1056', sec_id: '1/12/2015'},{sub_id: '1056', sec_id: '2/13/2015'},{sub_id: '1058', sec_id: '1/12/2015'},{sub_id: '1058', sec_id: '2/13/2015'},{sub_id: '1060', sec_id: '1/12/2015'},{sub_id: '1060', sec_id: '2/13/2015'},{sub_id: '1062', sec_id: '1/12/2015'},{sub_id: '1062', sec_id: '2/13/2015'},{sub_id: '1064', sec_id: '1/12/2015'},{sub_id: '1064', sec_id: '2/13/2015'},{sub_id: '1066', sec_id: '1/12/2015'},{sub_id: '1066', sec_id: '2/13/2015'},{sub_id: '1068', sec_id: '1/12/2015'},{sub_id: '1068', sec_id: '2/13/2015'},{sub_id: '1070', sec_id: '1/12/2015'},{sub_id: '1070', sec_id: '2/13/2015'}]
    headers = ['Children','Resting Heart Rate','Stress Level','Hemoglobin Level Grams Per Deciliter','Blood Pressure Systolic','Blood Pressure Diastolic','Average Sleep Duration','Bed Time','Wakeup Time','Height in inches','Pain Level','Admitted']

    answers = [
      ['1','1','4','4','2','2','2','3','3','1','1','1','1','1','1','1','1','1','1','1','1','1','4','4','4','4','3','3','3','4','4','1','1','1','1','1','1','3','3','2','2','2','2','2','2','3','3','3','3'],
      ['a80','102','aa90','91','aa80','aa67','66','aa99','61','aa57','84','102','109','98','105','66','97','107','109','70','107','86','50','85','64','110','64','79','90','101','53','91','52','63','106','70','103','110','60','96','68','73','110','61','67','63','68','110','55'],
      ['High','Very High','Very High','Very High','Low','Medium','High','Very High','Very High','Medium','Medium','Medium','Medium','Very High','Very High','High','Very High','Very High','Very High','High','High','Medium','Very High','High','Very High','Low','Very High','Very High','Medium','High','High','Medium','Low','High','Very High','Medium','Low','High','Low','Medium','Low','Very High','High','Low','Low','Medium','Very High','Very High','Low'],
      ['10','14','10','13','16','12','13','17','16','15','13','15','12','16','12','17','17','15','15','16','18','13','11','16','16','16','13','16','13','18','16','14','14','15','15','17','13','13','10','16','17','17','16','15','10','16','16','17','14'],
      ['132','103','133','133','107','aa82','80','135','111','81','aa99','124','139','126','133','114','104','127','97','81','93','123','98','108','86','95','108','121','117','93','134','94','113','82','140','134','113','114','96','85','116','83','126','110','96','130','115','129','117'],
      ['66','85','83','75','67','75','79','81','81','80','71','88','66','80','80','78','65','85','70','70','70','86','79','74','63','74','80','60','73','82','86','62','75','79','80','89','86','72','82','90','68','61','76','76','76','67','85','78','64'],
      ['6','9','aa6','6','6','aa6','9','10','aa9','9','7','9','10','9','7','8','9','8','9','9','7','9','10','9','10','7','7','10','7','6','9','10','8','6','10','9','10','10','8','8','8','9','8','7','8','9','7','6','6'],
      ['9:00 PM','9:00 PM','9:00 PM','10:00 PM','10:00 PM','10:00 PM','11:00 PM','11:00 PM','11:00 PM','12:00 PM','12:00 PM','12:00 PM','1:00 AM','1:00 AM','1:00 AM','9:00 AM','9:00 AM','9:00 AM','10:00 PM','10:00 PM','10:00 PM','10:00 PM','10:00 PM','10:00 PM','11:00 AM','12:00 PM','12:00 PM','1:00 AM','1:00 AM','1:00 AM','9:00 AM','9:00 AM','9:00 AM','10:00 PM','10:00 PM','10:00 PM','11:00 PM','11:00 PM','11:00 PM','12:00 PM','12:00 PM','12:00 PM','1:00 AM','1:00 AM','1:00 AM','9:00 AM','9:00 AM','9:00 AM','10:00 PM'],
      ['6:00 AM','6:00 AM','6:00 AM','7:00 AM','7:00 AM','7:00 AM','8:00 AM','8:00 AM','8:00 AM','9:00 AM','9:00 AM','9:00 AM','10:00 AM','10:00 AM','10:00 AM','6:00 AM','6:00 AM','6:00 AM','7:00 AM','7:00 AM','7:00 AM','8:00 AM','8:00 AM','8:00 AM','9:00 AM','9:00 AM','9:00 AM','10:00 AM','10:00 AM','10:00 AM','6:00 AM','6:00 AM','6:00 AM','7:00 AM','7:00 AM','7:00 AM','8:00 AM','8:00 AM','8:00 AM','9:00 AM','9:00 AM','9:00 AM','10:00 AM','10:00 AM','10:00 AM','6:00 AM','6:00 AM','6:00 AM','7:00 AM'],
      ['61','61','67','67','66','66','66','64','64','69','71','66','66','61','62','61','61','61','71','71','71','71','67','67','67','67','70','70','70','64','64','72','72','65','65','60','60','70','70','62','62','65','65','70','70','70','72','72','72'],
      ['9','4','7','2','2','4','10','9','9','9','8','6','5','5','2','1','7','4','4','9','6','10','8','2','7','6','7','2','1','9','3','3','5','2','3','4','5','3','2','8','3','8','7','6','2','8','1','1','9'],
      ['Yes','No','Yes','No','Yes','No','Yes','No','Yes','No','No','No','No','Yes','Yes','No','No','Yes','Yes','Yes','No','No','No','No','Yes','No','Yes','Yes','No','No','Yes','Yes ','Yes ','Yes ','No','Yes ','Yes ','Yes ','No','No','No','Yes ','Yes ','Yes ','No','Yes ','Yes ','No','No']
    ]
    i = 0
    headers.each do |h|
      q_cols.push({question_id: nil, question_type: nil, header: h, other_option_header: nil, other_option_value: nil, answers: answers[i]})
      i = i + 1
    end
    params[:import_struct][:subject_ids] = ids
    params[:import_struct][:question_columns] = q_cols
    import_responses()
  end

  def import_responses
    right_now = Time.now.utc.to_s
    project = ProjectLookup.find_project current_user, params[:id]
    data = params[:import_struct]
    file_name = data[:file_name]
    struct_info = data[:struct]
    subjects_column = data[:subject_ids]
    questions_columns = data[:question_columns]
    if struct_info[:id] && struct_info[:id] != ""
      structure = FormBuilderLookup.find_structure(current_user, struct_info[:id])
    else
      structure = FormRecordCreator.create_structure(project, struct_info)
    end
    struct_id = structure.id
    if !Permissions.user_can_enter_form_responses_for_form_structure?(current_user, structure)
      raise PayloadException.access_denied "You do not have access to edit responses for this form"
    end
    new_questions = []
    project = Project.find(structure.project_id)
    cur_qs = project.form_questions.order(sequence_number: :desc)
    current_question_display_numbers = cur_qs.where(form_structure_id: struct_id).pluck(:sequence_number)
    current_question_variable_names = cur_qs.pluck(:variable_name)
    current_other_variable_names = project.option_configs.where('other_variable_name is not NULL').pluck(:other_variable_name)
    used_variable_names = current_question_variable_names + current_other_variable_names
    sequence_number = current_question_display_numbers[0] ||  0
    questions_columns.each do |col|
      answers = col[:answers]
      if answers.length != subjects_column.length 
        raise PayloadException.new 422, "question's answers' lengths do not match subject_ids' length" 
      end
      if col[:question_id] == "" || !col[:question_id]
        q_suggestion = QuestionTypeSuggestor.suggest_question_type(answers)
        sequence_number += 1
        variable_name = col[:header]
        if(used_variable_names.include?(variable_name))
          var_incr = 1
          final_var = variable_name
          while(used_variable_names.include?(final_var))
            final_var = variable_name + "_" + var_incr.to_s
            var_incr += 1
          end
          variable_name = final_var
          used_variable_names.append(variable_name)
        end
        if q_suggestion[0] == "text"
          config = {size: 'large'}
        elsif q_suggestion[0] == "numericalrange"
          config = {minValue: nil, maxValue: nil, precision: 6}
        elsif ["radio", "checkbox", "yesno", "dropdown"].include?(q_suggestion[0])
          config = q_suggestion[1]
          if q_suggestion[0] == "checkbox"
            col[:answers] = q_suggestion[2]
          end
        else
          config = {}
        end
        variable_name = variable_name.split("").map do |c|
          if (c >= "A" && c <= "z") || (c >= "0" && c <= "9") || c == "_"
            c
          else
            "_"
          end
        end.join("")
        question_data = { 
            type: q_suggestion[0], 
            sequenceNumber: sequence_number,
            variableName: variable_name,
            prompt: variable_name,
            description: "",
            personallyIdentifiable: false,
            displayNumber: sequence_number,
            conditions: [],
            exceptions: [],
            config: config
          }
        new_question = FormRecordCreator.create_question(question_data, structure)
        col[:question_id] = new_question.id
      end
    end
    if structure.is_many_to_one
      subject_ids = subjects_column.map do |o|
        [o["sub_id"], o["sec_id"]]
      end
      responses = FormResponseLookup.find_many_responses_in_form_structure_by_subject_and_secondary_ids(current_user, structure, subject_ids)
    else
      subject_ids = subjects_column.map do |o|
        o["sub_id"]
      end
      responses = FormResponseLookup.find_many_responses_in_form_structure_by_subject_ids(current_user, structure, subject_ids)
    end
    right_now = Time.now.utc.to_s
    imported_questions_ids = []
    subject_id_to_num_instances_hash = FormResponse.where(form_structure_id: structure.id).select(:subject_id).group(:subject_id).count
    validate_structs = {}
    FormResponse.transaction do
      i = 0
      j = 0
      k = 0
      new_responses_data = []
      new_answer_records = []
      responses.each do |response|
        all_answers_for_subject_hash = {}
        if response.nil?
          r_id = SecureRandom.uuid
          if structure.is_many_to_one
            if !subject_id_to_num_instances_hash[subject_ids[i][0]]
              subject_id_to_num_instances_hash[subject_ids[i][0]] = 0
            end
            new_responses_data[k] = "'#{r_id}', '#{structure.id}', '#{right_now}', '#{right_now}', #{FormResponse.sanitize(subject_ids[i][0])}, #{FormResponse.sanitize(subject_ids[i][1])}, '#{subject_id_to_num_instances_hash[subject_ids[i][0]]}'"
            subject_id_to_num_instances_hash[subject_ids[i][0]] += 1
          else
            new_responses_data[k] = "'#{r_id}', '#{structure.id}', '#{right_now}', '#{right_now}', #{FormResponse.sanitize(subject_ids[i])}, NULL, '0'"
          end
          k = k + 1
        else
          r_id = response.id
          all_answers_for_subject = FormAnswer.where(form_response_id: r_id)
          all_answers_for_subject.each do |a|
            all_answers_for_subject_hash[a.form_question_id] = a
          end
        end

        for col in questions_columns
          q_id = col[:question_id]
          if i == 0
            imported_questions_ids.push q_id
            validate_structs[q_id] = {answer_records: [], answer_values: [], question: FormQuestion.find(q_id)}
          end
          answer = col[:answers][i]
          answer_record = all_answers_for_subject_hash[q_id] 
          if answer_record.nil?
            validate_structs[q_id][:answer_values].push(answer)
            validate_structs[q_id][:answer_records].push(FormAnswer.new({form_question_id: q_id, form_response_id: r_id, answer: answer, created_at: right_now, updated_at: right_now}))
          elsif answer.strip != "" 
            validate_structs[q_id][:answer_values].push(answer)
            validate_structs[q_id][:answer_records].push(FormAnswer.new({form_question_id: q_id, form_response_id: r_id, answer: answer, created_at: answer_record.created_at, updated_at: right_now}))
          end
        end
        i = i + 1
      end
      unless k == 0
        sql = "INSERT INTO form_responses (id, form_structure_id, created_at, updated_at, subject_id, secondary_id, instance_number) VALUES (#{new_responses_data.join("), (")})"
        FormResponse.connection.execute sql
      end
      for col in questions_columns
        stuff = validate_structs[col[:question_id]]
        answer_records = stuff[:answer_records]
        answer_values = stuff[:answer_values]
        question = stuff[:question]
        FormAnswerProcessor.validate_and_save_all(current_user, question, answer_records, answer_values)
      end
      AuditLogger.import(current_user, structure, params[:import_struct][:file_name], subject_ids, imported_questions_ids)
    end
    render json: { success: true }
  end


  def can_view_phi
    proj = Project.find_by(id: params[:id])
    render json: {
      view_phi: Permissions.user_can_view_personally_identifiable_answers_for_project?(current_user, proj)
    }
  end

  def errors_for_question
    question = FormQuestion.find(params[:question_id])
    structure = FormStructure.find(question.form_structure_id)
    #structure = FormBuilderLookup.find_structure(current_user, question.form_structure_id)
    if !Permissions.user_can_enter_form_responses_for_form_structure?(current_user, structure)
      raise PayloadException.access_denied "You do not have access to edit responses for this form"
    end
    results = []
    answers = params[:answers]
    for answer in answers
      fake_answer_record = FormAnswer.new({form_question_id: question.id})
      error = nil
      exception = FormAnswerExceptor.check_exceptions(question, fake_answer_record, answer, false)
      if !exception
        error = FormAnswerValidator.validate(question, answer)
      else 
        error = "*^*^\u200c#{fake_answer_record.regular_exception}\u200c#{fake_answer_record.day_exception}\u200c#{fake_answer_record.month_exception}\u200c#{fake_answer_record.year_exception}"
      end
      results.push error
    end
    pwd = get_q_pass(question.id, answers.length)
    render json: {errors: results, pwd: pwd}
  end

  def create
    project = ProjectCreator.create(current_user, params[:project])
    render json: { project: ProjectSerializer.serialize(current_user, project, true) }
  end

  def show
    project = ProjectLookup.find_project current_user, params[:id]
    render json: { project: ProjectSerializer.serialize(current_user, project, true) }
  end

  def update
    original_project = ProjectLookup.find_project current_user, params[:id]
    updated_project = ProjectUpdater.update params[:project], current_user, original_project
    render json: { project: ProjectSerializer.serialize(current_user, updated_project, true) }
  end

  def known_subjects
    project = ProjectLookup.find_project current_user, params[:id]
    subjects = SubjectLookup.known_subjects_of_project project
    render json: { subjects: subjects }
  end

  def destroy
    project = ProjectLookup.find_project(current_user, params[:id])
    ProjectDestroyer.destroy(current_user, project)
    render json: {}
  end

  def rename_subject_id
    project = ProjectLookup.find_project(current_user, params[:id])
    ProjectUpdater.rename_subject_id(current_user, project, params[:oldSubjectID], params[:newSubjectID])
    render json: {}
  end


  def query_details
    project = Project.find(params[:id])
    query = JSON params[:queryInfo]
    details = {}
    details[:params] = []
    begin
      details[:name] = Query.find(params["query_id"]).name
    rescue
      details[:name] = ""
    end
    details[:sub_line] = "#{query["percentage"]}% | #{query["partial"]} Subject IDs fit the query, out of #{query["total"]} total"
    details[:secondary_lines] = []
    query["instanceInfo"].each do |instance_info|
      details[:secondary_lines].push("#{instance_info["percent"]} | #{instance_info["matching"]} #{instance_info["secondaryId"]}(s) fit the query, out of #{instance_info["total"]} total")
    end
    removed = query["removed"]
    if removed
      details[:sub_exc] = "#{removed} Subject IDs were excluded due to codes set for missing, unknown, or skipped values"
    else
      details[:sub_exc] = ""
    end
    details[:andor] = query["conjunction"]
    if query["queriedForms"] == []
      details[:form_string] = "None"
    else
      str = ""
      query["queriedForms"].each do |f|
        str = str + f
      end
      details[:form_string] = str
    end
    query["params"].each do |param|
      details[:params].push({ n: param["n"], text: "In #{param["formName"]}, (#{param["questionName"]}) #{param["operator"]} #{param["value"]}"} )
    end
    date = params[:date]
    time = params[:time]

    header_string = "Query printed by #{current_user.first_name} #{current_user.last_name} on #{date} at #{time}"

    file_name = "#{project.name}_query_details_#{date}_#{time.gsub(" ", "-")}".gsub(" ", "_").downcase

    codebook = QueryDetailsExportBuilder.generate_query_details(details, project.name, header_string)

    cookies[:labcompass_download_file] = "success"

    send_data(codebook, :filename => "#{file_name}.pdf", :type => "application/pdf")

  end

  def codebook
    project = Project.find(params[:id])
    empty = params[:empty_code]
    closed = params[:closed_code]
    date = params[:date]
    time = params[:time]

    header_string = "Created by #{current_user.first_name} #{current_user.last_name} on #{date} at #{time}"


    all_structures = FormStructure.where(project_id: project.id)
    desired_structs = get_desired_structs(JSON.parse(params[:forms])["queriedForms"])
    structs = []

    all_structures.each do |struct|
      if desired_structs[struct.id]
        if !Permissions.user_can_see_form_structure?(current_user, struct)
          raise PayloadException.access_denied "You do not have access to this form"
        end
        structs.push struct
      end
    end


    file_name = "#{project.name}_codebook_#{date}_#{time.gsub(" ", "-")}".gsub(" ", "_").downcase

    codebook = ProjectCodebookBuilder.generate_codebook(project, structs, empty, closed, header_string)

    cookies[:labcompass_download_file] = "success"

    send_data(codebook, :filename => "#{file_name}.pdf", :type => "application/pdf")

  end


  private
    def get_q_pass(q_id, length_seed)
      pwd = q_id.dup
      pwd[length_seed% 9] = '-'
      return pwd
    end

    def get_desired_structs(query_form_array)
      result = {}
      for query_form in query_form_array
        result[query_form["formID"]] = query_form["included"]
      end
      result
    end
end
