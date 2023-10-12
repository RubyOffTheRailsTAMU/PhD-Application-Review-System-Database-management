class CreateToefls < ActiveRecord::Migration[7.0]
  def change
    create_table :toefls do |t|
      t.references :applicant, null: false, foreign_key: true
      t.integer :listening
      t.integer :reading
      t.integer :result
      t.integer :speaking
      t.integer :writing

      t.timestamps
    end
  end
end
