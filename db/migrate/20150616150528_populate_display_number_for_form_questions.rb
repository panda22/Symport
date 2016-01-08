class PopulateDisplayNumberForFormQuestions < ActiveRecord::Migration
  def change
    FormQuestion.all.each do |question|
      question.display_number = question.sequence_number
      question.save!
    end
  end
end
