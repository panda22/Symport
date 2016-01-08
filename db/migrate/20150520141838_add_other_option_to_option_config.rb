class AddOtherOptionToOptionConfig < ActiveRecord::Migration
  def change
    add_column :option_configs, :other_option, :boolean, default: false
  end
end
