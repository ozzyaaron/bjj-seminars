class SeminarsController < ApplicationController
  before_action :set_seminar, only: [:show, :edit, :update, :destroy]
  before_action :ensure_owner, only: [:edit, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @seminars = Seminar.includes(:user, :players, :images_attachments)
                      .where("starts_at > ?", Time.current)
                      .order(:starts_at)
    
    # Apply search and filters if present
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      seminars_table = Seminar.arel_table
      players_table = Player.arel_table
      
      @seminars = @seminars.joins(:players)
                          .where(
                            seminars_table[:title].matches(search_term)
                            .or(seminars_table[:description].matches(search_term))
                            .or(seminars_table[:address].matches(search_term))
                            .or(players_table[:name].matches(search_term))
                          )
                          .distinct
    end
    
    if params[:location].present?
      @seminars = @seminars.where(Seminar.arel_table[:address].matches("%#{params[:location]}%"))
    end
    
    if params[:instructor].present?
      @seminars = @seminars.joins(:players).where(Player.arel_table[:name].matches("%#{params[:instructor]}%"))
    end
  end

  def show
    @related_seminars = Seminar.includes(:user, :players, :images_attachments)
                              .where("starts_at > ? AND id != ?", Time.current, @seminar.id)
                              .limit(3)
  end

  def new
    @seminar = current_user.seminars.build
    @teams = Team.all
    @players = Player.all
  end

  def create
    @seminar = current_user.seminars.build(seminar_params)
    
    if @seminar.save
      current_user.increment_daily_seminar_count!
      redirect_to @seminar, notice: "Seminar created successfully"
    else
      @teams = Team.all
      @players = Player.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @teams = Team.all
    @players = Player.all
  end

  def update
    if @seminar.update(seminar_params)
      redirect_to @seminar, notice: "Seminar updated successfully"
    else
      @teams = Team.all
      @players = Player.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @seminar.destroy
    redirect_to seminars_path, notice: "Seminar deleted successfully"
  end

  private

  def set_seminar
    @seminar = Seminar.find(params[:id])
  end

  def ensure_owner
    unless @seminar.user == current_user || admin_user?
      redirect_to @seminar, alert: "You don't have permission to perform this action"
    end
  end

  def seminar_params
    params.require(:seminar).permit(:title, :description, :starts_at, :address, :price, :max_participants, player_ids: [], images: [])
  end
end