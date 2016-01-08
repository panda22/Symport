class AddCodeToOptionConfigs < ActiveRecord::Migration
  def change
    add_column :option_configs, :code, :text
  end
end
