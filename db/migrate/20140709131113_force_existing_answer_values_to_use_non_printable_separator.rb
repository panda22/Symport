class ForceExistingAnswerValuesToUseNonPrintableSeparator < ActiveRecord::Migration
  def up
    FormQuestion.where(question_type: 'checkbox').map { |q| q.form_answers[0] }.each do |fa|
      fa.answer = fa.answer.try(:sub, ',', "\u200C")
      fa.save!
    end
  end

  def down
    FormQuestion.where(question_type: 'checkbox').map { |q| q.form_answers[0] }.each do |fa|
      fa.answer = fa.answer.try(:sub, "\u200C", ",")
      fa.save!
    end
  end
end
