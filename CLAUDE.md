# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## BJJ Seminar Tracker

This is a Rails 8.0 application for tracking Brazilian Jiu-Jitsu seminars. The application uses modern Rails features with TailwindCSS for styling and Stimulus for JavaScript interactions.

## Key Development Commands

### Setup and Development
- `bin/setup` - Initial setup (installs dependencies, prepares database, starts server)
- `bin/dev` - Start development server
- `bin/rails server` - Start Rails server directly

### Database
- `bin/rails db:create` - Create database
- `bin/rails db:prepare` - Prepare database (create if needed, run migrations and seed)
- `bin/rails db:migrate` - Run pending migrations
- `bin/rails db:rollback` - Rollback last migration

### Testing and Code Quality
- `bin/rails test` - Run all tests (excluding system tests)
- `bin/rails test:system` - Run system tests
- `bin/rubocop` - Run RuboCop linter (uses rubocop-rails-omakase)
- `bin/brakeman` - Run security scanner

### Assets and Frontend
The application uses:
- TailwindCSS for styling (`tailwindcss-rails` gem)
- Importmap for JavaScript modules
- Stimulus controllers for JavaScript interactions

## Architecture Overview

### Core Rails Structure
- **Application Module**: `BjjSeminarTracker` (config/application.rb:9)
- **Database**: SQLite3 with Solid Cache, Solid Queue, and Solid Cable for background jobs
- **Styling**: TailwindCSS with both `tailwindcss-ruby` and `tailwindcss-rails` gems
- **JavaScript**: Stimulus controllers in `app/javascript/controllers/`

### Key Gems and Features
- **Rails 8.0** with modern defaults
- **Solid Stack**: Solid Cache, Solid Queue, Solid Cable for caching, jobs, and WebSockets
- **Deployment**: Kamal for Docker-based deployment
- **Security**: Brakeman for security scanning
- **Testing**: Capybara and Selenium for system testing

### File Structure Notes
- Standard Rails 8.0 structure with autoloading from `lib/` (ignoring assets and tasks)
- No custom routes defined yet (only health check at `/up`)
- Uses Rails omakase RuboCop configuration
- PWA manifest and service worker files prepared but not yet enabled

### Development Workflow
1. Run `bin/setup` for initial setup
2. Use `bin/dev` for development server
3. Run tests with `bin/rails test`
4. Use `bin/rubocop` before commits
5. Run `bin/brakeman` for security checks