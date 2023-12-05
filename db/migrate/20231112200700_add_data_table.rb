class AddDataTable < ActiveRecord::Migration[7.1]
  def change
    create_table :datas do |t|
      t.references :field, null: false, foreign_key: { on_delete: :cascade }
      t.string :cas_id, null: false
      t.string :subgroup, null: true
      t.string :data_value, null: false
      t.timestamps
    end
  end
end
