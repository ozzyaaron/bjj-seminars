require 'rails_helper'

RSpec.describe "Home Page", type: :system do
  describe "visiting the home page" do
    it "displays the main heading and tagline" do
      visit root_path
      
      expect(page).to have_content("BJJ Seminar")
      expect(page).to have_content("Tracker")
      expect(page).to have_content("Discover, track, and share Brazilian Jiu-Jitsu seminars")
    end

    it "shows navigation links" do
      visit root_path
      
      expect(page).to have_link("Seminars")
      expect(page).to have_link("Teams")
      expect(page).to have_link("Players")
    end

    it "shows authentication links when not signed in" do
      visit root_path
      
      expect(page).to have_link("Sign in")
      expect(page).to have_link("Sign up")
      expect(page).to have_content("Ready to start tracking?")
    end

    context "when seminars exist" do
      let(:user) { create(:user) }
      let(:team) { create(:team) }
      let(:player) { create(:player, team: team) }
      
      before do
        seminar = create(:seminar, :future, user: user)
        seminar.players << player
      end

      it "displays recent seminars section" do
        visit root_path
        
        expect(page).to have_content("Recent Seminars")
        expect(page).to have_content("Discover the latest BJJ seminars")
        expect(page).to have_link("View All Seminars")
      end

      it "shows seminar information in cards" do
        visit root_path
        
        # Should show seminar details
        expect(page).to have_content(Seminar.first.title)
        expect(page).to have_content("View Details")
        expect(page).to have_content(user.email.split('@').first) # Posted by user
      end
    end

    context "when signed in" do
      let(:user) { create(:user) }
      
      before do
        sign_in(user)
      end

      it "shows user-specific navigation" do
        visit root_path
        
        expect(page).to have_link("Add Seminar")
        expect(page).to have_link("Sign out")
        expect(page).not_to have_content("Ready to start tracking?")
      end
    end
  end
end