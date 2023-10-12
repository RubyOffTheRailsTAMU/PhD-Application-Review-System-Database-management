class CreateSchools < ActiveRecord::Migration[7.0]
  def change
    create_table :schools do |t|
      t.references :applicant, null: false, foreign_key: { on_delete: :cascade }
      t.string :application_school_name
      t.string :application_school_level, null: true
      t.integer :application_school_quality_points, null: true
      t.float :application_school_gpa, null: true
      t.integer :application_school_credit_hours, null: true

      t.timestamps
    end
  end
end
