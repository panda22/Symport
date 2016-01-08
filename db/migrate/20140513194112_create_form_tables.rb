class CreateFormTables < ActiveRecord::Migration
  def change
    create_table :form_structures, id: :uuid do |t|
      t.text :name
      t.timestamps
    end

    create_table :form_responses, id: :uuid do |t|
      t.uuid :form_structure_id
      t.timestamps

      t.index :form_structure_id
      t.foreign_key :form_structures
    end

    create_table :form_questions, id: :uuid do |t|
      t.uuid :form_structure_id
      t.text :prompt
      t.text :description
      t.integer :question_number
      t.boolean :personally_identifiable
      t.text :question_type 
      t.timestamps

      t.index :form_structure_id
      t.foreign_key :form_structures
    end

    create_table :form_answers, id: :uuid do |t|
      t.uuid :form_response_id
      t.uuid :form_question_id
      t.text :answer
      t.timestamps

      t.index :form_response_id
      t.foreign_key :form_responses

      t.index :form_question_id
      t.foreign_key :form_questions
    end

    create_table :numerical_range_configs, id: :uuid do |t|
      t.uuid :form_question_id
      t.float :minimum_value
      t.float :maximum_value
      t.text :precision

      t.index :form_question_id
      t.foreign_key :form_questions
    end

    create_table :text_configs, id: :uuid do |t|
      t.uuid :form_question_id 
      t.text :size

      t.index :form_question_id
      t.foreign_key :form_questions
    end

    create_table :option_configs, id: :uuid do |t|
      t.uuid :form_question_id
      t.integer :index
      t.text :value

      t.index :form_question_id
      t.foreign_key :form_questions
    end
  end
end
