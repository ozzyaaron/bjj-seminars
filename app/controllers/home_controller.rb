class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @recent_seminars = Seminar.includes(:user, :players, :images_attachments)
                             .where("starts_at > ?", Time.current)
                             .order(:starts_at)
                             .limit(6)
    
    # Featured seminars could be marked as featured in the future
    @featured_seminars = []
    
    # Popular instructors based on seminar count
    @popular_instructors = Player.joins(:seminars)
                                .where(seminars: { starts_at: Time.current.. })
                                .group('players.id')
                                .order('COUNT(seminars.id) DESC')
                                .limit(6)
  end
end