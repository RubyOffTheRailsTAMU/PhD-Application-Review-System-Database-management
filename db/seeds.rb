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

# Create new fields
fields = [
  { field_name: "first_name", field_alias: "first", field_used: true, field_many: false },
  { field_name: "middle_name", field_alias: "middle", field_used: true, field_many: false },
  { field_name: "last_name", field_alias: "last", field_used: true, field_many: false },
  { field_name: "email", field_alias: "email", field_used: true, field_many: false },
  { field_name: "phone", field_alias: "phone", field_used: true, field_many: false },
]
fields.each do |field|
  # Field.create!(field)
end
