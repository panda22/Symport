class AddIsChangedToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :is_changed, :boolean
    add_column :queries, :change_message, :text
  end
end
