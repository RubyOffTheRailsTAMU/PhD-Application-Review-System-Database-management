class ChangeIeltsColumnsToAllowNull < ActiveRecord::Migration[7.0]
  def change
    change_column :application_ielts, :application_ielts_listening, :integer, null: true
    change_column :application_ielts, :application_ielts_reading, :integer, null: true
    change_column :application_ielts, :application_ielts_result, :integer, null: true
    change_column :application_ielts, :application_ielts_speaking, :integer, null: true
    change_column :application_ielts, :application_ielts_writing, :integer, null: true
  end
end
