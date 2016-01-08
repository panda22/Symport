class PopulateSecondaryIdForFormStructures < ActiveRecord::Migration
  def change
    FormStructure.all.each do |form|
      form.secondary_id = "Secondary ID"
      form.save!
    end
  end
end
