require 'rails_helper'

RSpec.describe "Component Rendering", type: :request do
  describe "GET /" do
    it "renders home page successfully" do
      get root_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include("BJJ Seminar")
      expect(response.body).to include("Tracker")
    end

    context "with seminars" do
      let(:user) { create(:user) }
      let(:team) { create(:team) }
      let(:player) { create(:player, team: team) }
      
      before do
        seminar = create(:seminar, :future, user: user)
        seminar.players << player
      end

      it "renders seminar content" do
        get root_path
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Recent Seminars")
        expect(response.body).to include(Seminar.first.title)
      end
    end
  end

  describe "GET /seminars" do
    let(:user) { create(:user) }
    
    it "renders seminars index page" do
      get seminars_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include("BJJ Seminars")
      expect(response.body).to include("Discover upcoming Brazilian Jiu-Jitsu seminars")
    end

    context "with seminars" do
      before do
        team = create(:team)
        player = create(:player, team: team)
        seminar = create(:seminar, :future, user: user)
        seminar.players << player
      end

      it "displays seminar cards" do
        get seminars_path
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include(Seminar.first.title)
        expect(response.body).to include("View Details")
      end
    end
  end

  describe "GET /teams" do
    it "renders teams index page" do
      get teams_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include("BJJ Teams")
      expect(response.body).to include("Discover Brazilian Jiu-Jitsu teams")
    end

    context "with teams" do
      before do
        create(:team)
      end

      it "displays team cards" do
        get teams_path
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include(Team.first.name)
        expect(response.body).to include("View Team")
      end
    end
  end

  describe "GET /players" do
    it "renders players index page" do
      get players_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include("BJJ Players")
      expect(response.body).to include("Discover Brazilian Jiu-Jitsu instructors")
    end

    context "with players" do
      before do
        team = create(:team)
        create(:player, team: team)
      end

      it "displays player information" do
        get players_path
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include(Player.first.name)
        expect(response.body).to include(Team.first.name)
      end
    end
  end

  describe "GET /login" do
    it "renders login form" do
      get login_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Sign in to your account")
      expect(response.body).to include("Email address")
      expect(response.body).to include("Password")
    end
  end

  describe "GET /signup" do
    it "renders registration form" do
      get new_user_registration_path
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Create your account")
      expect(response.body).to include("Email address")
      expect(response.body).to include("Password")
    end
  end

  describe "authenticated routes" do
    let(:user) { create(:user) }
    
    before do
      sign_in(user)
    end

    describe "GET /seminars/new" do
      it "renders seminar creation form" do
        get new_seminar_path
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Add New Seminar")
        expect(response.body).to include("Basic Information")
        expect(response.body).to include("Instructors")
        expect(response.body).to include("Images")
      end
    end

    describe "GET /seminars/:id" do
      let(:team) { create(:team) }
      let(:player) { create(:player, team: team) }
      let(:seminar) { create(:seminar, user: user) }
      
      before do
        seminar.players << player
      end

      it "renders seminar details" do
        get seminar_path(seminar)
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include(seminar.title)
        expect(response.body).to include("Seminar Details")
        expect(response.body).to include(player.name)
      end
    end
  end

  describe "admin routes" do
    let(:admin) { create(:user, :admin) }
    
    before do
      sign_in(admin)
    end

    describe "GET /teams/new" do
      it "renders team creation form" do
        get new_team_path
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Add New Team")
        expect(response.body).to include("Team Name")
      end
    end

    describe "GET /players/new" do
      it "renders player creation form" do
        get new_player_path
        
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Add New Player")
        expect(response.body).to include("Full Name")
        expect(response.body).to include("Belt Rank")
      end
    end
  end
end