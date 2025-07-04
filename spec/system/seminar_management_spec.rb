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
end