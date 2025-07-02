# BJJ Seminar Tracker Implementation Plan

## Project Overview

This is a Rails 8.0 application for tracking Brazilian Jiu-Jitsu seminars with dual functionality as both a web application and a Progressive Web App (PWA). The system allows users to discover seminars by location and instructor while requiring authentication for seminar creation.

## Database Schema with Constraints

### Core Models with Database Constraints

#### User Model
```ruby
# Database constraints:
# - email: NOT NULL, UNIQUE index
# - password_digest: NOT NULL
# - admin: BOOLEAN DEFAULT false NOT NULL
# - daily_seminar_count: INTEGER DEFAULT 0 CHECK (daily_seminar_count >= 0 AND daily_seminar_count <= 25)
# - last_seminar_created_at: TIMESTAMP
```

#### Team Model
```ruby
# Database constraints:
# - name: NOT NULL, UNIQUE index
# - description: TEXT
# - country: VARCHAR(2) DEFAULT 'US'
```

#### Player Model
```ruby
# Database constraints:
# - name: NOT NULL
# - nationality: NOT NULL
# - team_id: FOREIGN KEY (optional)
# - bio: TEXT
```

#### Seminar Model
```ruby
# Database constraints:
# - title: NOT NULL, VARCHAR(200)
# - description: NOT NULL, TEXT
# - starts_at: NOT NULL, TIMESTAMP CHECK (starts_at > CURRENT_TIMESTAMP)
# - ends_at: TIMESTAMP CHECK (ends_at IS NULL OR ends_at > starts_at)
# - user_id: NOT NULL, FOREIGN KEY
# - address: NOT NULL
# - city: NOT NULL, VARCHAR(100)
# - state: NOT NULL, VARCHAR(2)
# - zip_code: VARCHAR(10)
# - latitude: DECIMAL(10,6)
# - longitude: DECIMAL(10,6)
# - primary_image_id: FOREIGN KEY to SeminarImage
```

#### SeminarPlayer (Join Table)
```ruby
# Database constraints:
# - seminar_id: NOT NULL, FOREIGN KEY
# - player_id: NOT NULL, FOREIGN KEY
# - UNIQUE INDEX on (seminar_id, player_id)
```

#### SeminarImage Model
```ruby
# Database constraints:
# - seminar_id: NOT NULL, FOREIGN KEY
# - position: INTEGER NOT NULL
# - primary: BOOLEAN DEFAULT false
# - UNIQUE INDEX on (seminar_id, position)
# - UNIQUE INDEX on (seminar_id) WHERE primary = true (only one primary per seminar)
# - CHECK constraint: max 10 images per seminar
```

#### NotificationRequest Model
```ruby
# Database constraints:
# - user_id: NOT NULL, FOREIGN KEY
# - player_ids: JSON (for specific player following)
# - city: VARCHAR(100)
# - state: VARCHAR(2)
# - active: BOOLEAN DEFAULT true NOT NULL
```

#### NotificationDelivery Model
```ruby
# Database constraints:
# - user_id: NOT NULL, FOREIGN KEY
# - seminar_id: NOT NULL, FOREIGN KEY
# - delivered_at: NOT NULL, TIMESTAMP
# - UNIQUE INDEX on (user_id, seminar_id) to prevent duplicate notifications
```

## Validation Strategy (Dual Layer)

### Database Level Protections
- NOT NULL constraints on required fields
- UNIQUE constraints on email, team names
- CHECK constraints for numeric limits (image count ≤ 10, seminars ≤ 25/day)
- FOREIGN KEY constraints with proper cascade rules
- INDEX constraints for performance and uniqueness
- Triggers for complex business rules

### Rails Model Level Validations
```ruby
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validate :daily_seminar_limit
  
  private
  
  def daily_seminar_limit
    return unless daily_seminar_count >= 25
    errors.add(:base, "Daily seminar creation limit reached")
  end
end

class Seminar < ApplicationRecord
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :starts_at, presence: true, comparison: { greater_than: Time.current }
  validates :address, :city, :state, presence: true
  validates :state, format: { with: /\A[A-Z]{2}\z/ }
  validate :ends_at_after_starts_at
  
  private
  
  def ends_at_after_starts_at
    return unless ends_at && starts_at
    errors.add(:ends_at, "must be after start time") if ends_at <= starts_at
  end
end
```

