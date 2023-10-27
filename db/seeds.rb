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
  { user_netid: "123",user_email:"admin.phd@tamu.edu", user_name: "admin", user_level: "admin", password:"admin"},
  # add more users as needed
]

# Save users to the database
users.each do |user|
  User.create!(user)
end
