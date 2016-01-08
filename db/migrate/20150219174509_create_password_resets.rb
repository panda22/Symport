class CreatePasswordResets < ActiveRecord::Migration
  def change
    create_table :password_resets, id: :uuid do |t|
      t.uuid :user_id
      t.timestamps

      t.index :user_id
      t.foreign_key :users, dependent: :delete
    end
  end
end