## Rate Limiting Strategy

### Account Creation
- **Limit:** 1 account per IP per day
- **Implementation:** Rack::Attack + database tracking
- **Database constraint:** IP tracking table with daily reset

### Seminar Creation
- **Limit:** 25 seminars per user per day
- **Implementation:** Database CHECK constraint + Rails validation
- **Reset mechanism:** Daily counter reset at midnight UTC

## Component Architecture with Phlex

### Component Structure
```
app/views/components/
├── application_component.rb
├── seminar_card.rb
├── player_profile.rb
├── image_gallery.rb
├── search_form.rb
├── notification_settings.rb
└── ui/
    ├── button.rb
    ├── form_field.rb
    └── modal.rb
```

### Example Component
```ruby
class SeminarCard < ApplicationComponent
  def initialize(seminar:, show_edit: false)
    @seminar = seminar
    @show_edit = show_edit
  end

  private

  attr_reader :seminar, :show_edit

  def template
    article(class: "bg-white rounded-lg shadow-md p-6") do
      header(class: "mb-4") do
        h3(class: "text-xl font-bold") { seminar.title }
        p(class: "text-gray-600") { seminar.formatted_date }
      end
      
      div(class: "mb-4") do
        render ImageGallery.new(images: seminar.images, primary: seminar.primary_image)
      end
      
      footer(class: "flex justify-between items-center") do
        render PlayerProfiles.new(players: seminar.players)
        render EditButton.new(seminar: seminar) if show_edit
      end
    end
  end
end
```

## Progressive Web App Implementation

### PWA Strategy (Hybrid Approach)
- **Architecture:** Server-rendered HTML with Phlex components + Turbo
- **Navigation:** Turbo for SPA-like experience
- **Offline:** Service worker caches rendered pages
- **Enhancement:** Progressive enhancement with Stimulus
- **Notifications:** Rails Action Cable + web-push gem

### Service Worker Features
```javascript
// app/views/pwa/service-worker.js
const CACHE_NAME = 'bjj-seminar-tracker-v1';
const urlsToCache = [
  '/',
  '/seminars',
  '/players',
  '/offline'
];

// Cache-first for static assets
// Network-first for dynamic content
// Offline fallbacks for key pages
// Background sync for form submissions
```

### PWA Manifest Configuration
```json
{
  "name": "BJJ Seminar Tracker",
  "short_name": "BJJ Seminars",
  "description": "Track and discover Brazilian Jiu-Jitsu seminars",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#1f2937",
  "icons": [
    {
      "src": "/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

## Image Management System

### SeminarImage Implementation
- **Storage:** Active Storage with variants
- **Limits:** Maximum 10 images per seminar (database constraint)
- **Primary Image:** Only one primary image per seminar (unique constraint)
- **Upload:** Direct upload with client-side compression
- **Variants:** Thumbnail (300x200), medium (600x400), large (1200x800)

### Upload Flow
1. Client selects multiple images
2. Client-side compression and validation
3. Direct upload to Active Storage
4. Background job processes variants
5. Database records created with constraints enforced

## Testing Stack with POROs

### Testing Framework
- **Unit/Integration:** RSpec
- **BDD:** Cucumber
- **System:** Capybara + Selenium
- **LSP Support:** ruby-lsp, rspec-lsp, cucumber-lsp

### PORO-based Test Data Strategy

#### Custom Builder Classes
```ruby
# spec/support/builders/seminar_builder.rb
class SeminarBuilder
  def self.build_valid_seminar(overrides = {})
    defaults = {
      title: "BJJ Fundamentals Seminar",
      description: Faker::Lorem.paragraph,
      starts_at: 1.week.from_now,
      ends_at: 1.week.from_now + 3.hours,
      address: "123 Main St",
      city: "Austin",
      state: "TX",
      zip_code: "78701"
    }
    OpenStruct.new(defaults.merge(overrides))
  end
  
  def self.create_seminar_with_images(image_count: 3)
    user = UserBuilder.create_user
    seminar = Seminar.create!(build_valid_seminar(user: user).to_h)
    
    image_count.times do |i|
      seminar.images.create!(
        position: i + 1,
        primary: i.zero?
      )
    end
    
    seminar
  end
