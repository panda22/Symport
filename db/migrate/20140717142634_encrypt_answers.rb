class EncryptAnswers < ActiveRecord::Migration
  def change
    remove_column :form_answers, :answer, :text
    add_column :form_answers, :encrypted_answer, :text
  end
end
