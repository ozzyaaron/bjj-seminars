class Players::FormComponent < ApplicationComponent
  def initialize(player:, teams:, action_url: nil)
    @player = player
    @teams = teams
    @action_url = action_url || (player.persisted? ? player_path(player) : players_path)
  end

  private

  attr_reader :player, :teams, :action_url

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      form_header
      form_content
    end
  end

  def form_header
    div(class: "bg-white shadow") do
      div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-center") do
          div do
            h1(class: "text-3xl font-bold text-gray-900") do
              player.persisted? ? "Edit Player" : "Add New Player"
            end
            p(class: "mt-2 text-sm text-gray-600") do
              "Manage BJJ player information and details"
            end
          end
          
          render Components::UI::Button.new(
            href: player.persisted? ? player_path(player) : players_path,
            variant: "secondary"
          ) do
            "Cancel"
          end
        end
      end
    end
  end

  def form_content
    div(class: "max-w-2xl mx-auto py-8 px-4 sm:px-6 lg:px-8") do
      render Components::UI::Card.new do
        div(class: "p-6") do
          render_errors if player.errors.any?
          
          form_with(model: player, url: action_url, local: true, class: "space-y-6") do |form|
            basic_info_section
            team_and_rank_section
            biography_section
            form_actions
          end
        end
      end
    end
  end

  def basic_info_section
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Basic Information" }
      
      div do
        label(for: "player_name", class: "block text-sm font-medium text-gray-700 mb-2") { "Full Name *" }
        input(
          type: "text",
          name: "player[name]",
          id: "player_name",
          value: player.name,
          required: true,
          class: input_classes(player.errors[:name].present?),
          placeholder: "e.g., Roger Gracie, Marcelo Garcia"
        )
        render_field_errors(player.errors[:name])
      end
    end
  end

  def team_and_rank_section
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Team & Rank" }
      
      div do
        label(for: "player_team_id", class: "block text-sm font-medium text-gray-700 mb-2") { "Team *" }
        select(
          name: "player[team_id]",
          id: "player_team_id",
          required: true,
          class: input_classes(player.errors[:team_id].present?)
        ) do
          option(value: "", selected: player.team_id.blank?) { "Select a team..." }
          teams.each do |team|
            option(value: team.id, selected: player.team_id == team.id) { team.name }
          end
        end
        render_field_errors(player.errors[:team_id])
      end
      
      div do
        label(for: "player_belt_rank", class: "block text-sm font-medium text-gray-700 mb-2") { "Belt Rank" }
        select(
          name: "player[belt_rank]",
          id: "player_belt_rank",
          class: input_classes(player.errors[:belt_rank].present?)
        ) do
          option(value: "", selected: player.belt_rank.blank?) { "Select belt rank..." }
          belt_ranks.each do |rank|
            option(value: rank, selected: player.belt_rank == rank) { rank.humanize }
          end
        end
        render_field_errors(player.errors[:belt_rank])
      end
    end
  end

  def biography_section
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Biography" }
      
      div do
        label(for: "player_biography", class: "block text-sm font-medium text-gray-700 mb-2") { "About the Player" }
        textarea(
          name: "player[biography]",
          id: "player_biography",
          rows: 6,
          class: input_classes(player.errors[:biography].present?),
          placeholder: "Tell us about the player's achievements, competition history, teaching style, and what makes them special..."
        ) { player.biography }
        render_field_errors(player.errors[:biography])
        p(class: "mt-1 text-sm text-gray-500") { "Optional: Player background, achievements, and teaching style" }
      end
    end
  end

  def form_actions
    div(class: "flex justify-end space-x-3 pt-6 border-t border-gray-200") do
      render Components::UI::Button.new(
        href: player.persisted? ? player_path(player) : players_path,
        variant: "secondary"
      ) do
        "Cancel"
      end
      
      render Components::UI::Button.new(
        type: "submit",
        variant: "primary"
      ) do
        player.persisted? ? "Update Player" : "Create Player"
      end
    end
  end

  def belt_ranks
    %w[white blue purple brown black]
  end

  def render_errors
    div(class: "rounded-md bg-red-50 p-4 mb-6") do
      div(class: "flex") do
        div(class: "ml-3") do
          h3(class: "text-sm font-medium text-red-800") do
            "Please fix the following errors:"
          end
          div(class: "mt-2 text-sm text-red-700") do
            ul(class: "list-disc pl-5 space-y-1") do
              player.errors.full_messages.each do |message|
                li { message }
              end
            end
          end
        end
      end
    end
  end

  def render_field_errors(errors)
    return unless errors.present?

    div(class: "mt-1") do
      errors.each do |error|
        p(class: "text-sm text-red-600") { error }
      end
    end
  end

  def input_classes(has_error = false)
    base_classes = "mt-1 block w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
    
    if has_error
      "#{base_classes} border-red-300 text-red-900 placeholder-red-300 focus:ring-red-500 focus:border-red-500"
    else
      "#{base_classes} border-gray-300 text-gray-900 placeholder-gray-500"
    end
  end
end