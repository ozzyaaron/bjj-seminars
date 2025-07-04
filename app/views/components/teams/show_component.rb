class Teams::ShowComponent < ApplicationComponent
  def initialize(team:, players:, recent_seminars:)
    @team = team
    @players = players
    @recent_seminars = recent_seminars
  end

  private

  attr_reader :team, :players, :recent_seminars

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      team_header
      team_content
    end
  end

  def team_header
    div(class: "bg-white shadow") do
      div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-start") do
          div(class: "flex-1") do
            h1(class: "text-3xl font-bold text-gray-900") { team.name }
            if team.location.present?
              p(class: "mt-2 text-sm text-gray-600") do
                svg(class: "inline w-4 h-4 mr-1", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
                  s.path(
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    stroke_width: "2",
                    d: "M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                  )
                  s.path(
                    stroke_linecap: "round",
                    stroke_linejoin: "round",
                    stroke_width: "2",
                    d: "M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                  )
                end
                span { team.location }
              end
            end
          end
          
          if admin_user?
            div(class: "flex space-x-3") do
              render UI::ButtonComponent.new(
                href: edit_team_path(team),
                variant: "secondary"
              ) do
                "Edit Team"
              end
              
              render UI::ButtonComponent.new(
                href: team_path(team),
                method: :delete,
                variant: "danger",
                confirm: "Are you sure you want to delete this team?"
              ) do
                "Delete Team"
              end
            end
          end
        end
      end
    end
  end

  def team_content
    div(class: "max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8") do
      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
        main_content
        sidebar
      end
    end
  end

  def main_content
    div(class: "lg:col-span-2 space-y-8") do
      team_description if team.description.present?
      team_players
      recent_seminars_section if recent_seminars.any?
    end
  end

  def team_description
    render UI::CardComponent.new do
      div(class: "p-6") do
        h2(class: "text-2xl font-bold text-gray-900 mb-4") { "About #{team.name}" }
        div(class: "prose max-w-none text-gray-700") do
          simple_format(team.description)
        end
      end
    end
  end

  def team_players
    render UI::CardComponent.new do
      div(class: "p-6") do
        div(class: "flex justify-between items-center mb-6") do
          h2(class: "text-2xl font-bold text-gray-900") { "Team Members" }
          if admin_user?
            render UI::ButtonComponent.new(
              href: new_player_path(team_id: team.id),
              variant: "primary",
              size: "sm"
            ) do
              "Add Player"
            end
          end
        end
        
        if players.any?
          div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
            players.each do |player|
              render PlayerCardComponent.new(player: player)
            end
          end
        else
          div(class: "text-center py-8") do
            p(class: "text-gray-500") { "No players found for this team." }
            if admin_user?
              div(class: "mt-4") do
                render UI::ButtonComponent.new(
                  href: new_player_path(team_id: team.id),
                  variant: "primary"
                ) do
                  "Add first player"
                end
              end
            end
          end
        end
      end
    end
  end

  def recent_seminars_section
    render UI::CardComponent.new do
      div(class: "p-6") do
        h2(class: "text-2xl font-bold text-gray-900 mb-6") { "Recent Seminars" }
        
        div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
          recent_seminars.each do |seminar|
            render SeminarCardComponent.new(seminar: seminar)
          end
        end
        
        if recent_seminars.count >= 6
          div(class: "mt-6 text-center") do
            render UI::ButtonComponent.new(
              href: seminars_path(team_id: team.id),
              variant: "secondary"
            ) do
              "View All Seminars"
            end
          end
        end
      end
    end
  end

  def sidebar
    div(class: "space-y-6") do
      team_stats_card
      team_info_card
    end
  end

  def team_stats_card
    render UI::CardComponent.new do
      div(class: "p-6") do
        h3(class: "text-lg font-semibold text-gray-900 mb-4") { "Team Stats" }
        
        div(class: "space-y-3") do
          stat_item("Total Players", players.count.to_s)
          stat_item("Recent Seminars", recent_seminars.count.to_s)
          
          if players.any?
            belt_distribution = players.group(:belt_rank).count
            belt_distribution.each do |belt, count|
              next if belt.blank?
              stat_item("#{belt.humanize} Belts", count.to_s)
            end
          end
        end
      end
    end
  end

  def team_info_card
    render UI::CardComponent.new do
      div(class: "p-6") do
        h3(class: "text-lg font-semibold text-gray-900 mb-4") { "Team Information" }
        
        div(class: "space-y-3") do
          if team.website.present?
            div do
              span(class: "text-sm font-medium text-gray-500") { "Website" }
              div(class: "mt-1") do
                a(
                  href: team.website.start_with?('http') ? team.website : "https://#{team.website}",
                  target: "_blank",
                  class: "text-sm text-indigo-600 hover:text-indigo-800"
                ) do
                  team.website
                end
              end
            end
          end
          
          div do
            span(class: "text-sm font-medium text-gray-500") { "Established" }
            p(class: "text-sm text-gray-900") { time_ago_in_words(team.created_at) + " ago" }
          end
        end
      end
    end
  end

  def stat_item(label, value)
    div(class: "flex justify-between") do
      span(class: "text-sm font-medium text-gray-500") { label }
      span(class: "text-sm font-semibold text-gray-900") { value }
    end
  end
end