class TeamCardComponent < ApplicationComponent
  def initialize(team:)
    @team = team
  end

  private

  attr_reader :team

  def view_template
    render Components::UI::Card.new(class: "h-full hover:shadow-lg transition-shadow duration-200") do
      div(class: "p-6") do
        team_header
        team_details
        team_footer
      end
    end
  end

  def team_header
    div(class: "mb-4") do
      h3(class: "text-xl font-semibold text-gray-900 mb-2") do
        a(href: team_path(team), class: "hover:text-indigo-600") do
          team.name
        end
      end
      
      if team.location.present?
        div(class: "flex items-center text-sm text-gray-500") do
          svg(class: "w-4 h-4 mr-1", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
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
  end

  def team_details
    div(class: "mb-4") do
      if team.description.present?
        p(class: "text-gray-600 text-sm line-clamp-3 mb-3") do
          team.description
        end
      end
      
      div(class: "flex items-center justify-between text-sm text-gray-500") do
        div(class: "flex items-center") do
          svg(class: "w-4 h-4 mr-1", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
            s.path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "2",
              d: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
            )
          end
          span { "#{team.players.count} #{'player'.pluralize(team.players.count)}" }
        end
        
        if team.website.present?
          a(
            href: team.website.start_with?('http') ? team.website : "https://#{team.website}",
            target: "_blank",
            class: "text-indigo-600 hover:text-indigo-800 flex items-center"
          ) do
            svg(class: "w-4 h-4 mr-1", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
              s.path(
                stroke_linecap: "round",
                stroke_linejoin: "round",
                stroke_width: "2",
                d: "M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
              )
            end
            span { "Website" }
          end
        end
      end
    end
  end

  def team_footer
    div(class: "flex items-center justify-between pt-4 border-t border-gray-200") do
      div(class: "text-xs text-gray-500") do
        "Added #{time_ago_in_words(team.created_at)} ago"
      end
      
      render Components::UI::Button.new(
        href: team_path(team),
        variant: "primary",
        size: "sm"
      ) do
        "View Team"
      end
    end
  end
end