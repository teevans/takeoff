# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Seeding database..."

# Create users if they don't exist
user1 = User.find_or_create_by!(email_address: "demo@example.com") do |user|
  user.name = "Demo User"
  user.password_digest = nil # Passwordless auth
end

user2 = User.find_or_create_by!(email_address: "john@example.com") do |user|
  user.name = "John Smith"
  user.password_digest = nil
end

# Create companies if they don't exist
company1 = Company.find_or_create_by!(name: "BuildCo Construction") do |company|
  puts "Creating company: #{company.name}"
end

company2 = Company.find_or_create_by!(name: "Premier Renovations") do |company|
  puts "Creating company: #{company.name}"
end

# Associate users with companies
unless CompanyUser.exists?(company: company1, user: user1)
  CompanyUser.create!(company: company1, user: user1, role: "administrator")
  puts "Added #{user1.name} as administrator to #{company1.name}"
end

unless CompanyUser.exists?(company: company1, user: user2)
  CompanyUser.create!(company: company1, user: user2, role: "member")
  puts "Added #{user2.name} as member to #{company1.name}"
end

unless CompanyUser.exists?(company: company2, user: user1)
  CompanyUser.create!(company: company2, user: user1, role: "administrator")
  puts "Added #{user1.name} as administrator to #{company2.name}"
end

# Create projects for company1
projects_data = [
  {
    name: "Sunset Ridge Estate",
    description: "Luxury residential development featuring 12 custom homes with modern amenities and sustainable design",
    project_type: "new_build",
    status: "active",
    address: "1500 Sunset Ridge Drive",
    city: "Los Angeles",
    state: "CA",
    zip_code: "90210",
    budget: 8500000.00,
    start_date: 2.months.ago,
    estimated_completion_date: 10.months.from_now
  },
  {
    name: "Downtown Office Tower",
    description: "40-story commercial office building with LEED Gold certification target",
    project_type: "new_build",
    status: "planning",
    address: "100 Financial District",
    city: "San Francisco",
    state: "CA",
    zip_code: "94111",
    budget: 125000000.00,
    start_date: 1.month.from_now,
    estimated_completion_date: 3.years.from_now
  },
  {
    name: "Historic Theater Restoration",
    description: "Complete restoration of 1920s art deco theater, preserving original architectural features",
    project_type: "existing_build",
    status: "active",
    address: "456 Broadway",
    city: "Portland",
    state: "OR",
    zip_code: "97204",
    budget: 3200000.00,
    start_date: 6.weeks.ago,
    estimated_completion_date: 8.months.from_now
  },
  {
    name: "Riverside Shopping Center",
    description: "Mixed-use retail and dining complex with outdoor plaza and river views",
    project_type: "new_build",
    status: "completed",
    address: "2000 Riverside Plaza",
    city: "Austin",
    state: "TX",
    zip_code: "78701",
    budget: 22000000.00,
    start_date: 18.months.ago,
    estimated_completion_date: 2.months.ago
  },
  {
    name: "Tech Campus Expansion",
    description: "Adding three new buildings to existing technology campus, including labs and offices",
    project_type: "new_build",
    status: "active",
    address: "5000 Innovation Way",
    city: "Seattle",
    state: "WA",
    zip_code: "98109",
    budget: 45000000.00,
    start_date: 3.months.ago,
    estimated_completion_date: 15.months.from_now
  },
  {
    name: "Victorian Home Renovation",
    description: "Full renovation of historic Victorian home, updating systems while preserving character",
    project_type: "existing_build",
    status: "on_hold",
    address: "789 Heritage Lane",
    city: "San Francisco",
    state: "CA",
    zip_code: "94117",
    budget: 850000.00,
    start_date: 1.month.ago,
    estimated_completion_date: 6.months.from_now
  },
  {
    name: "Green Energy Warehouse",
    description: "Solar-powered distribution center with advanced automation systems",
    project_type: "new_build",
    status: "active",
    address: "3000 Logistics Boulevard",
    city: "Phoenix",
    state: "AZ",
    zip_code: "85001",
    budget: 18000000.00,
    start_date: 4.months.ago,
    estimated_completion_date: 5.months.from_now
  },
  {
    name: "Beachfront Condominiums",
    description: "Luxury beachfront residential complex with 60 units and resort-style amenities",
    project_type: "new_build",
    status: "planning",
    address: "1 Ocean View Drive",
    city: "Miami",
    state: "FL",
    zip_code: "33139",
    budget: 75000000.00,
    start_date: 2.months.from_now,
    estimated_completion_date: 30.months.from_now
  },
  {
    name: "School Modernization",
    description: "Comprehensive upgrade of elementary school facilities including new STEM labs",
    project_type: "existing_build",
    status: "active",
    address: "500 Education Avenue",
    city: "Denver",
    state: "CO",
    zip_code: "80202",
    budget: 4500000.00,
    start_date: 2.months.ago,
    estimated_completion_date: 3.months.from_now
  },
  {
    name: "Mountain Resort Lodge",
    description: "Boutique ski resort with 50 rooms, restaurant, and spa facilities",
    project_type: "new_build",
    status: "completed",
    address: "100 Alpine Peak Road",
    city: "Aspen",
    state: "CO",
    zip_code: "81611",
    budget: 35000000.00,
    start_date: 2.years.ago,
    estimated_completion_date: 3.months.ago
  }
]

