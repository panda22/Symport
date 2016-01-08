class FormQuestionsController < ApplicationController

  wrap_parameters format: [:json], include: [:sequenceNumber, :personallyIdentifiable, :type, :prompt, :description, :config, :variable_name]

  def update
    structure = FormBuilderLookup.find_structure current_user, params[:form_structure_id]
    
    question = FormBuilderLookup.find_question current_user, params[:id]

    prev_question_id = params[:prev_id]

    updated_structure = FormQuestionUpdater.update current_user, question, structure, params[:form_question], prev_question_id
 
    payload = FormStructureSerializer.serialize(current_user, updated_structure, true) 

    render json: { formStructure: payload }
  end

  def show
    question = FormBuilderLookup.find_question current_user, params[:id]
    render json: {formQuestion: FormQuestionSerializer.serialize(question)}
  end

  def create
    begin
      structure = FormBuilderLookup.find_structure current_user, params[:form_structure_id]

      prev_question_id = params[:prev_id]

      updated_structure = FormQuestionCreator.create current_user, structure, params[:form_question], prev_question_id

      payload = FormStructureSerializer.serialize(current_user, updated_structure, true) 
      render json: { formStructure: payload }
    rescue ActiveRecord::RecordInvalid => error
      validations = FormQuestionSerializer.validation_errors(error.record)
      render json: {validations: validations}, status: 422
    end
  end

  def destroy
    structure = FormBuilderLookup.find_structure current_user, params[:form_structure_id]
    question = FormBuilderLookup.find_question current_user, params[:id]
    updated_structure = FormQuestionDestroyer.destroy current_user, question, structure
    payload = FormStructureSerializer.serialize(current_user, updated_structure, true) 
    render json: { formStructure: payload }
  end
end
