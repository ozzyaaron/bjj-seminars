# Configure Rack::Attack rate limiting
class Rack::Attack
  # Allow localhost in development/test
  safelist('allow-localhost') do |req|
    %w[127.0.0.1 ::1].include?(req.ip) if Rails.env.development? || Rails.env.test?
  end

  # Allow admin users more generous limits
  safelist('allow-admin') do |req|
    user = Current.user
    user&.admin?
  end

  # Throttle registration attempts: 1 registration per IP per day
  throttle('registrations/ip', limit: 1, period: 24.hours) do |req|
    if req.path == '/signup' && req.post?
      req.ip
    end
  end

  # Throttle login attempts: 5 attempts per IP per hour
  throttle('logins/ip', limit: 5, period: 1.hour) do |req|
    if req.path == '/login' && req.post?
      req.ip
    end
  end

  # Throttle login attempts per email: 3 attempts per email per hour
  throttle('logins/email', limit: 3, period: 1.hour) do |req|
    if req.path == '/login' && req.post?
      req.params['email']&.downcase
    end
  end

  # Throttle seminar creation: 25 seminars per user per day (handled in application logic)
  # But also limit by IP as a backup: 30 seminar creations per IP per day
  throttle('seminars/ip', limit: 30, period: 24.hours) do |req|
    if req.path == '/seminars' && req.post?
      req.ip
    end
  end

  # Throttle general API requests: 300 requests per IP per hour
  throttle('req/ip', limit: 300, period: 1.hour) do |req|
    req.ip unless req.path.start_with?('/assets', '/packs', '/favicon')
  end

  # Throttle POST requests more strictly: 60 per IP per hour
  throttle('posts/ip', limit: 60, period: 1.hour) do |req|
    if %w[POST PUT PATCH DELETE].include?(req.request_method)
      req.ip
    end
  end

  # Block suspicious user agents
  blocklist('block-bad-user-agents') do |req|
    bad_agents = [
      'BadBot',
      'ScanBot', 
      'PetalBot',
      'DataForSeoBot'
    ]
    
    user_agent = req.user_agent.to_s
    bad_agents.any? { |agent| user_agent.include?(agent) }
  end

  # Block requests with suspicious paths
  blocklist('block-bad-paths') do |req|
    bad_paths = [
      '/wp-admin',
      '/wp-login',
      '/.env',
      '/admin.php',
      '/phpmyadmin'
    ]
    
    bad_paths.any? { |path| req.path.include?(path) }
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    match_data = request.env['rack.attack.match_data']
    now = match_data[:epoch_time]
    
    headers = {
      'RateLimit-Limit' => match_data[:limit].to_s,
      'RateLimit-Remaining' => '0',
      'RateLimit-Reset' => (now + (match_data[:period] - (now % match_data[:period]))).to_s,
      'Retry-After' => match_data[:period].to_s,
      'Content-Type' => 'application/json'
    }
    
    body = {
      error: 'Rate limit exceeded',
      message: 'Too many requests. Please try again later.',
      retry_after: match_data[:period]
    }.to_json
    
    [429, headers, [body]]
  end

  # Custom response for blocked requests
  self.blocklisted_responder = lambda do |request|
    [403, { 'Content-Type' => 'application/json' }, [{ error: 'Forbidden', message: 'Access denied' }.to_json]]
  end

  # Store in Rails cache
  Rack::Attack.cache.store = Rails.cache
end

# Enable rate limiting in production and staging
unless Rails.env.development? || Rails.env.test?
  Rails.application.config.middleware.use Rack::Attack
end