projects_data.each do |project_data|
  project = company1.projects.find_or_create_by!(name: project_data[:name]) do |p|
    p.assign_attributes(project_data)
    puts "Creating project: #{p.name}"
  end
end

# Create a few projects for company2
company2_projects = [
  {
    name: "Urban Loft Conversion",
    description: "Converting old warehouse into 24 modern loft apartments",
    project_type: "existing_build",
    status: "active",
    address: "888 Industrial Street",
    city: "Chicago",
    state: "IL",
    zip_code: "60606",
    budget: 12000000.00,
    start_date: 1.month.ago,
    estimated_completion_date: 10.months.from_now
  },
  {
    name: "Suburban Medical Center",
    description: "New medical facility with emergency care, imaging center, and specialty clinics",
    project_type: "new_build",
    status: "planning",
    address: "2500 Healthcare Drive",
    city: "Houston",
    state: "TX",
    zip_code: "77002",
    budget: 55000000.00,
    start_date: 3.months.from_now,
    estimated_completion_date: 2.years.from_now
  },
  {
    name: "Boutique Hotel Refresh",
    description: "Complete interior renovation of 100-room boutique hotel",
    project_type: "existing_build",
    status: "active",
    address: "50 Luxury Lane",
    city: "Las Vegas",
    state: "NV",
    zip_code: "89109",
    budget: 8000000.00,
    start_date: 6.weeks.ago,
    estimated_completion_date: 4.months.from_now
  }
]

company2_projects.each do |project_data|
  project = company2.projects.find_or_create_by!(name: project_data[:name]) do |p|
    p.assign_attributes(project_data)
    puts "Creating project: #{p.name}"
  end
end

# Load notification types from configuration
puts "\nSeeding notification types..."
config_file = Rails.root.join("config", "notifications.yml")
if File.exist?(config_file)
  config = YAML.load_file(config_file)
  config["notification_types"].each do |key, attrs|
    NotificationType.register(
      key: key,
      name: attrs["name"],
      description: attrs["description"],
      category: attrs["category"],
      channels: attrs["channels"] || ["email"],
      default_enabled: attrs.fetch("default_enabled", true),
      force_enabled: attrs.fetch("force_enabled", false)
    )
    puts "  Created/updated notification type: #{attrs['name']}"
  end
else
  puts "  Warning: config/notifications.yml not found"
end

puts "\nSeed data created successfully!"
puts "Companies: #{Company.count}"
puts "Users: #{User.count}"
puts "Projects: #{Project.count}"
puts "Notification Types: #{NotificationType.count}"
puts "\nYou can log in with:"
puts "  Email: demo@example.com"
puts "  Email: john@example.com"
puts "\nProjects by company:"
Company.all.each do |company|
  puts "  #{company.name}: #{company.projects.count} projects"
end