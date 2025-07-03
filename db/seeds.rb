# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Create admin user
admin = User.find_or_create_by!(email: "admin@bjjseminars.com") do |user|
  user.password = "password123"
  user.password_confirmation = "password123"
  user.admin = true
end
puts "✅ Created admin user: #{admin.email}"

# Create regular users
regular_users = [
  { email: "user1@example.com", password: "password123" },
  { email: "user2@example.com", password: "password123" },
  { email: "user3@example.com", password: "password123" }
]

regular_users.each do |user_attrs|
  user = User.find_or_create_by!(email: user_attrs[:email]) do |u|
    u.password = user_attrs[:password]
    u.password_confirmation = user_attrs[:password]
    u.admin = false
  end
  puts "✅ Created user: #{user.email}"
end

# Create BJJ teams
teams_data = [
  { name: "Gracie Barra", description: "One of the largest BJJ teams in the world", country: "BR" },
  { name: "Alliance", description: "Competition-focused BJJ team", country: "BR" },
  { name: "Atos Jiu-Jitsu", description: "Elite BJJ academy", country: "US" },
  { name: "Checkmat", description: "International BJJ team", country: "BR" },
  { name: "Unity Jiu-Jitsu", description: "Modern BJJ methodology", country: "US" },
  { name: "10th Planet Jiu-Jitsu", description: "No-gi focused BJJ system", country: "US" }
]

teams_data.each do |team_data|
  team = Team.find_or_create_by!(name: team_data[:name]) do |t|
    t.description = team_data[:description]
    t.country = team_data[:country]
  end
  puts "✅ Created team: #{team.name}"
end

# Create famous BJJ players
players_data = [
  { name: "Marcus 'Buchecha' Almeida", nationality: "Brazilian", team: "Checkmat", bio: "Multiple-time IBJJF World Champion and ADCC Champion" },
  { name: "Gordon Ryan", nationality: "American", team: "B-Team Jiu-Jitsu", bio: "ADCC and EBI Champion, considered one of the best no-gi grapplers" },
  { name: "André Galvão", nationality: "Brazilian", team: "Atos Jiu-Jitsu", bio: "ADCC Champion and UFC veteran" },
  { name: "Rafael Mendes", nationality: "Brazilian", team: "Art of Jiu-Jitsu", bio: "5x IBJJF World Champion" },
  { name: "Mackenzie Dern", nationality: "American", team: "Legacy Fighting Alliance", bio: "UFC fighter and IBJJF World Champion" },
  { name: "Leandro Lo", nationality: "Brazilian", team: "NS Brotherhood", bio: "8x IBJJF World Champion" },
  { name: "Kyra Gracie", nationality: "Brazilian", team: "Gracie Humaitá", bio: "ADCC Champion and member of the Gracie family" },
  { name: "Eddie Bravo", nationality: "American", team: "10th Planet Jiu-Jitsu", bio: "Founder of 10th Planet Jiu-Jitsu system" }
]

players_data.each do |player_data|
  # Find team by name, allow nil if team doesn't exist
  team = Team.find_by(name: player_data[:team])
  
  player = Player.find_or_create_by!(name: player_data[:name]) do |p|
    p.nationality = player_data[:nationality]
    p.team = team
    p.bio = player_data[:bio]
  end
  puts "✅ Created player: #{player.name}"
end

# Create future seminars (only in development environment)
if Rails.env.development?
  puts "🏗️  Creating development seminars..."
  
  # Helper method to create seminars
  def create_seminar(user, title, description, city, state, start_time, players_names = [])
    # Skip if starts_at is in the past (would violate database constraint)
    return if start_time <= Time.current
    
    seminar = Seminar.find_or_create_by!(
      title: title,
      user: user,
      starts_at: start_time
    ) do |s|
      s.description = description
      s.address = "123 Main Street"
      s.city = city
      s.state = state
      s.country = "US"
      s.zip_code = "12345"
      s.ends_at = start_time + 3.hours
    end
    
    # Add players to seminar
    players_names.each do |player_name|
      player = Player.find_by(name: player_name)
      if player && !seminar.players.include?(player)
        seminar.players << player
      end
    end
    
    seminar
  rescue => e
    puts "⚠️  Could not create seminar '#{title}': #{e.message}"
    nil
  end
  
  # Create seminars in different cities
  seminar_data = [
    {
      title: "Gordon Ryan No-Gi Masterclass",
      description: "Learn advanced no-gi techniques from one of the world's best grapplers. Focus on leg locks, back takes, and submission chains.",
      city: "Austin",
      state: "TX", 
      start_time: 2.weeks.from_now,
      players: ["Gordon Ryan"]
    },
    {
      title: "André Galvão Competition Prep",
      description: "Intensive training camp focused on competition strategy, mental preparation, and advanced techniques.",
      city: "San Diego",
      state: "CA",
      start_time: 3.weeks.from_now,
      players: ["André Galvão"]
    },
    {
      title: "Rafael Mendes Guard Mastery",
      description: "Deep dive into berimbolo, De La Riva guard, and modern guard concepts with a legend of the sport.",
      city: "Los Angeles", 
      state: "CA",
      start_time: 1.month.from_now,
      players: ["Rafael Mendes"]
    },
    {
      title: "Mackenzie Dern Women's Self-Defense",
      description: "Self-defense seminar specifically designed for women, covering practical techniques and situational awareness.",
      city: "Miami",
      state: "FL",
      start_time: 5.weeks.from_now,
      players: ["Mackenzie Dern"]
    },
    {
      title: "Eddie Bravo 10th Planet System",
      description: "Introduction to the 10th Planet system including rubber guard, twister, and lockdown techniques.",
      city: "Denver",
      state: "CO",
      start_time: 6.weeks.from_now,
      players: ["Eddie Bravo"]
    },
    {
      title: "Multi-Champion Workshop",
      description: "Special event featuring multiple world champions sharing their favorite techniques and training methods.",
      city: "New York",
      state: "NY",
      start_time: 2.months.from_now,
      players: ["Marcus 'Buchecha' Almeida", "Leandro Lo", "Kyra Gracie"]
    }
  ]
  
  created_seminars = []
  seminar_data.each do |data|
    # Rotate between users for variety
    user = User.where(admin: false).sample || admin
    
    seminar = create_seminar(
      user,
      data[:title],
      data[:description], 
      data[:city],
      data[:state],
      data[:start_time],
      data[:players]
    )
    
    if seminar
      created_seminars << seminar
      puts "✅ Created seminar: #{seminar.title} in #{seminar.city}, #{seminar.state}"
    end
  end
  
  puts "📊 Summary:"
  puts "   Teams: #{Team.count}"
  puts "   Players: #{Player.count}" 
  puts "   Users: #{User.count}"
  puts "   Seminars: #{Seminar.count}"
  puts "   Admin user: admin@bjjseminars.com / password123"
end

puts "🌱 Database seeding completed!"
