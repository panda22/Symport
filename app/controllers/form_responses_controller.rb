class FormResponsesController < ApplicationController

  def show
    instance_number = 0
    if params[:instance_number] != nil
      instance_number = params[:instance_number]
    end
    form_response = FormResponseLookup.find_response_by_subject_id(current_user, params[:form_structure_id], params[:id], instance_number)
    if form_response.nil?
      structure = FormBuilderLookup.find_structure(current_user, params[:form_structure_id])
      # this show function runs create if response doesn't exist ?
      form_response = FormResponseBuilder.build(current_user, structure, params[:id])
    else
      AuditLogger.view current_user, form_response
    end
    payload = FormResponseSerializer.serialize(current_user, form_response, true)
    render json: { formResponse: payload }
  end

  def create_new
    form = FormStructure.find(params[:form_id])
    unless Permissions.user_can_enter_form_responses_for_form_structure?(current_user, form)
      raise PayloadException.access_denied "You do not have access to responses for this form"
    end
    temp_instance_num = 0
    if form.is_many_to_one
      temp_instance_num = -1
    end
    response = FormResponse.create!(
        {
            form_structure_id: params[:form_id],
            subject_id: params[:subject_id],
            secondary_id: params[:secondary_id],
            instance_number: temp_instance_num
        }
    )
    FormResponseOrderer.order(response)
    response = FormResponse.find(response.id) # refresh instance number
    payload = FormResponseSerializer.serialize(current_user, response, true)
    render json: payload
  end

  def find_by_id
    response = FormResponse.find(params[:id])
    unless Permissions.user_can_view_form_responses_for_form_structure?(current_user, response.form_structure)
      raise PayloadException.access_denied "You do not have access to responses for this form"
    end
    payload = FormResponseSerializer.serialize(current_user, response, true)
    render json: payload
  end

  def get_by_subject_and_instance
    instance_number = 0
    if params[:instance_number] != nil
      instance_number = params[:instance_number]
    end
    form_response = FormResponseLookup.find_response_by_subject_id(current_user, params[:form_structure_id], params[:subject_id], instance_number)
    if form_response.nil?
      structure = FormBuilderLookup.find_structure(current_user, params[:form_structure_id])
      form_response = FormResponseBuilder.build(current_user, structure, params[:subject_id])
    else
      AuditLogger.view current_user, form_response
    end
    payload = FormResponseSerializer.serialize(current_user, form_response, true)
    render json: { formResponse: payload }
  end

  def known_subjects_by_form
    form = FormStructure.find(params[:form_id])
    unless Permissions.user_can_view_form_responses_for_form_structure?(current_user, form)
      raise PayloadException.access_denied "You do not have access to responses for this form"
    end
    response_hash = FormResponseLookup.get_subjects_by_form(form)
    payload = FormResponseSerializer.serialize_subjects(response_hash)
    render json: payload
  end

  def update
    instance_number = 0
    if params[:form_response][:instanceNumber] != nil
      instance_number = params[:form_response][:instanceNumber]
    end
    if params[:onlyCheckErrors]
      structure = FormBuilderLookup.find_structure(current_user, params[:form_structure_id])
      form_response = FormRecordCreator.new_response(params[:id], structure, [], instance_number)
      updated_response = FormResponseUpdater.get_errors(current_user, form_response, params[:form_response])
      render json: { formResponse: FormResponseSerializer.serialize(current_user, updated_response) }
    else
      form_response = FormResponseLookup.find_response_by_subject_id(current_user, params[:form_structure_id], params[:id], instance_number)
      if form_response.nil?
        structure = FormBuilderLookup.find_structure(current_user, params[:form_structure_id])
        form_response = FormRecordCreator.create_response(params[:id], structure, [], instance_number, params[:form_response][:secondaryId])
        AuditLogger.add(current_user, form_response)
      end
      updated_response = FormResponseUpdater.update(current_user, form_response, params[:form_response])
      render json: { formResponse: FormResponseSerializer.serialize(current_user, updated_response) }
    end
  end

  def destroy
    response_record = FormResponse.find_by(:id => params[:id])
    payload = if response_record.present?
      FormResponseDestroyer.destroy(current_user, response_record)
    end
    FormResponseOrderer.order(response_record)
    render json: { formResponse: payload }
  end

  def rename_instance
    response_record = FormResponseLookup.find_response(current_user, params[:id])
    AuditLogger.surround_edit(current_user, response_record) do
      response_record.secondary_id = params[:secondary_id]
      response_record.save!
    end
    if response_record.form_structure.is_secondary_id_sorted
      FormResponseOrderer.order(response_record)
    end
    render json: { formResponse: FormResponseSerializer.serialize(current_user, response_record) }
  end

  def destroy_instances_for_subject
    structure = FormStructure.find(params[:form_id])
    structure_ids = structure.project.form_structures.pluck(:id)
    instances = FormResponse.where(
      :form_structure_id => structure_ids,
      :subject_id => params[:subject_id]
    )
    instances.each do |instance|
      FormResponseDestroyer.destroy(current_user, instance)
    end
    render json: {result: "success"}
  end



end
