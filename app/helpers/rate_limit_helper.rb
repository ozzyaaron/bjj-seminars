module RateLimitHelper
  def rate_limit_info_for_user
    return unless user_signed_in?
    
    user = current_user
    remaining_seminars = [25 - user.daily_seminar_count, 0].max
    next_reset = user.last_seminar_created_at&.beginning_of_day&.+ 1.day || Time.current.beginning_of_day + 1.day
    
    {
      remaining_seminars: remaining_seminars,
      next_reset: next_reset,
      can_create: user.can_create_seminar?
    }
  end

  def format_time_until_reset(reset_time)
    return 'now' if reset_time <= Time.current
    
    duration = reset_time - Time.current
    
    if duration < 1.hour
      "#{(duration / 60).to_i} minutes"
    elsif duration < 1.day
      "#{(duration / 1.hour).to_i} hours"
    else
      "#{(duration / 1.day).to_i} days"
    end
  end

  def rate_limit_warning_message
    info = rate_limit_info_for_user
    return unless info && info[:remaining_seminars] <= 5
    
    if info[:remaining_seminars] == 0
      "You've reached your daily limit of 25 seminars. Limit resets in #{format_time_until_reset(info[:next_reset])}."
    else
      "You have #{info[:remaining_seminars]} seminar#{'s' unless info[:remaining_seminars] == 1} remaining today."
    end
  end
end