require 'rails_helper'

RSpec.describe 'Seminar Management', type: :system do
  let(:user) { create(:user) }
  
  before { sign_in(user) }
  
  describe 'Creating a seminar' do
    it 'allows user to create a new seminar' do
      visit new_seminar_path
      
      fill_in 'Title', with: 'Guard Techniques Workshop'
      fill_in 'Description', with: 'Comprehensive guard techniques for all levels'
      fill_in 'Instructor name', with: 'John Doe'
      select 'Black', from: 'Instructor belt'
      fill_in 'Instructor lineage', with: 'Gracie Lineage'
      fill_in 'Seminar date', with: 1.week.from_now.strftime('%Y-%m-%d')
      fill_in 'Venue', with: 'Test BJJ Academy'
      fill_in 'Location', with: 'Test City, State'
      fill_in 'Price amount', with: '75.00'
      select 'USD', from: 'Price currency'
      
      click_button 'Create Seminar'
      
      expect(page).to have_content('Seminar was successfully created.')
      expect(page).to have_content('Guard Techniques Workshop')
      expect(page).to have_content('John Doe')
    end
    
    it 'prevents creating seminar with invalid data' do
      visit new_seminar_path
      
      fill_in 'Title', with: ''
      fill_in 'Description', with: ''
      
      click_button 'Create Seminar'
      
      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Description can't be blank")
    end
  end
  
  describe 'Viewing seminars' do
    let!(:seminar1) { create(:seminar, title: 'Guard Workshop', user: user) }
    let!(:seminar2) { create(:seminar, title: 'Submission Seminar', user: create(:user)) }
    
    it 'displays all seminars on index page' do
      visit seminars_path
      
      expect(page).to have_content('Guard Workshop')
      expect(page).to have_content('Submission Seminar')
    end
    
    it 'allows searching seminars' do
      visit seminars_path
      
      fill_in 'Search seminars...', with: 'Guard'
      click_button 'Search'
      
      expect(page).to have_content('Guard Workshop')
      expect(page).not_to have_content('Submission Seminar')
    end
    
    it 'shows seminar details on show page' do
      visit seminar_path(seminar1)
      
      expect(page).to have_content(seminar1.title)
      expect(page).to have_content(seminar1.description)
      expect(page).to have_content(seminar1.instructor_name)
      expect(page).to have_content(seminar1.venue)
    end
  end
  
  describe 'Editing seminars' do
    let!(:seminar) { create(:seminar, title: 'Original Title', user: user) }
    
    it 'allows user to edit their own seminar' do
      visit seminar_path(seminar)
      click_link 'Edit'
      
      fill_in 'Title', with: 'Updated Title'
      click_button 'Update Seminar'
      
      expect(page).to have_content('Seminar was successfully updated.')
      expect(page).to have_content('Updated Title')
    end
    
    it 'prevents editing other users\' seminars' do
      other_user_seminar = create(:seminar, user: create(:user))
      
      visit edit_seminar_path(other_user_seminar)
      
      expect(page).to have_content('You can only edit your own seminars.')
      expect(page).to have_current_path(seminars_path)
    end
  end
  
  describe 'Deleting seminars' do
    let!(:seminar) { create(:seminar, title: 'Seminar to Delete', user: user) }
    
    it 'allows user to delete their own seminar' do
      visit seminar_path(seminar)
      
      accept_confirm do
        click_link 'Delete'
      end
      
      expect(page).to have_content('Seminar was successfully deleted.')
      expect(page).not_to have_content('Seminar to Delete')
    end
  end
  
  describe 'Image upload', js: true do
    it 'allows user to upload images to seminar' do
      visit new_seminar_path
      
      fill_in 'Title', with: 'Seminar with Images'
      fill_in 'Description', with: 'Test description for image upload'
      fill_in 'Instructor name', with: 'Test Instructor'
      select 'Black', from: 'Instructor belt'
      fill_in 'Seminar date', with: 1.week.from_now.strftime('%Y-%m-%d')
      fill_in 'Venue', with: 'Test Venue'
      fill_in 'Location', with: 'Test Location'
      
      # Note: In a real test, you would attach actual test image files
      # attach_file 'Images', Rails.root.join('spec/fixtures/test_image.jpg')
      
      click_button 'Create Seminar'
      
      expect(page).to have_content('Seminar was successfully created.')
    end
  end
  
  describe 'Multi-step seminar creation workflow' do
    it 'guides user through complete seminar creation process' do
      visit root_path
      click_link 'Create Seminar'
      
      # Step 1: Basic seminar information
      fill_in 'Title', with: 'Advanced Guard Retention'
      fill_in 'Description', with: 'Comprehensive seminar on guard retention techniques'
      fill_in 'Instructor name', with: 'Marcelo Garcia'
      select 'Black', from: 'Instructor belt'
      fill_in 'Instructor lineage', with: 'Fabio Gurgel'
      
      # Step 2: Event details
      fill_in 'Seminar date', with: 2.weeks.from_now.strftime('%Y-%m-%d')
      fill_in 'Venue', with: 'Alliance BJJ Academy'
      fill_in 'Location', with: 'New York, NY'
      
      # Step 3: Pricing and submission
      fill_in 'Price amount', with: '120.00'
      select 'USD', from: 'Price currency'
      
      click_button 'Create Seminar'
      
      expect(page).to have_content('Seminar was successfully created.')
      expect(page).to have_content('Advanced Guard Retention')
      expect(page).to have_content('Marcelo Garcia')
      expect(page).to have_content('Alliance BJJ Academy')
      expect(page).to have_content('$120.00')
    end
    
    it 'handles validation errors gracefully throughout the process' do
      visit new_seminar_path
      
      # Submit with missing required fields
      click_button 'Create Seminar'
      
      expect(page).to have_content("Title can't be blank")
      expect(page).to have_content("Description can't be blank")
      expect(page).to have_content("Instructor name can't be blank")
      
      # Fix some errors but leave others
      fill_in 'Title', with: 'Test Seminar'
      click_button 'Create Seminar'
      
      expect(page).to have_content("Description can't be blank")
      expect(page).to have_content("Instructor name can't be blank")
      expect(page).to have_selector('input[name="seminar[title]"][value="Test Seminar"]')
    end
  end
  
  describe 'Seminar discovery and search workflows' do
    let!(:guard_seminar) { create(:seminar, title: 'Guard Workshop', instructor_name: 'Roger Gracie', location: 'London, UK', user: user) }
    let!(:submission_seminar) { create(:seminar, title: 'Submission Techniques', instructor_name: 'Gordon Ryan', location: 'Austin, TX', user: create(:user)) }
    let!(:defense_seminar) { create(:seminar, title: 'Escape Fundamentals', instructor_name: 'Xande Ribeiro', location: 'San Diego, CA', user: create(:user)) }
    
    it 'allows comprehensive search by various criteria' do
      visit seminars_path
      
      # Search by title
      fill_in 'Search seminars...', with: 'Guard'
      click_button 'Search'
      expect(page).to have_content('Guard Workshop')
      expect(page).not_to have_content('Submission Techniques')
      
      # Search by instructor
      fill_in 'Search seminars...', with: 'Gordon Ryan'
      click_button 'Search'
      expect(page).to have_content('Submission Techniques')
      expect(page).not_to have_content('Guard Workshop')
      
      # Search by location
      fill_in 'Search seminars...', with: 'London'
      click_button 'Search'
      expect(page).to have_content('Guard Workshop')
      expect(page).not_to have_content('Submission Techniques')
      
      # Clear search
      fill_in 'Search seminars...', with: ''
      click_button 'Search'
      expect(page).to have_content('Guard Workshop')
      expect(page).to have_content('Submission Techniques')
      expect(page).to have_content('Escape Fundamentals')
    end
    
    it 'provides filtering options for seminar discovery' do
      visit seminars_path
      
      # Should display all seminars initially
      expect(page).to have_content('Guard Workshop')
      expect(page).to have_content('Submission Techniques')
      expect(page).to have_content('Escape Fundamentals')
      
      # Test pagination if many seminars exist
      expect(page).to have_selector('.seminars-list')
    end
    
    it 'shows detailed seminar information in search results' do
      visit seminars_path
      
      within('.seminar-card', text: 'Guard Workshop') do
        expect(page).to have_content('Roger Gracie')
        expect(page).to have_content('London, UK')
        expect(page).to have_link('View Details')
      end
    end
  end
end