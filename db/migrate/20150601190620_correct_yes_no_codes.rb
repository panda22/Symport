class CorrectYesNoCodes < ActiveRecord::Migration
  def change
  	OptionConfig.where(value: "Yes").each do |option|
  		option.code = "1"
  		option.save!
  	end
  	OptionConfig.where(value: "No").each do |option|
  		option.code = "2"
  		option.save!
  	end
  end
end
