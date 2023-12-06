# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create new users
users = [
  { user_netid: "123", user_email: "admin.phd@tamu.edu", user_name: "admin", user_level: "admin", password: "admin" },
# add more users as needed
]

# Save users to the database
users.each do |user|
  User.create!(user)
end

#Create new fields
fields = [
  { field_name: "first_name", field_alias: "first", field_used: true, field_many: false },
  { field_name: "middle_name", field_alias: "middle", field_used: true, field_many: false },
  { field_name: "last_name", field_alias: "last", field_used: true, field_many: false },
  { field_name: "email", field_alias: "email", field_used: true, field_many: false },
  { field_name: "phone", field_alias: "phone", field_used: true, field_many: false },
]

# fields = [
#   { field_name: "cas_id", field_alias: "cas_id", field_used: true, field_many: false},
#   { field_name: "Full Name", field_alias: "Full Name", field_used: true, field_many: false},
#   { field_name: "gender", field_alias: "gender", field_used: true, field_many: false},
#   { field_name: "citizenship_country_name", field_alias: "citizenship_country_name", field_used: true, field_many: false},
#   { field_name: "phone", field_alias: "phone", field_used: true, field_many: false},
#   { field_name: "citizenship_status", field_alias: "citizenship_status", field_used: true, field_many: false},
#   { field_name: "date_of_birth", field_alias: "date_of_birth", field_used: true, field_many: false},
#   { field_name: "gpas_by_transcript_school_name", field_alias: "gpas_by_transcript_school_name", field_used: true, field_many: false},
# ]
fields.each do |field|
  # Field.create!(field)
end
