class RenameDataToInfo < ActiveRecord::Migration[7.1]
  def change
    rename_table :datas, :infos
  end
end