end
```

#### Test Helper Modules
```ruby
# spec/support/seminar_helpers.rb
module SeminarHelpers
  def create_user_with_seminars(seminar_count: 2)
    user = User.create!(UserBuilder.build_valid_user.to_h)
    
    seminar_count.times do
      Seminar.create!(SeminarBuilder.build_valid_seminar(user: user).to_h)
    end
    
    user
  end
  
  def create_complete_seminar_setup
    team = Team.create!(name: "Gracie Barra", country: "BR")
    player = Player.create!(name: "Carlos Gracie Jr.", nationality: "Brazilian", team: team)
    user = User.create!(UserBuilder.build_valid_user.to_h)
    seminar = Seminar.create!(SeminarBuilder.build_valid_seminar(user: user).to_h)
    seminar.players << player
    
    { team: team, player: player, user: user, seminar: seminar }
  end
end
```

### Validation Testing Examples
```ruby
# spec/models/seminar_spec.rb
RSpec.describe Seminar, type: :model do
  describe "database constraints" do
    it "enforces title presence at database level" do
      expect {
        Seminar.connection.execute(
          "INSERT INTO seminars (description, starts_at, user_id, address, city, state) 
           VALUES ('test', '#{1.week.from_now}', 1, 'test', 'Austin', 'TX')"
        )
      }.to raise_error(ActiveRecord::NotNullViolation)
    end
    
    it "enforces future date constraint" do
      seminar_data = SeminarBuilder.build_valid_seminar(starts_at: 1.day.ago)
      expect { Seminar.create!(seminar_data.to_h) }.to raise_error(ActiveRecord::StatementInvalid)
    end
    
    it "enforces maximum 10 images per seminar" do
      seminar = SeminarBuilder.create_seminar_with_images(image_count: 10)
      expect {
        seminar.images.create!(position: 11)
      }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  describe "model validations" do
    it "validates title length" do
      seminar_data = SeminarBuilder.build_valid_seminar(title: "x" * 201)
      seminar = Seminar.new(seminar_data.to_h)
      expect(seminar).not_to be_valid
      expect(seminar.errors[:title]).to include("is too long")
    end
    
    it "validates future start date" do
      seminar_data = SeminarBuilder.build_valid_seminar(starts_at: 1.hour.ago)
      seminar = Seminar.new(seminar_data.to_h)
      expect(seminar).not_to be_valid
      expect(seminar.errors[:starts_at]).to be_present
    end
  end
end
```

## Technology Stack

### Core Gems
```ruby
# Gemfile additions
gem "phlex-rails"           # Component-based views
gem "bcrypt"               # Authentication
gem "geocoder"             # Address → coordinates
gem "image_processing"     # Active Storage variants
gem "rack-attack"          # Rate limiting
gem "web-push"             # PWA notifications

# Testing gems
gem "rspec-rails", group: [:development, :test]
gem "cucumber-rails", group: [:development, :test]
gem "ruby-lsp", group: :development
gem "rspec-lsp", group: :development
gem "cucumber-lsp", group: :development
gem "faker", group: [:development, :test]
```

### Database Migration Examples

#### Seminars Table with Constraints
```ruby
class CreateSeminars < ActiveRecord::Migration[8.0]
  def change
    create_table :seminars do |t|
      t.string :title, null: false, limit: 200
      t.text :description, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.references :user, null: false, foreign_key: true
      t.string :address, null: false
      t.string :city, null: false, limit: 100
      t.string :state, null: false, limit: 2
      t.string :zip_code, limit: 10
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.references :primary_image, foreign_key: { to_table: :seminar_images }, null: true
      t.timestamps
    end

    add_check_constraint :seminars, "starts_at > CURRENT_TIMESTAMP", name: "seminars_future_date"
    add_check_constraint :seminars, "ends_at IS NULL OR ends_at > starts_at", name: "seminars_valid_duration"
    add_index :seminars, [:city, :state]
    add_index :seminars, [:starts_at]
    add_index :seminars, [:latitude, :longitude]
  end
