class CreateExceptionTable < ActiveRecord::Migration
  def change
    create_table :question_exceptions, id: :uuid do |t|
      t.uuid :form_question_id
      t.text :value
      t.text :label
      t.text :exception_type

      t.datetime :deleted_at
      t.timestamps

      t.foreign_key :form_questions, dependent: :delete
    end

    add_column :form_answers, :closed, :boolean, default: false
    add_column :form_answers, :regular_exception, :uuid, default: nil
    add_column :form_answers, :year_exception, :uuid, default: nil
    add_column :form_answers, :month_exception, :uuid, default: nil
    add_column :form_answers, :day_exception, :uuid, default: nil

  end
end
