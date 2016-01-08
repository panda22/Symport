class CreateDemoProgressTable < ActiveRecord::Migration
  def change
    create_table :demo_progresses, id: :uuid do |t|
      t.uuid :user_id
      t.uuid :project_id
      t.uuid :demo_form_id
      t.uuid :demo_question_id

      t.datetime :deleted_at
      t.timestamps


      t.foreign_key :projects, dependent: :delete
    end
  end
end
