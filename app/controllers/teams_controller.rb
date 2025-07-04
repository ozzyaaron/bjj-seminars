class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy]
  before_action :require_admin!, except: [:index, :show]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @teams = Team.includes(:players).order(:name)
    
    if params[:search].present?
      @teams = @teams.where("name ILIKE ? OR location ILIKE ?", 
                           "%#{params[:search]}%", "%#{params[:search]}%")
    end
  end

  def show
    @players = @team.players.order(:name)
    @recent_seminars = Seminar.joins(:players)
                             .where(players: { team: @team })
                             .where("starts_at > ?", Time.current)
                             .includes(:user, :players, :images_attachments)
                             .order(:starts_at)
                             .limit(6)
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    
    if @team.save
      redirect_to @team, notice: "Team created successfully"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: "Team updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_path, notice: "Team deleted successfully"
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :location, :website, :description)
  end
end