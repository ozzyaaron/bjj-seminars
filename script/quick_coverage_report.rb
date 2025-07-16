#!/usr/bin/env ruby
# Quick Coverage Report Script - Analyzes existing coverage data without running tests

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

class QuickCoverageAnalyzer
  def initialize
    @root_path = File.expand_path('..', __dir__)
    @coverage_path = File.join(@root_path, 'coverage', '.resultset.json')
  end

  def run
    puts "🔍 BJJ Seminar Tracker - Quick Coverage Analysis".colorize(:blue)
    puts "=" * 60
    puts

    unless File.exist?(@coverage_path)
      puts "❌ No coverage data found at #{@coverage_path}".colorize(:red)
      puts "Run the tests first to generate coverage data.".colorize(:yellow)
      return
    end

    analyze_existing_coverage
  end

  private

  def analyze_existing_coverage
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
        
        puts "Processing #{source} coverage data...".colorize(:light_black)
        
        source_data['coverage'].each do |file_path, file_data|
          next unless file_path.include?('/app/') && file_path.end_with?('.rb')
          
          lines = file_data['lines'] || []
          
          # Initialize file in merged data if not exists
          if all_files[file_path].nil?
            all_files[file_path] = Array.new(lines.length, nil)
          end
          
          # Merge line coverage (take maximum coverage for each line)
          lines.each_with_index do |line_coverage, index|
            # Extend array if this file has more lines in this test run
            while all_files[file_path].length <= index
              all_files[file_path] << nil
            end
            
            if line_coverage.nil?
              # Line is not trackable, keep as nil
              all_files[file_path][index] ||= nil
            else
              # Line is trackable, merge coverage
              if all_files[file_path][index].nil?
                all_files[file_path][index] = line_coverage
              else
                all_files[file_path][index] = [all_files[file_path][index], line_coverage].max
              end
            end
          end
        end
      end

      # Calculate final coverage statistics
      all_files.each do |file_path, lines|
        trackable_lines = 0
        covered_count = 0
        
        lines.each do |line_coverage|
          next if line_coverage.nil?
          
          trackable_lines += 1
          total_lines += 1
          
          if line_coverage > 0
            covered_count += 1
            covered_lines += 1
          end
        end
        
        if trackable_lines > 0
          file_coverage[file_path] = {
            total: trackable_lines,
            covered: covered_count,
            percentage: (covered_count.to_f / trackable_lines * 100).round(2)
          }
        end
      end

      # Display results
      display_coverage_results(total_lines, covered_lines, file_coverage, test_sources)
      
    rescue JSON::ParserError => e
      puts "❌ Error parsing coverage data: #{e.message}".colorize(:red)
    rescue => e
      puts "❌ Error analyzing coverage data: #{e.message}".colorize(:red)
    end
  end

  def display_coverage_results(total_lines, covered_lines, file_coverage, test_sources)
    overall_percentage = total_lines > 0 ? (covered_lines.to_f / total_lines * 100).round(2) : 0
    
    puts
    puts "📈 COVERAGE SUMMARY".colorize(:blue)
    puts "=" * 60
    puts
    
    # Overall coverage
    color = coverage_color(overall_percentage)
    puts "Overall Coverage: #{overall_percentage}% (#{covered_lines}/#{total_lines} lines)".colorize(color)
    puts "Coverage includes: #{test_sources.join(' + ')} tests".colorize(:cyan)
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
    
    puts "📊 Coverage analysis complete!".colorize(:green)
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
  analyzer = QuickCoverageAnalyzer.new
  analyzer.run
end