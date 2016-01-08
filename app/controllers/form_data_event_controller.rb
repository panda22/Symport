class FormDataEventController < ApplicationController


  def update_question
    question = FormQuestion.find(params[:question][:id])
    form = question.form_structure
    updated_form = FormQuestionUpdater.update(current_user, question, form, params[:question])
    updated_question_order = updated_form.form_questions.map do |question|
      question.id
    end
    render json: {
               success: true,
               questionOrder: updated_question_order
           }
  end

  def get_question_errors
    # TODO: add permission check
    question_id = params[:question_id]
    error_objs = FormAnswer.
        where("error_msg is not null and form_question_id='#{question_id}'").
        map do |answer|
      get_error_obj(answer)
    end
    render json: { errors: error_objs }
  end

  # @params
  #   answers: [
  #     {
  #       :id,
  #       :answer,
  #       :ignored
  #     }
  #   ]
  def save_answers_for_question
    question_id = params[:question_id]
    question = FormQuestion.find(question_id)
    if params[:answers].nil? or params[:answers].length == 0
      render json: {sucess: false, message: "no answers"}
      return
    end
    other_val = nil
    unless question.option_configs.length == 0
      question.option_configs.each do |option|
        if option.other_option
          other_val = option.value
        end
      end
    end
    response_ids = params[:answers].map do |params_obj|
      params_obj[:responseID]
    end
    answer_vals = construct_answer_vals(params[:answers], other_val)
    answer_records = FormAnswer.where(:form_question_id => question_id, :form_response_id => response_ids)
    ordered_answers = order_answers_from_params(answer_records, response_ids)
    ordered_answers.each_with_index do |answer, i|
      answer.ignore_error = params[:answers][i][:ignored]
    end
    FormAnswerProcessor.validate_and_save_all(current_user, question, ordered_answers, answer_vals)
    updated_answers = FormAnswer.
        where(:form_response_id => response_ids, :form_question_id => question_id).
        where("error_msg is not null or ignore_error=true")
    fixed_count = answer_records.count - updated_answers.count
    error_objs = updated_answers.map do |answer|
      get_error_obj(answer)
    end
    render json: {
               success: true,
               errors: error_objs,
               fixedCount: fixed_count
           }
  end\

  private
  def get_error_obj(answer)
    answer_val = answer.answer
    other_answer = ""
    if answer_val.nil? == false and answer_val.include?("\u200a")
      temp_answer_val = ""
      answer_val.split("\u200c").each_with_index do |answer_part, i|
        if i != 0
          temp_answer_val += "\u200c"
        end
        if answer_part.include?("\u200a") and answer_part.split("\u200a").length == 2
          other_answer = answer_part.split("\u200a")[1]
          temp_answer_val += answer_part.split("\u200a")[0]
        else
          temp_answer_val += answer_part
        end
      end
      answer_val = temp_answer_val
    end
    {
        questionID: answer.form_question_id,
        responseID: answer.form_response_id,
        canceled: false,
        message: answer.error_msg,
        isActive: !answer.ignore_error,
        answerID: answer.id,
        subjectID: answer.form_response.subject_id,
        secondaryId: answer.form_response.secondary_id,
        answer: answer_val,
        otherAnswer: other_answer
    }
  end

  def construct_answer_vals (input_arr, other_val)
    result = input_arr.map do |param_obj|
      if other_val
        temp_answer = ""
        param_obj[:answer].split("\u200c").each_with_index do |answer_part, i|
          if i != 0
            temp_answer += "\u200c"
          end
          if answer_part == other_val
            temp_answer += (answer_part + "\u200a" + param_obj[:otherAnswer])
          else
            temp_answer += answer_part
          end
        end
        temp_answer
      else
        param_obj[:answer]
      end
    end
    result
  end

  def order_answers_from_params(answers, response_ids)
    answer_arr = answers.map{|answer| answer} # convert activerecord relation to array
    result = []
    response_ids.each do |response_id|
      answer = answer_arr.find do |answer|
        answer.form_response_id == response_id
      end
      result.push(answer)
    end
    result
  end


end
