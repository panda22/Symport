class PopulateIndexForAnswerChoices < ActiveRecord::Migration
  def change
    OptionConfig.all.group_by(&:form_question_id).each do |group|
      i = 0
      group[1].each do |option|
        option.index = i
        option.save!
        i = i + 1
      end
    end
  end
end
