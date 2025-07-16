# Step definitions for seminar filtering

Given('the following seminars exist:') do |table|
  table.hashes.each do |row|
    player = Player.find_by!(name: row['player'])
    user = User.first || FactoryBot.create(:user)
    
    # Parse city and state from address
    city = row['city'] || 'San Francisco'
    state = 'CA'
    if row['address'].include?('NY')
      state = 'NY'
    elsif row['address'].include?('TX')
      state = 'TX'
    end
    
    seminar = Seminar.create!(
      title: row['title'],
      description: "Description for #{row['title']}",
      address: row['address'],
      city: city,
      state: state,
      zip_code: '12345',
      starts_at: DateTime.parse(row['starts_at']),
      ends_at: DateTime.parse(row['starts_at']) + 3.hours,
      user: user
    )
    
    seminar.players << player
  end
end

When('I clear the {string} field') do |field|
  fill_in field, with: ''
end

Then('I should see all {int} seminars') do |count|
  expect(page).to have_css('.seminar-card', count: count)
end

# These steps are already defined in other step definition files