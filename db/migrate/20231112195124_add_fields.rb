class AddFields < ActiveRecord::Migration[7.0]
  def change
    create_table :fields do |t|
      t.string :field_name
      t.string :field_alias
      t.boolean :field_used
      t.boolean :field_many
      t.timestamps
    end
  end
end