end
```

#### SeminarImages with Constraints
```ruby
class CreateSeminarImages < ActiveRecord::Migration[8.0]
  def change
    create_table :seminar_images do |t|
      t.references :seminar, null: false, foreign_key: true
      t.integer :position, null: false
      t.boolean :primary, default: false, null: false
      t.timestamps
    end

    add_index :seminar_images, [:seminar_id, :position], unique: true
    add_index :seminar_images, [:seminar_id], unique: true, where: "primary = true", name: "unique_primary_per_seminar"
    
    # Check constraint for max 10 images per seminar
    execute <<-SQL
      CREATE OR REPLACE FUNCTION check_max_images_per_seminar()
      RETURNS TRIGGER AS $$
      BEGIN
        IF (SELECT COUNT(*) FROM seminar_images WHERE seminar_id = NEW.seminar_id) > 10 THEN
          RAISE EXCEPTION 'Maximum 10 images allowed per seminar';
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      
      CREATE TRIGGER max_images_per_seminar_trigger
        BEFORE INSERT ON seminar_images
        FOR EACH ROW
        EXECUTE FUNCTION check_max_images_per_seminar();
    SQL
  end
end
```

## Authentication & Authorization

### User Model Implementation
```ruby
class User < ApplicationRecord
  has_secure_password
  
  has_many :seminars, dependent: :destroy
  has_many :notification_requests, dependent: :destroy
  has_many :notification_deliveries, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8 }, on: :create
  validate :daily_seminar_limit
  
  scope :admins, -> { where(admin: true) }
  
  def can_create_seminar?
    reset_daily_counters if new_day?
    daily_seminar_count < 25
  end
  
  def admin?
    admin
  end
  
  private
  
  def daily_seminar_limit
    return unless daily_seminar_count >= 25
    errors.add(:base, "Daily seminar creation limit reached")
  end
  
  def new_day?
    last_seminar_created_at.nil? || last_seminar_created_at.to_date < Date.current
  end
  
  def reset_daily_counters
    update_columns(
      daily_seminar_count: 0,
      last_seminar_created_at: Time.current
    )
  end
end
```

### Authorization Implementation
```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:index, :show]
  before_action :authorize_admin!, only: [:admin_dashboard, :destroy_user]
  
  private
  
  def authenticate_user!
    redirect_to login_path unless current_user
  end
  
  def authorize_admin!
    redirect_to root_path unless current_user&.admin?
  end
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
```

## Notification System

### Daily Digest Implementation
```ruby
class NotificationDigestJob < ApplicationJob
  def perform
    User.joins(:notification_requests).distinct.find_each do |user|
      seminars = find_matching_seminars(user)
      next if seminars.empty?
      
      NotificationMailer.daily_digest(user, seminars).deliver_now
      record_deliveries(user, seminars)
    end
  end
  
  private
  
  def find_matching_seminars(user)
    yesterday = 1.day.ago.beginning_of_day
    
    seminars = Seminar.joins(:players)
                     .where(created_at: yesterday..)
                     .distinct
    
    # Filter by user's notification preferences
    user.notification_requests.active.each do |request|
      if request.player_ids.present?
        seminars = seminars.where(players: { id: request.player_ids })
      end
      
      if request.city.present?
        seminars = seminars.where(city: request.city)
      elsif request.state.present?
        seminars = seminars.where(state: request.state)
      end
    end
    
    # Exclude already delivered seminars
    delivered_seminar_ids = user.notification_deliveries
                               .where(created_at: yesterday..)
                               .pluck(:seminar_id)
    
    seminars.where.not(id: delivered_seminar_ids)
  end
  
  def record_deliveries(user, seminars)
    deliveries = seminars.map do |seminar|
      {
        user_id: user.id,
        seminar_id: seminar.id,
        delivered_at: Time.current,
        created_at: Time.current,
        updated_at: Time.current
      }
    end
    
    NotificationDelivery.insert_all(deliveries)
  end
