class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @recent_seminars = Seminar.includes(:user, :players, :images_attachments)
                             .where("starts_at > ?", Time.current)
                             .order(:starts_at)
                             .limit(6)
  end
end