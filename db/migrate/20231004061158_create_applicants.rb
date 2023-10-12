class CreateApplicants < ActiveRecord::Migration[7.0]
  def change
    create_table :applicants do |t|
      t.string :application_cas_id
      t.string :application_name
      t.string :application_gender
      t.string :application_citizenship_country
      t.datetime :application_dob
      t.string :application_email
      t.string :application_degree
      t.string :application_submitted
      t.string :application_status
      t.string :application_research
      t.string :application_faculty
      t.timestamps
    end
  end
end
