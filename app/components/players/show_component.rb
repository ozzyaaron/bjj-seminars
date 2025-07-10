class Components::Players::ShowComponent < Components::ApplicationComponent
  def initialize(player:, upcoming_seminars:, past_seminars:)
    @player = player
    @upcoming_seminars = upcoming_seminars
    @past_seminars = past_seminars
  end

  private

  attr_reader :player, :upcoming_seminars, :past_seminars

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      player_header
      player_content
    end
  end

  def player_header
    div(class: "bg-white shadow") do
      div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-start") do
          div(class: "flex items-center space-x-4") do
            player_avatar
            div do
              h1(class: "text-3xl font-bold text-gray-900") { player.name }
              div(class: "flex items-center space-x-3 mt-2") do
                render Components::UI::Button.new(
                  href: team_path(player.team),
                  variant: "link",
                  size: "sm"
                ) do
                  player.team.name
                end
                
                if player.belt_rank.present?
                  render Components::UI::Badge.new(
                    variant: belt_color(player.belt_rank),
                    size: "sm"
                  ) do
                    player.belt_rank.humanize
                  end
                end
              end
            end
          end
          
          if admin_user?
            div(class: "flex space-x-3") do
              render Components::UI::Button.new(
                href: edit_player_path(player),
                variant: "secondary"
              ) do
                "Edit Player"
              end
              
              render Components::UI::Button.new(
                href: player_path(player),
                method: :delete,
                variant: "danger",
                confirm: "Are you sure you want to delete this player?"
              ) do
                "Delete Player"
              end
            end
          end
        end
      end
    end
  end

  def player_content
    div(class: "max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8") do
      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
        main_content
        sidebar
      end
    end
  end

  def main_content
    div(class: "lg:col-span-2 space-y-8") do
      player_biography if player.biography.present?
      upcoming_seminars_section if upcoming_seminars.any?
      past_seminars_section if past_seminars.any?
    end
  end

  def player_biography
    render Components::UI::Card.new do
      div(class: "p-6") do
        h2(class: "text-2xl font-bold text-gray-900 mb-4") { "Biography" }
        div(class: "prose max-w-none text-gray-700") do
          simple_format(player.biography)
        end
      end
    end
  end

  def upcoming_seminars_section
    render Components::UI::Card.new do
      div(class: "p-6") do
        h2(class: "text-2xl font-bold text-gray-900 mb-6") { "Upcoming Seminars" }
        
        div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
          upcoming_seminars.each do |seminar|
            render Components::SeminarCardComponent.new(seminar: seminar)
          end
        end
      end
    end
  end

  def past_seminars_section
    render Components::UI::Card.new do
      div(class: "p-6") do
        h2(class: "text-2xl font-bold text-gray-900 mb-6") { "Past Seminars" }
        
        div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
          past_seminars.each do |seminar|
            render Components::SeminarCardComponent.new(seminar: seminar)
          end
        end
      end
    end
  end

  def sidebar
    div(class: "space-y-6") do
      player_stats_card
      player_info_card
    end
  end

  def player_stats_card
    render Components::UI::Card.new do
      div(class: "p-6") do
        h3(class: "text-lg font-semibold text-gray-900 mb-4") { "Player Stats" }
        
        div(class: "space-y-3") do
          stat_item("Upcoming Seminars", upcoming_seminars.count.to_s)
          stat_item("Past Seminars", past_seminars.count.to_s)
          stat_item("Total Seminars", (upcoming_seminars.count + past_seminars.count).to_s)
        end
      end
    end
  end

  def player_info_card
    render Components::UI::Card.new do
      div(class: "p-6") do
        h3(class: "text-lg font-semibold text-gray-900 mb-4") { "Player Information" }
        
        div(class: "space-y-3") do
          div do
            span(class: "text-sm font-medium text-gray-500") { "Team" }
            div(class: "mt-1") do
              render Components::UI::Button.new(
                href: team_path(player.team),
                variant: "link",
                size: "sm"
              ) do
                player.team.name
              end
            end
          end
          
          if player.belt_rank.present?
            div do
              span(class: "text-sm font-medium text-gray-500") { "Belt Rank" }
              div(class: "mt-1") do
                render Components::UI::Badge.new(
                  variant: belt_color(player.belt_rank),
                  size: "sm"
                ) do
                  player.belt_rank.humanize
                end
              end
            end
          end
          
          div do
            span(class: "text-sm font-medium text-gray-500") { "Added" }
            p(class: "text-sm text-gray-900") { time_ago_in_words(player.created_at) + " ago" }
          end
        end
      end
    end
  end

  def player_avatar
    div(class: "w-16 h-16 bg-indigo-100 rounded-full flex items-center justify-center") do
      span(class: "text-2xl font-bold text-indigo-800") do
        player.name.split.map(&:first).join.upcase
      end
    end
  end

  def stat_item(label, value)
    div(class: "flex justify-between") do
      span(class: "text-sm font-medium text-gray-500") { label }
      span(class: "text-sm font-semibold text-gray-900") { value }
    end
  end

  def belt_color(belt_rank)
    case belt_rank
    when "white"
      "gray"
    when "blue"
      "blue"
    when "purple"
      "purple"
    when "brown"
      "warning"
    when "black"
      "black"
    else
      "gray"
    end
  end
end