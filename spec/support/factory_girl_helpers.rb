module FactoryGirlHelpers
  def create_answer(answer_name, structure)
    answer = create(answer_name)
    old_question = answer.form_question
    new_question = structure.form_questions.where(prompt: old_question.prompt).first
    answer.form_question = new_question
    old_question.delete
    answer.save
    answer
  end
end
