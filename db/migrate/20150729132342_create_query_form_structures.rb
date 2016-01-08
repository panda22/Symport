class CreateQueryFormStructures < ActiveRecord::Migration
  def change
    create_table :query_form_structures, id: :uuid do |t|
      t.uuid :form_structure_id
      t.uuid :query_id

      t.timestamp :deleted_at
      t.timestamps

      t.foreign_key :queries, column: 'query_id', dependent: :delete
      t.foreign_key :form_structures, dependent: :delete

      t.index :form_structure_id
      t.index :query_id
    end
  end
end
