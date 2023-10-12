class CreateGres < ActiveRecord::Migration[7.0]
  def change
    create_table :gres do |t|
      t.references :applicant, null: false, foreign_key: true
      t.integer :quantitative_scaled
      t.integer :quantitative_percentile
      t.integer :verbal_scaled
      t.integer :verbal_percentile
      t.float :analytical_scaled
      t.integer :analytical_percentile

      t.timestamps
    end
  end
end
