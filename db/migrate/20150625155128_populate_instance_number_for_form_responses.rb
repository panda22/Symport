class PopulateInstanceNumberForFormResponses < ActiveRecord::Migration
  def change
    FormResponse.all.each do |response|
      response.instance_number = 0
      response.save!
    end
    FormStructure.all.each do |form|
      form.is_many_to_one = false
      form.save!
    end
  end
end
