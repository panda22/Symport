class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries, id: :uuid do |t|
    	t.uuid :owner_id
      t.uuid :editor_id
    	t.uuid :project_id
      t.text :name
    	t.boolean :is_shared
      t.text :conjunction

    	t.timestamp :deleted_at
      t.timestamps

      t.foreign_key :projects, dependent: :delete
      t.foreign_key :users, column: 'owner_id', dependent: :delete
      t.foreign_key :users, column: 'editor_id', dependent: :delete

      t.index :project_id
      t.index :owner_id
    end
  end
end