end
```

## Anti-Fraud Protection Strategy

### Multi-Layer Protection
1. **Account Level:**
   - Email verification required
   - 1 account per IP per day limit
   - 24-48 hour probation period for new accounts
   - Device fingerprinting for repeated violations

2. **Content Level:**
   - Address geocoding verification
   - Seminar date/time validation
   - Price range validation (if implemented)
   - Duplicate detection algorithms

3. **Behavioral Analysis:**
   - Pattern detection for bulk creation
   - Unusual location patterns
   - Time-based creation patterns

4. **Community Features:**
   - User reporting system
   - Admin moderation tools
   - Automatic flagging of suspicious content

### Implementation Example
```ruby
class FraudDetectionService
  def self.suspicious_account?(user)
    return true if recent_accounts_from_ip(user.last_sign_in_ip).count > 3
    return true if user.seminars.count > 10 && user.created_at > 1.week.ago
    return true if duplicate_content_patterns?(user)
    
    false
  end
  
  def self.suspicious_seminar?(seminar)
    return true unless geocoding_valid?(seminar)
    return true if duplicate_seminar?(seminar)
    return true if unrealistic_details?(seminar)
    
    false
  end
  
  private
  
  def self.recent_accounts_from_ip(ip)
    User.where(last_sign_in_ip: ip, created_at: 1.day.ago..)
  end
  
  def self.geocoding_valid?(seminar)
    Geocoder.search("#{seminar.address}, #{seminar.city}, #{seminar.state}").any?
  end
  
  def self.duplicate_seminar?(seminar)
    Seminar.where(
      title: seminar.title,
      city: seminar.city,
      starts_at: seminar.starts_at - 1.hour..seminar.starts_at + 1.hour
    ).where.not(id: seminar.id).exists?
  end
end
```

## International Expansion Strategy

### Database Schema Preparation
```ruby
class AddInternationalSupport < ActiveRecord::Migration[8.0]
  def change
    add_column :seminars, :country, :string, limit: 2, default: 'US', null: false
    add_column :teams, :country, :string, limit: 2, default: 'US'
    add_column :players, :nationality, :string, limit: 100
    
    add_index :seminars, [:country, :state, :city]
  end
end
```

### Localization Support
```ruby
# config/application.rb
config.i18n.available_locales = [:en, :es, :pt, :fr]
config.i18n.default_locale = :en

# Address validation per country
class AddressValidator < ActiveModel::Validator
  def validate(record)
    case record.country
    when 'US'
      validate_us_address(record)
    when 'BR'
      validate_brazil_address(record)
    when 'UK'
      validate_uk_address(record)
    end
  end
end
```

## Future Considerations

### Reviews & Ratings (Phase 2)
```ruby
class Review < ApplicationRecord
  belongs_to :user
  belongs_to :seminar
  
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { maximum: 1000 }
  validates :user_id, uniqueness: { scope: :seminar_id }
  
  # Database constraints
  # rating: INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5)
  # UNIQUE INDEX on (user_id, seminar_id)
end
```

### API Implementation (Phase 3)
```ruby
# API alongside HTML responses
class Api::V1::SeminarsController < Api::V1::BaseController
  def index
    seminars = Seminar.published.includes(:players, :images)
    render json: SeminarSerializer.new(seminars).serialized_json
  end
  
  def create
    seminar = current_user.seminars.build(seminar_params)
    
    if seminar.save
      render json: SeminarSerializer.new(seminar).serialized_json, status: :created
    else
      render json: { errors: seminar.errors }, status: :unprocessable_entity
    end
  end
end
```

## Security Implementation

### Content Security Policy
```ruby
# config/initializers/content_security_policy.rb
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, :blob
    policy.object_src  :none
    policy.script_src  :self, :https
    policy.style_src   :self, :https, :unsafe_inline
    
    # Allow Google Maps
    policy.connect_src :self, :https, "*.googleapis.com"
    policy.frame_src   "*.google.com"
  end
end
```

### Rate Limiting Configuration
```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle account creation
  throttle('account-creation', limit: 1, period: 1.day) do |req|
    req.ip if req.path == '/users' && req.post?
  end
  
  # Throttle seminar creation
  throttle('seminar-creation', limit: 25, period: 1.day) do |req|
    req.session[:user_id] if req.path == '/seminars' && req.post?
  end
  
  # Throttle login attempts
  throttle('login-attempts', limit: 5, period: 1.hour) do |req|
    req.ip if req.path == '/login' && req.post?
  end
end
```

## Deployment Strategy

### Database Considerations
- **Development/Test:** SQLite (already configured)
- **Production:** PostgreSQL for better concurrency and advanced features
- **Migration Path:** Rails database adapter switching

### PWA Deployment
- HTTPS required for service workers
- Proper caching headers for static assets
- Push notification service configuration
- Offline-first asset delivery

This comprehensive plan provides a solid foundation for building a robust, scalable BJJ seminar tracking application with modern web technologies and strong data integrity guarantees.