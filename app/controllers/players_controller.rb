class PlayersController < ApplicationController
  before_action :set_player, only: [:show, :edit, :update, :destroy]
  before_action :require_admin!, except: [:index, :show]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @players = Player.includes(:team).order(:name)
    
    # Apply search and filters
    if params[:search].present?
      @players = @players.where("name ILIKE ? OR biography ILIKE ?", 
                               "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    if params[:team_id].present?
      @players = @players.where(team_id: params[:team_id])
    end
    
    if params[:belt_rank].present?
      @players = @players.where(belt_rank: params[:belt_rank])
    end
    
    @teams = Team.order(:name)
    @belt_ranks = Player.distinct.pluck(:belt_rank).compact.sort
  end

  def show
    @upcoming_seminars = Seminar.joins(:players)
                               .where(players: { id: @player.id })
                               .where("starts_at > ?", Time.current)
                               .includes(:user, :players, :images_attachments)
                               .order(:starts_at)
                               .limit(6)
                               
    @past_seminars = Seminar.joins(:players)
                           .where(players: { id: @player.id })
                           .where("starts_at < ?", Time.current)
                           .includes(:user, :players, :images_attachments)
                           .order(starts_at: :desc)
                           .limit(6)
  end

  def new
    @player = Player.new
    @teams = Team.order(:name)
  end

  def create
    @player = Player.new(player_params)
    
    if @player.save
      redirect_to @player, notice: "Player created successfully"
    else
      @teams = Team.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @teams = Team.order(:name)
  end

  def update
    if @player.update(player_params)
      redirect_to @player, notice: "Player updated successfully"
    else
      @teams = Team.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @player.destroy
    redirect_to players_path, notice: "Player deleted successfully"
  end

  private

  def set_player
    @player = Player.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name, :team_id, :belt_rank, :biography)
  end
end