class AbandonDevise < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.remove :encrypted_password
      t.remove :reset_password_token
      t.remove :reset_password_sent_at
      t.remove :remember_created_at
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip

      t.string :password_digest
    end

    create_table :session_tokens, id: :uuid do |t|
      t.uuid :user_id
      t.datetime :last_activity_at

      t.timestamps
    end
  end
end
