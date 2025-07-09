Given('I am on the new seminar page') do
  visit new_seminar_path
end

Given('I have created a seminar titled {string}') do |title|
  @my_seminar = FactoryBot.create(:seminar, 
    title: title, 
    user: @current_user,
    description: 'A comprehensive seminar for all levels'
  )
end

Given('there is a seminar titled {string} created by another user') do |title|
  other_user = FactoryBot.create(:user, email: 'other@example.com')
  @other_seminar = FactoryBot.create(:seminar, 
    title: title, 
    user: other_user,
    description: 'A comprehensive seminar for all levels'
  )
end

Given('there is a seminar created by another user') do
  other_user = FactoryBot.create(:user, email: 'other@example.com')
  @other_seminar = FactoryBot.create(:seminar, 
    title: 'Other User Seminar', 
    user: other_user,
    description: 'A comprehensive seminar for all levels'
  )
end

Given('there are multiple seminars available') do
  3.times do |i|
    FactoryBot.create(:seminar, 
      title: "Seminar #{i + 1}", 
      description: 'A comprehensive seminar for all levels'
    )
  end
end

Given('there is a seminar titled {string}') do |title|
  FactoryBot.create(:seminar, 
    title: title,
    description: 'A comprehensive seminar for all levels'
  )
end

Given('I have already created {int} seminars today') do |count|
  @current_user.update(daily_seminar_count: count, last_seminar_created_at: Time.current)
end

When('I select {string} from {string}') do |value, field|
  select value, from: field
end

When('I visit the seminar show page') do
  seminar = @my_seminar || @other_seminar
  visit seminar_path(seminar)
end

When('I am on the seminar edit page') do
  visit edit_seminar_path(@my_seminar)
end

When('I try to visit the edit page for that seminar') do
  visit edit_seminar_path(@other_seminar)
end

When('I try to delete that seminar') do
  visit seminar_path(@other_seminar)
  click_button 'Delete Seminar' if page.has_button?('Delete Seminar')
end

When('I visit the seminars page') do
  visit seminars_path
end

When('I fill in the search field with {string}') do |query|
  fill_in 'search', with: query
end

When('I click {string}') do |link_or_button|
  click_link_or_button link_or_button
end

When('I confirm the deletion') do
  page.accept_confirm if page.respond_to?(:accept_confirm)
end

When('I attach an image file {string}') do |filename|
  attach_file 'seminar[images][]', Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')
end

When('I fill in all required seminar fields') do
  fill_in 'Title', with: 'Test Seminar'
  fill_in 'Description', with: 'A comprehensive test seminar for all levels'
  fill_in 'Address', with: '123 Test Street'
  fill_in 'City', with: 'Test City'
  select 'CA', from: 'State'
  fill_in 'Zip code', with: '12345'
  select 'US', from: 'Country'
  fill_in 'Starts at', with: 1.week.from_now.strftime('%Y-%m-%d %H:%M')
  fill_in 'Ends at', with: (1.week.from_now + 3.hours).strftime('%Y-%m-%d %H:%M')
end

When('I try to create another seminar') do
  visit new_seminar_path
  fill_in 'Title', with: 'Limit Test Seminar'
  fill_in 'Description', with: 'Testing the daily limit functionality'
  fill_in 'Address', with: '123 Test Street'
  fill_in 'City', with: 'Test City'
  select 'CA', from: 'State'
  fill_in 'Zip code', with: '12345'
  select 'US', from: 'Country'
  fill_in 'Starts at', with: 1.week.from_now.strftime('%Y-%m-%d %H:%M')
  fill_in 'Ends at', with: (1.week.from_now + 3.hours).strftime('%Y-%m-%d %H:%M')
  click_button 'Create Seminar'
end

Then('I should be redirected to the seminar show page') do
  expect(current_path).to match(%r{/seminars/\d+})
end

Then('I should remain on the new seminar page') do
  expect(current_path).to eq(new_seminar_path)
end

Then('I should be redirected to the seminars index page') do
  expect(current_path).to eq(seminars_path)
end

Then('I should see seminar cards with titles and details') do
  expect(page).to have_css('.seminar-card', minimum: 1)
end

Then('I should see search and filter options') do
  expect(page).to have_field('search')
end

Then('I should see the seminar with the uploaded image') do
  expect(page).to have_css('img')
end

Then('the image should be displayed in the seminar card') do
  expect(page).to have_css('.seminar-card img')
end

Then('the seminar should not be created') do
  expect(page).to have_content('Daily seminar creation limit reached')
end