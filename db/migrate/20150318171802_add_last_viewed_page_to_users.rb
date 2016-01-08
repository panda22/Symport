class AddLastViewedPageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_viewed_page, :string
  end
end
