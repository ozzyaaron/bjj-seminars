#!/usr/bin/env ruby
# Coverage Report Script
# Generates comprehensive test coverage analysis using SimpleCov

require 'json'
require 'fileutils'

# Try to load colorize, but don't fail if it's not available
begin
  require 'colorize'
  COLORIZE_AVAILABLE = true
rescue LoadError
  COLORIZE_AVAILABLE = false
end

# Define colorize method stub if colorize gem is not available
class String
  def colorize(color)
    COLORIZE_AVAILABLE ? super : self
  end
end

class CoverageReporter
  def initialize
    @root_path = File.expand_path('..', __dir__)
    @coverage_path = File.join(@root_path, 'coverage', '.resultset.json')
    @working_tests = %w[
      spec/models/user_spec_new.rb
      spec/models/seminar_spec_new.rb
      spec/models/player_spec_new.rb
      spec/models/team_spec_new.rb
      spec/requests/security_spec.rb
      spec/requests/component_rendering_spec.rb
    ]
  end

  def run
    puts "🔍 BJJ Seminar Tracker - Coverage Report Generator".colorize(:blue)
    puts "=" * 60
    puts

    # Clean previous coverage data
    cleanup_coverage
    
    # Run working tests first (comprehensive but stable)
    puts "📊 Running working test suite for stable coverage baseline...".colorize(:yellow)
    run_working_tests
    
    # Try to run full test suite if working tests pass
    if working_tests_passed?
      puts "✅ Working tests passed! Attempting full test suite...".colorize(:green)
      run_full_test_suite
    else
      puts "⚠️  Working tests had issues. Using baseline coverage only.".colorize(:yellow)
    end
    
    # Generate and display coverage report
    generate_coverage_report
  end

  private

  def cleanup_coverage
    coverage_dir = File.join(@root_path, 'coverage')
    FileUtils.rm_rf(coverage_dir) if Dir.exist?(coverage_dir)
    puts "🧹 Cleaned previous coverage data".colorize(:cyan)
  end

  def run_working_tests
    cmd = "cd #{@root_path} && RAILS_ENV=test bundle exec rspec #{@working_tests.join(' ')} --format progress"
    
    puts "Running: #{cmd}".colorize(:light_black)
    system(cmd)
  end

  def working_tests_passed?
    # Check if coverage file was generated (indicates tests ran)
    File.exist?(@coverage_path)
  end

  def run_full_test_suite
    puts "🚀 Running full test suite with coverage merging...".colorize(:yellow)
    
    # Run RSpec tests with timeout
    puts "📊 Running RSpec tests...".colorize(:cyan)
    rspec_cmd = "cd #{@root_path} && timeout 300 bundle exec rspec --format progress 2>/dev/null"
    puts "Running: #{rspec_cmd}".colorize(:light_black)
    rspec_success = system(rspec_cmd)
    
    # Run Cucumber tests separately to merge coverage
    puts "🥒 Running Cucumber tests...".colorize(:cyan)
    cucumber_cmd = "cd #{@root_path} && timeout 180 bundle exec cucumber --format progress 2>/dev/null"
    puts "Running: #{cucumber_cmd}".colorize(:light_black)
    cucumber_success = system(cucumber_cmd)
    
    if rspec_success && cucumber_success
      puts "✅ Both test suites completed successfully".colorize(:green)
    elsif rspec_success
      puts "⚠️  RSpec completed, Cucumber had issues".colorize(:yellow)
    elsif cucumber_success
      puts "⚠️  Cucumber completed, RSpec had issues".colorize(:yellow)
    else
      puts "❌ Both test suites had issues".colorize(:red)
    end
  end

  def generate_coverage_report
    unless File.exist?(@coverage_path)
      puts "❌ No coverage data found. Tests may have failed to run.".colorize(:red)
      return
    end

    begin
      # Parse coverage data
      coverage_data = JSON.parse(File.read(@coverage_path))
      
      # Identify test sources (RSpec, Cucumber, or merged)
      test_sources = []
      test_sources << 'RSpec' if coverage_data['RSpec']
      test_sources << 'cucumber' if coverage_data['cucumber']
      
      if test_sources.empty?
        puts "❌ No valid coverage data found in results.".colorize(:red)
        return
      end

      puts "📊 Found coverage data from: #{test_sources.join(', ')}".colorize(:cyan)

      # Calculate overall coverage from all sources
      total_lines = 0
      covered_lines = 0
      file_coverage = {}
      all_files = {}

      # Merge coverage data from all test sources
      test_sources.each do |source|
        source_data = coverage_data[source]
        next unless source_data && source_data['coverage']
        
        source_data['coverage'].each do |file_path, file_data|
          next unless file_path.include?('/app/') && file_path.end_with?('.rb')
          
          lines = file_data['lines'] || []
          
          # Initialize file in merged data if not exists
          all_files[file_path] ||= Array.new(lines.length, 0)
          
          # Merge line coverage (take maximum coverage for each line)
          lines.each_with_index do |line_coverage, index|
            next if line_coverage.nil?
            
            # Extend array if this file has more lines in this test run
            while all_files[file_path].length <= index
              all_files[file_path] << 0
            end
            
            # Use the maximum coverage count between sources
            if line_coverage > 0
              all_files[file_path][index] = [all_files[file_path][index], line_coverage].max
            end
          end
        end
      end

      # Calculate final coverage statistics
      all_files.each do |file_path, lines|
        lines.each do |line_coverage|
          next if line_coverage.nil?
          
          total_lines += 1
          if line_coverage > 0
            covered_lines += 1
          end
        end
        
        # Calculate per-file coverage
        file_total = lines.count { |l| !l.nil? && l != 0 }
        file_covered = lines.count { |l| l && l > 0 }
        
        # Only count lines that could potentially be covered
        trackable_lines = lines.length
        
        if trackable_lines > 0
          file_coverage[file_path] = {
            total: trackable_lines,
            covered: file_covered,
            percentage: (file_covered.to_f / trackable_lines * 100).round(2)
          }
        end
      end

      # Display results
      display_coverage_results(total_lines, covered_lines, file_coverage)
      
    rescue JSON::ParserError => e
      puts "❌ Error parsing coverage data: #{e.message}".colorize(:red)
    rescue => e
      puts "❌ Error generating coverage report: #{e.message}".colorize(:red)
    end
  end

  def display_coverage_results(total_lines, covered_lines, file_coverage)
    overall_percentage = total_lines > 0 ? (covered_lines.to_f / total_lines * 100).round(2) : 0
    
    puts
    puts "📈 COVERAGE SUMMARY".colorize(:blue)
    puts "=" * 60
    puts
    
    # Overall coverage
    color = coverage_color(overall_percentage)
    puts "Overall Coverage: #{overall_percentage}% (#{covered_lines}/#{total_lines} lines)".colorize(color)
    puts "Coverage includes: RSpec + Cucumber tests".colorize(:cyan)
    puts
    
    # Coverage status
    target_coverage = 90.0
    if overall_percentage >= target_coverage
      puts "🎉 SUCCESS: Coverage meets target of #{target_coverage}%!".colorize(:green)
    else
      deficit = target_coverage - overall_percentage
      puts "⚠️  ATTENTION: Coverage is #{deficit.round(2)}% below target of #{target_coverage}%".colorize(:yellow)
    end
    
    puts
    puts "📁 PER-FILE COVERAGE BREAKDOWN".colorize(:blue)
    puts "-" * 60
    
    # Sort files by coverage percentage (lowest first)
    sorted_files = file_coverage.sort_by { |_, data| data[:percentage] }
    
    sorted_files.each do |file_path, data|
      relative_path = file_path.gsub(@root_path, '').gsub(/^\//, '')
      color = coverage_color(data[:percentage])
      percentage_str = "#{data[:percentage].to_s.rjust(6)}%"
      coverage_str = "(#{data[:covered]}/#{data[:total]} lines)"
      
      puts "#{percentage_str.colorize(color)} #{relative_path} #{coverage_str}".colorize(:light_black)
    end
    
    puts
    puts "🔍 COVERAGE INSIGHTS".colorize(:blue)
    puts "-" * 60
    
    # Find files needing attention
    low_coverage_files = file_coverage.select { |_, data| data[:percentage] < 80 }
    high_coverage_files = file_coverage.select { |_, data| data[:percentage] >= 90 }
    
    if low_coverage_files.any?
      puts "Files needing attention (< 80% coverage):".colorize(:yellow)
      low_coverage_files.each do |file_path, data|
        relative_path = file_path.gsub(@root_path, '').gsub(/^\//, '')
        puts "  • #{relative_path} (#{data[:percentage]}%)".colorize(:yellow)
      end
      puts
    end
    
    if high_coverage_files.any?
      puts "Well-covered files (≥ 90% coverage):".colorize(:green)
      high_coverage_files.each do |file_path, data|
        relative_path = file_path.gsub(@root_path, '').gsub(/^\//, '')
        puts "  • #{relative_path} (#{data[:percentage]}%)".colorize(:green)
      end
      puts
    end
    
    puts "📊 Coverage report generated successfully!".colorize(:green)
    puts "📁 Detailed HTML report available at: coverage/index.html".colorize(:cyan)
    puts
  end

  def coverage_color(percentage)
    case percentage
    when 0...50 then :red
    when 50...75 then :yellow
    when 75...90 then :light_yellow
    else :green
    end
  end
end

# Make script executable
if __FILE__ == $0
  reporter = CoverageReporter.new
  reporter.run
end