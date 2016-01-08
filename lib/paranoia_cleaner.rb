class ParanoiaCleaner
  class << self
    def delete_old_records
      stale_threshold = 30.days.ago
  
      stale_projects = Project.deleted.all.select { |proj| proj.deleted_at < stale_threshold }
      stale_projects.each do |proj|
        Project.transaction do
          delete_project(proj)
        end
      end

      stale_team_members = TeamMember.deleted.all.select { |member| member.deleted_at < stale_threshold }
      stale_team_members.each do |member|
        TeamMember.transaction do
          delete_team_member(member)
        end
      end

      stale_forms = FormStructure.deleted.all.select { |form| form.deleted_at < stale_threshold }
      stale_forms.each do |form|
        FormStructure.transaction do
          delete_form_structure(form)
        end
      end

      stale_questions = FormQuestion.deleted.all.select { |question| question.deleted_at < stale_threshold }
      stale_questions.each do |question|
        FormQuestion.transaction do
          delete_all_conditions_for_questions([question.id])
        end
      end

      stale_responses = FormResponse.deleted.all.select { |resp| resp.deleted_at < stale_threshold }
      stale_responses.each do |resp|
        FormResponse.transaction do
          resp.really_destroy!
        end
      end

      stale_conditions = FormQuestionCondition.deleted.all.select { |cond| cond.deleted_at < stale_threshold }
      stale_conditions.each do |cond|
        FormQuestionCondtion.transaction do
          cond.really_destroy!
        end
      end

    end

    def delete_team_member(team_member)
      permissions = FormStructurePermission.unscoped.where(team_member_id: team_member.id)
      permissions.each do |perm|
        perm.really_destroy!
      end

      team_member.really_destroy!
    end
    
    def delete_project(project)
      
      backups = ProjectBackup.unscoped.where(project_id: project.id)
      backups.each do |back|
        back.really_destroy!
      end

      form_ids = FormStructure.unscoped.where(project_id: project.id).map do |struct| 
        struct.id
      end

      question_ids = FormQuestion.unscoped.where(form_structure_id: form_ids).map do |q| 
        q.id
      end
      delete_all_conditions_for_questions(question_ids)

      permissions = FormStructurePermission.unscoped.where(form_structure_id: form_ids)
      permissions.each do |perm|
        perm.really_destroy!
      end

      project.really_destroy!
    end



    def delete_form_structure(form)
      question_ids = FormQuestion.unscoped.where(form_structure_id: form.id).map do |q| 
        q.id
      end 
      delete_all_conditions_for_questions(question_ids)
 
      permissions = FormStructurePermission.unscoped.where(form_structure_id: form.id)
      permissions.each do |perm|
        perm.really_destroy!
      end

      form.really_destroy!
    end

    def delete_all_conditions_for_questions(q_ids)
      conds = FormQuestionCondition.unscoped.where(form_question_id: q_ids)
      conds.each do |cond|
        cond.really_destroy!
      end
      conds = FormQuestionCondition.unscoped.where(depends_on_id: q_ids)
      conds.each do |cond|
        cond.really_destroy!
      end
    end
  end
end