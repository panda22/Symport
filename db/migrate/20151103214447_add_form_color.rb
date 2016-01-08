class AddFormColor < ActiveRecord::Migration
  def change
  	add_column :form_structures, :color_index, :integer
  	Project.all.each do |project|
  	  project.form_structures.order(updated_at: :desc).each_with_index do |form, i|
  	  	form.color_index = i
  	  	form.save!
  	  end
  	 end
  end
end
