class PlayerCardComponent < ApplicationComponent
  def initialize(player:)
    @player = player
  end

  private

  attr_reader :player

  def view_template
    render Components::UI::Card.new(class: "h-full") do
      div(class: "p-4") do
        div(class: "flex items-center space-x-3") do
          player_avatar
          player_info
        end
      end
    end
  end

  def player_avatar
    div(class: "flex-shrink-0") do
      div(class: "w-12 h-12 bg-indigo-100 rounded-full flex items-center justify-center") do
        span(class: "text-lg font-medium text-indigo-800") do
          player.name.split.map(&:first).join.upcase
        end
      end
    end
  end

  def player_info
    div(class: "flex-1 min-w-0") do
      h3(class: "text-lg font-semibold text-gray-900 truncate") { player.name }
      
      div(class: "mt-1 flex items-center text-sm text-gray-500") do
        span { player.team.name }
        
        if player.belt_rank.present?
          span(class: "mx-1") { "•" }
          render Components::UI::Badge.new(
            variant: belt_color(player.belt_rank),
            size: "sm"
          ) do
            player.belt_rank.humanize
          end
        end
      end
      
      if player.biography.present?
        p(class: "mt-2 text-sm text-gray-600 line-clamp-2") do
          player.biography
        end
      end
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
      "yellow"
    when "black"
      "black"
    else
      "gray"
    end
  end
end