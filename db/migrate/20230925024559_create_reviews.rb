class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.integer :review_id
      t.string :user_netid
      t.string :candidate_id
      t.string :review_info

      t.timestamps
    end
  end
end
