class CreateApplicationIelts < ActiveRecord::Migration[7.0]
  def change
    create_table :application_ielts do |t|
      t.references :applicant, null: false, foreign_key: { on_delete: :cascade }
      t.integer :application_ielts_listening
      t.integer :application_ielts_reading
      t.integer :application_ielts_result
      t.integer :application_ielts_speaking
      t.integer :application_ielts_writing

      t.timestamps
    end
  end
end
