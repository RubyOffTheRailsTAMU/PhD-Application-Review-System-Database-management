class AddSubgroupTable < ActiveRecord::Migration[7.1]
  def change
    create_table :subgroups do |t|
      t.string :subgroup_name, null: false
      t.timestamps
    end
  end
end
