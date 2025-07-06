# Phlex configuration for Rails
# This initializer ensures Phlex components work properly with Rails

# Configure Phlex to work with Rails
if defined?(Phlex::Rails)
  # Enable automatic component reloading in development
  Rails.application.config.to_prepare do
    # This block runs before each request in development
    # and once in production to ensure components are loaded
  end
end

# Optional: Add any custom Phlex configurations here
# For example, if you want to add custom helpers to all components:
# Phlex::HTML.include(YourCustomHelpers)