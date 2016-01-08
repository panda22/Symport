class PopulateManyToOneToQueryParams < ActiveRecord::Migration
  def change
    QueryParam.update_all(:is_many_to_one_instance => false, :is_many_to_one_count => false)
    QueryParam.all.each do |param|
      param.form_structure_id = param.form_question.form_structure_id
      param.save!
    end
  end
end
