class AddDeletedAtToSessionTokens < ActiveRecord::Migration
  def change
    add_column :session_tokens, :deleted_at, :datetime
    add_index :session_tokens, :deleted_at
  end
end
