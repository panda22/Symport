class AddErrorStuffToAnswers < ActiveRecord::Migration
  def change
  	add_column :form_answers, :ignore_error, :boolean, default: false
  	add_column :form_answers, :error_msg, :text, default: nil
  end
end
