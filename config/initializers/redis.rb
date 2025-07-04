# Redis configuration for caching and rate limiting
if Rails.env.production?
  # Use Redis for cache and rate limiting in production
  redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')
  
  # Configure Redis for Rails cache
  Rails.application.configure do
    config.cache_store = :redis_cache_store, {
      url: redis_url,
      expires_in: 30.minutes,
      namespace: 'bjj_seminar_tracker_cache'
    }
  end
  
  # Configure Redis for Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: redis_url,
    namespace: 'bjj_seminar_tracker_rate_limit'
  )
else
  # Use memory store in development/test
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
end