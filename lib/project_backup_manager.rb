class ProjectBackupManager
  class << self

    def backup_project_from_days_ago(old_id, num_days_back)
      if num_days_back < 1 || num_days_back > 20
        return puts "Bad Number"
      end
      backups = ProjectBackup.where(project_id: old_id).order(created_at: :desc)
      if backups == []
        puts "NO BACKUPS"
        return
      end
      backup = backups[num_days_back-1]
      old_project = Project.unscoped.find(old_id)
      puts "\n____________________________________________\nBACKING UP PROJECT...."
      puts "ID: #{old_project.id}"
      puts "NAME: #{old_project.name}"
      puts "TO DATE: #{backup.created_at}"
      puts "IS THIS CORRECT??? 'yes' if yes"
      puts "..."
      yes = gets
      puts "__________________________________________________________________________________________\n\n"
      unless yes.chomp == "yes"
        puts "\n____________________________________________\nABORTING BACKUP"
      puts "__________________________________________________________________________________________\n\n"
        return
      end
      new_id = SecureRandom.uuid
      create_project_from_xml(backup.project_content, new_id)
      new_project = Project.find(new_id)
      puts "\n____________________________________________\nSUCCESS INSERTING PROJECT!"
      puts "NEW PROJECT: #{new_project.id}"
      puts "__________________________________________________________________________________________\n\n"
      backups.each do |b|
        b.project_id = new_id
        b.save!
      end
      puts "\n____________________________________________\nBACKUPS F.K. updated"
      puts "__________________________________________________________________________________________\n\n"
      unless old_project.deleted?
        old_project.destroy!
      end
      puts "\n____________________________________________\nORIGINAL DELETED PROJECT'S ID: #{old_project.id}"
      puts "__________________________________________________________________________________________\n\n"

    end

    def create_xml_backup_for_project(id)
      project = Project.find(id)

      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml.root {
          xml.project(:id => project.id, :created_at => project.created_at, :updated_at => project.updated_at) {
            
            xml.name project.name

            xml.team_members {
              for team_member in project.team_members
                
                xml.team_member(:id => team_member.id, :created_at => team_member.created_at, :updated_at => team_member.updated_at) {
                  xml.user_id                              team_member.user_id
                  xml.expiration_date                      team_member.expiration_date
                  xml.administrator                        team_member.administrator
                  xml.form_creation                        team_member.form_creation
                  xml.audit                                team_member.audit
                  xml.export                               team_member.export
                  xml.view_personally_identifiable_answers team_member.view_personally_identifiable_answers
                }

              end
            }

            xml.form_structures {
              for form in project.form_structures
                
                xml.form_structure(:id => form.id, :created_at => form.created_at, :updated_at => form.updated_at) {
                  
                  xml.name                    form.name
                  xml.is_many_to_one          form.is_many_to_one
                  xml.secondary_id            form.secondary_id
                  xml.is_secondary_id_sorted  form.is_secondary_id_sorted

                  xml.form_structure_permissions {
                    for perm in form.form_structure_permissions
                      
                      xml.form_structure_permission(:id => perm.id, :created_at => perm.created_at, :updated_at => perm.updated_at){
                        xml.team_member_id   perm.team_member_id
                        xml.permission_level perm.permission_level
                      }

                    end
                  }

                  xml.form_questions {
                    for question in form.form_questions

                      xml.form_question(:id => question.id, :created_at => question.created_at, :updated_at => question.updated_at){

                        xml.prompt                  question.prompt
                        xml.description             question.description
                        xml.sequence_number         question.sequence_number
                        xml.display_number          question.display_number
                        xml.variable_name           question.variable_name
                        xml.question_type           question.question_type
                        xml.personally_identifiable question.personally_identifiable

                        type = question.question_type
                        if type == "checkbox" || type == "radio" || type == "dropdown"
                          xml.option_configs {
                            for option in question.option_configs.order(:index)
                              
                              xml.option_config(:id => option.id, ) {
                                xml.value               option.value
                                xml.code                option.code
                                xml.other_option        option.other_option
                                xml.other_variable_name option.other_variable_name
                              }

                            end
                          }
                        elsif type == "numericalrange"
                          range_config = question.numerical_range_config
                          xml.numerical_range_config(:id => range_config.id){
                            xml.precision     range_config.precision
                            xml.minimum_value range_config.minimum_value
                            xml.maximum_value range_config.maximum_value
                          }
                        elsif type == "text"
                          text_config = question.text_config
                          xml.text_config(:id => text_config.id) {
                            xml.size text_config.size
                          }
                        end                              
                      
                        xml.form_question_conditions {
                          for condition in question.form_question_conditions

                            xml.form_question_condition(:id => condition.id) {
                              xml.value         condition.value
                              xml.operator      condition.operator
                              xml.depends_on_id condition.depends_on_id
                             }

                          end
                        }

                        xml.question_exceptions {
                          for exception in question.question_exceptions

                            xml.question_exception(:id => exception.id, :created_at => exception.created_at, :updated_at => exception.updated_at) {
                              xml.value           exception.value
                              xml.label           exception.label
                              xml.exception_type  exception.exception_type
                            }

                          end
                        }
                      }

                    end
                  }
                }

              end
            }
            GC.start()
            xml.form_responses {
              for form in project.form_structures
                for form_response in form.form_responses

                  xml.form_response(:id => form_response.id, :created_at => form_response.created_at, :updated_at => form_response.updated_at){

                    xml.subject_id        form_response.subject_id
                    xml.form_structure_id form_response.form_structure_id
                    xml.instance_number   form_response.instance_number
                    xml.secondary_id      form_response.secondary_id

                    xml.answers {
                      for form_answer in form_response.form_answers
                        if form_answer.form_question
                          xml.form_answer(:id => form_answer.id, :created_at => form_answer.created_at, :updated_at => form_answer.updated_at){
                            xml.answer           form_answer.answer
                            xml.form_question_id form_answer.form_question_id
                          }
                        end
                      end
                    }
                  }

                end
              end
            }
          }
        }
      end.to_xml
    end

    def create_project_from_xml(xml, new_project_id)
      xml = Nokogiri::XML.parse(xml)
      
      project = get_project_from_xml(xml.xpath("//project"))
      project_sql = "INSERT INTO projects (id, name, updated_at, created_at) VALUES ('#{new_project_id}', #{Project.sanitize(project[:name])},'#{project[:updated_at]}','#{project[:created_at]}')"

      form_structures = get_form_structures_from_xml(xml.xpath("//form_structure"), new_project_id)
      new_forms_ids = {}
      form_structures.each do |form|
        id = new_forms_ids[form[:id]] = SecureRandom.uuid
        form[:id] = id
      end
      structures_string = stringify_structures(form_structures)
      form_structures_sql = "INSERT INTO form_structures (id, project_id, name, is_many_to_one, secondary_id, is_secondary_id_sorted, updated_at, created_at) VALUES (#{structures_string.join("), (")})"
      form_structures_sql.gsub!("''", "NULL")

      team_members = get_team_members_from_xml(xml.xpath("//team_member"), new_project_id)
      team_members_sql = "INSERT INTO team_members (project_id, user_id, expiration_date, view_personally_identifiable_answers, administrator, form_creation, export, audit, updated_at, created_at) VALUES (#{team_members.join("), (")})"
      team_members_sql.gsub!("''", "NULL")

      form_permissions = get_form_permissions_from_xml(xml.xpath("//form_structure_permission"), new_forms_ids)
      form_permissions_sql = "INSERT INTO form_structure_permissions (form_structure_id, team_member_id, permission_level, updated_at, created_at) VALUES (#{form_permissions.join("), (")})"

      questions = get_form_questions_from_xml(xml.xpath("//form_question"), new_forms_ids)
      new_questions_ids = {}
      questions.each do |q|
        id = new_questions_ids[q[:id]] = SecureRandom.uuid
        q[:id] = id
      end
      question_strings = stringify_questions(questions)
      questions_sql = "INSERT INTO form_questions (id, form_structure_id, prompt, description, sequence_number, personally_identifiable, variable_name, display_number, question_type, updated_at, created_at) VALUES (#{question_strings.join("), (")})"

      text_configs = get_text_configs_from_xml(xml.xpath("//text_config"), new_questions_ids)
      text_configs_sql = "INSERT INTO text_configs (form_question_id, size) VALUES (#{text_configs.join("), (")})"

      range_configs = get_range_configs_from_xml(xml.xpath("//numerical_range_config"), new_questions_ids)
      range_configs_sql = "INSERT INTO numerical_range_configs (form_question_id, minimum_value, maximum_value, precision) VALUES (#{range_configs.join("), (")})"
      range_configs_sql.gsub!("''", "NULL")
      
      option_configs = get_option_configs_from_xml(xml.xpath("//option_config"), new_questions_ids)
      option_configs_sql = "INSERT INTO option_configs (form_question_id, index, value, other_option, code, other_variable_name) VALUES (#{option_configs.join("), (")})"

      question_conditions = get_question_conditions_from_xml(xml.xpath("//form_question_condition"), new_questions_ids)
      question_conditions_sql = "INSERT INTO form_question_conditions (form_question_id, depends_on_id, operator, value) VALUES (#{question_conditions.join("), (")})"

      question_exceptions = get_question_exceptions_from_xml(xml.xpath("//question_exception"), new_questions_ids)
      question_exceptions_sql = "INSERT INTO question_exceptions (form_question_id, label, exception_type, value) VALUES (#{question_exceptions.join("), (")})"

      responses = get_form_responses_from_xml(xml.xpath("//form_response"), new_forms_ids)
      new_responses_ids = {}
      responses.each do |resp|
        id = new_responses_ids[resp[:id]] = SecureRandom.uuid
        resp[:id] = id
      end
      response_strings = stringify_responses(responses)
      responses_sql = "INSERT INTO form_responses (id, form_structure_id, subject_id, secondary_id, instance_number, updated_at, created_at) VALUES (#{response_strings.join("), (")})"

      answers = get_form_answers_from_xml(xml.xpath("//form_answer"), new_questions_ids, new_responses_ids)
      answers_sql = "INSERT INTO form_answers (form_question_id, form_response_id, answer, updated_at, created_at) VALUES (#{answers.join("), (")})"

      Project.transaction do 
        Project.connection.execute project_sql
        if team_members != []
          TeamMember.connection.execute team_members_sql
        end
        if form_structures != []
          FormStructure.connection.execute form_structures_sql
        end
        if form_permissions != []
          FormStructurePermission.connection.execute form_permissions_sql
        end
        if questions != []
          FormQuestion.connection.execute questions_sql
        end
        if text_configs != []
          TextConfig.connection.execute text_configs_sql
        end
        if range_configs != []
          NumericalRangeConfig.connection.execute range_configs_sql
        end
        if option_configs != []
          OptionConfig.connection.execute option_configs_sql
        end
        if question_conditions != []
          FormQuestionCondition.connection.execute question_conditions_sql
        end
        if question_exceptions != []
          QuestionException.connection.execute question_exceptions_sql
        end
        if responses != []
          FormResponse.connection.execute responses_sql
        end
        if answers != []
          FormAnswer.connection.execute answers_sql
        end
      end
    end

    private
      def get_project_from_xml(project_node)
        {
          updated_at: project_node[0].attributes["updated_at"].value,
          created_at: project_node[0].attributes["created_at"].value, 
          name: project_node[0].xpath("name").text
        }
      end

      def get_team_members_from_xml(team_members, project_id)
        team_members.map do |member_node|
          {
            project_id: project_id,
            updated_at: member_node.attributes["updated_at"].value,
            created_at: member_node.attributes["created_at"].value, 
            user_id: member_node.xpath("user_id").text,
            expiration_date: member_node.xpath("expiration_date").text,
            view_personally_identifiable_answers: member_node.xpath("view_personally_identifiable_answers").text,
            administrator: member_node.xpath("administrator").text,
            form_creation: member_node.xpath("form_creation").text,
            audit: member_node.xpath("audit").text,
            export: member_node.xpath("export").text
          }
        end.map do |member| "'#{member[:project_id]}', '#{member[:user_id]}', '#{member[:expiration_date]}', '#{member[:view_personally_identifiable_answers]}', '#{member[:administrator]}', '#{member[:form_creation]}', '#{member[:export]}', '#{member[:audit]}', '#{member[:updated_at]}', '#{member[:created_at]}'" end
      end

      def get_form_permissions_from_xml(form_permissions, new_forms_ids)
        form_permissions.map do |form_node|
          {
            form_structure_id: new_forms_ids[form_node.parent.parent.attributes["id"].value],
            updated_at: form_node.attributes["updated_at"].value,
            created_at: form_node.attributes["created_at"].value, 
            team_member_id: form_node.xpath("team_member_id").text,
            permission_level: form_node.xpath("permission_level").text
          }
        end.map do |perm| "'#{perm[:form_structure_id]}', '#{perm[:team_member_id]}', '#{perm[:permission_level]}','#{perm[:updated_at]}','#{perm[:created_at]}'" end
      end

      def get_form_structures_from_xml(form_structures, project_id)
        
        form_structures.map do |structure_node|
          {
            id: structure_node.attributes["id"].value,
            project_id: project_id,
            updated_at: structure_node.attributes["updated_at"].value,
            created_at: structure_node.attributes["created_at"].value, 
            name: structure_node.xpath("name").text,
            is_many_to_one: structure_node.xpath("is_many_to_one").text,
            secondary_id: structure_node.xpath("secondary_id").text,
            is_secondary_id_sorted: structure_node.xpath("is_secondary_id_sorted").text
          }
        end
      end      

      def stringify_structures(form_structures)
        form_structures.map do |struct| 
          "'#{struct[:id]}', '#{struct[:project_id]}', #{FormStructure.sanitize(struct[:name])}, '#{struct[:is_many_to_one]}', #{FormStructure.sanitize(struct[:secondary_id])}, '#{struct[:is_secondary_id_sorted]}', '#{struct[:updated_at]}', '#{struct[:created_at]}'" 
        end
      end

      def get_option_configs_from_xml(option_configs, new_questions_ids)
        i = -1
        option_configs.map do |option_node|
          i = i + 1
          {
            form_question_id: new_questions_ids[option_node.parent.parent.attributes["id"].value],
            value: option_node.xpath("value").text,
            other_option: option_node.xpath("other_option").text,
            other_variable_name: option_node.xpath("other_variable_name").text,
            code: option_node.xpath("code").text,
            index: i
          }
        end.map do |option| "'#{option[:form_question_id]}', '#{option[:index]}', #{OptionConfig.sanitize(option[:value])}, '#{option[:other_option]}', #{OptionConfig.sanitize(option[:code])}, #{OptionConfig.sanitize(option[:other_variable_name])}" end
      end

      def get_range_configs_from_xml(range_configs, new_questions_ids)
        range_configs.map do |range_config_node|
          {
            form_question_id: new_questions_ids[range_config_node.parent.attributes["id"].value],
            minimum_value: range_config_node.xpath("minimum_value").text,
            maximum_value: range_config_node.xpath("maximum_value").text,
            precision: range_config_node.xpath("precision").text
          }
        end.map do |range| "'#{range[:form_question_id]}', '#{range[:minimum_value]}', '#{range[:maximum_value]}', #{range[:precision]}" end
      end

      def get_text_configs_from_xml(text_configs, new_questions_ids)
        text_configs.map do |text_config_node|
          {
            form_question_id: new_questions_ids[text_config_node.parent.attributes["id"].value],
            size: text_config_node.xpath("size").text
          }
        end.map do |text| "'#{text[:form_question_id]}', '#{text[:size]}'" end
      end

      def get_question_conditions_from_xml(question_conditions, new_questions_ids)
        question_conditions.map do |condition_node|
          {
            form_question_id: new_questions_ids[condition_node.parent.parent.attributes["id"].value],
            value: condition_node.xpath("value").text,
            operator: condition_node.xpath("operator").text,
            depends_on_id: new_questions_ids[condition_node.xpath("depends_on_id").text]
          }
        end.map do |cond| "'#{cond[:form_question_id]}', '#{cond[:depends_on_id]}', '#{cond[:operator]}', #{FormQuestionCondition.sanitize(cond[:value])}" end
      end

      def get_question_exceptions_from_xml(question_exceptions, new_questions_ids)
        question_exceptions.map do |exception_node|
          {
            form_question_id: new_questions_ids[exception_node.parent.parent.attributes["id"].value],
            label: exception_node.xpath("label").text,
            exception_type: exception_node.xpath("exception_type").text,
            value: exception_node.xpath("value").text
          }
        end.map do |excep| "'#{excep[:form_question_id]}', #{QuestionException.sanitize(excep[:label])}, '#{excep[:exception_type]}', #{QuestionException.sanitize(excep[:value])}" end
      end

      def get_form_questions_from_xml(form_questions, new_forms_ids)
        form_questions.map do |question_node|
          {            
            id: question_node.attributes["id"].value,
            form_structure_id: new_forms_ids[question_node.parent.parent.attributes["id"].value],
            updated_at: question_node.attributes["updated_at"].value,
            created_at: question_node.attributes["created_at"].value,            
            prompt: question_node.xpath("prompt").text,
            sequence_number: question_node.xpath("sequence_number").text,
            display_number: question_node.xpath("display_number").text,
            variable_name: question_node.xpath("variable_name").text,
            question_type: question_node.xpath("question_type").text,
            personally_identifiable: question_node.xpath("personally_identifiable").text
          }
        end
      end

      def stringify_questions(form_questions)
        form_questions.map do |question|
          "'#{question[:id]}', '#{question[:form_structure_id]}', #{FormQuestion.sanitize(question[:prompt])}, #{FormQuestion.sanitize(question[:description])}, '#{question[:sequence_number]}', '#{question[:personally_identifiable]}', #{FormQuestion.sanitize(question[:variable_name])}, #{FormQuestion.sanitize(question[:display_number])}, '#{question[:question_type]}', '#{question[:updated_at]}', '#{question[:created_at]}'"
        end
      end

      def get_form_responses_from_xml(form_responses, new_forms_ids)
        form_responses.map do |response_node|
          {           
            id: response_node.attributes["id"].value,
            updated_at: response_node.attributes["updated_at"].value,
            created_at: response_node.attributes["created_at"].value,
            subject_id: response_node.xpath("subject_id").text,
            secondary_id: response_node.xpath("secondary_id").text,
            instance_number: response_node.xpath("instance_number").text,
            form_structure_id: new_forms_ids[response_node.xpath("form_structure_id").text]
          }
        end
      end

      def stringify_responses(form_responses)
        form_responses.map do |resp| 
          "'#{resp[:id]}', '#{resp[:form_structure_id]}', #{FormResponse.sanitize(resp[:subject_id])}, #{FormResponse.sanitize(resp[:secondary_id])}, '#{resp[:instance_number]}', '#{resp[:updated_at]}', '#{resp[:created_at]}'" 
        end
      end

      def get_form_answers_from_xml(form_answers, new_questions_ids, new_responses_ids)
        ret = form_answers.map do |answer_node|
          {
            form_response_id: new_responses_ids[answer_node.parent.parent.attributes["id"].value],
            updated_at: answer_node.attributes["updated_at"].value,
            created_at: answer_node.attributes["created_at"].value,
            answer: answer_node.xpath("answer").text,
            form_question_id: new_questions_ids[answer_node.xpath("form_question_id").text]
          }
        end.each do |answer|
          if answer[:updated_at] == ""
            answer[:updated_at] = Time.now.utc.to_s
          end
          if answer[:created_at] == ""
            answer[:created_at] = Time.now.utc.to_s
          end
        end.map do |answer| "'#{answer[:form_question_id]}', '#{answer[:form_response_id]}', #{FormAnswer.sanitize(answer[:answer])}, '#{answer[:updated_at]}', '#{answer[:created_at]}'" end
      end
  end
end