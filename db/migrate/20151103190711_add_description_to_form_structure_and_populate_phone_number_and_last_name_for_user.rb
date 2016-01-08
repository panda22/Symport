class AddDescriptionToFormStructureAndPopulatePhoneNumberAndLastNameForUser < ActiveRecord::Migration
  def change
  	add_column :form_structures, :description, :string, default: ""
  	User.where(:phone_number => ["",nil]).update_all(phone_number: "Please Fill")
  end
end
