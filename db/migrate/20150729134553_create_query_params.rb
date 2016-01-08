class CreateQueryParams < ActiveRecord::Migration
  def change
    create_table :query_params, id: :uuid do |t|
    	t.uuid :query_id
    	t.uuid :form_question_id
      t.text :value
      t.text :operator
      t.boolean :is_last
      t.integer :sequence_number
      t.boolean :is_exception

      t.timestamps
      t.datetime :deleted_at

      t.foreign_key :queries, column: 'query_id', dependent: :delete
      t.foreign_key :form_questions, dependent: :delete

      t.index :query_id
    end
  end
end
