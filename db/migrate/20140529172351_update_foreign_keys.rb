class UpdateForeignKeys < ActiveRecord::Migration
  def up
    remove_foreign_key :form_structures, :projects
    add_foreign_key :form_structures, :projects, dependent: :delete

    remove_foreign_key :form_responses, :form_structures
    add_foreign_key :form_responses, :form_structures, dependent: :delete

    remove_foreign_key :form_questions, :form_structures
    add_foreign_key :form_questions, :form_structures, dependent: :delete

    remove_foreign_key :form_answers, :form_questions
    add_foreign_key :form_answers, :form_questions, dependent: :delete

    remove_foreign_key :form_answers, :form_responses
    add_foreign_key :form_answers, :form_responses, dependent: :delete

    remove_foreign_key :numerical_range_configs, :form_questions
    add_foreign_key :numerical_range_configs, :form_questions, dependent: :delete

    remove_foreign_key :text_configs, :form_questions
    add_foreign_key :text_configs, :form_questions, dependent: :delete

    remove_foreign_key :option_configs, :form_questions
    add_foreign_key :option_configs, :form_questions, dependent: :delete
  end

  def down
    remove_foreign_key :form_structures, :projects
    add_foreign_key :form_structures, :projects

    remove_foreign_key :form_responses, :form_structures
    add_foreign_key :form_responses, :form_structures

    remove_foreign_key :form_questions, :form_structures
    add_foreign_key :form_questions, :form_structures

    remove_foreign_key :form_answers, :form_questions
    add_foreign_key :form_answers, :form_questions

    remove_foreign_key :form_answers, :form_responses
    add_foreign_key :form_answers, :form_responses

    remove_foreign_key :numerical_range_configs, :form_questions
    add_foreign_key :numerical_range_configs, :form_questions

    remove_foreign_key :text_configs, :form_questions
    add_foreign_key :text_configs, :form_questions

    remove_foreign_key :option_configs, :form_questions
    add_foreign_key :option_configs, :form_questions
  end
end
