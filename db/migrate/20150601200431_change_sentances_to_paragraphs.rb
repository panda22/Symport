class ChangeSentancesToParagraphs < ActiveRecord::Migration
  def change
  	TextConfig.where(size: "normal").each do |option|
      option.size = "large"
      option.save!
  	end
  end
end
