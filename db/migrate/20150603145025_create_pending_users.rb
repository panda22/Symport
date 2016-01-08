class CreatePendingUsers < ActiveRecord::Migration
  def change
    create_table :pending_users, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :team_member_id
      t.datetime :expires
      t.text :message
      t.datetime :deleted_at

      t.timestamps

      t.index :user_id
      t.index :expires

      t.foreign_key :users, dependent: :delete
    end
  end
end
