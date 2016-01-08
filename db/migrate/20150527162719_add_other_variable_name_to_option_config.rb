class AddOtherVariableNameToOptionConfig < ActiveRecord::Migration
  def change
  	add_column :option_configs, :other_variable_name, :text, default: nil
  end
end
