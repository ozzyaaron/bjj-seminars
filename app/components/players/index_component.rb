class Components::Players::IndexComponent < Components::ApplicationComponent
  def initialize(players:, teams:, belt_ranks:)
    @players = players
    @teams = teams
    @belt_ranks = belt_ranks
  end

  private

  attr_reader :players, :teams, :belt_ranks

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      page_header
      filters_section
      players_grid
    end
  end

  def page_header
    div(class: "bg-white shadow") do
      div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-center") do
          div do
            h1(class: "text-3xl font-bold text-gray-900") { "BJJ Players" }
            p(class: "mt-2 text-sm text-gray-600") { "Discover Brazilian Jiu-Jitsu instructors and competitors" }
          end
          
          if admin_user?
            render Components::UI::Button.new(
              href: new_player_path,
              variant: "primary"
            ) do
              "Add Player"
            end
          end
        end
      end
    end
  end

  def filters_section
    div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
      form_with(url: players_path, method: :get, local: true, class: "mb-6") do |form|
        div(class: "grid grid-cols-1 md:grid-cols-3 gap-4") do
          div do
            label(for: "search", class: "block text-sm font-medium text-gray-700 mb-2") { "Search" }
            input(
              type: "text",
              name: "search",
              id: "search",
              value: params[:search],
              placeholder: "Search by name or biography...",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            )
          end
          
          div do
            label(for: "team_id", class: "block text-sm font-medium text-gray-700 mb-2") { "Team" }
            select(
              name: "team_id",
              id: "team_id",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            ) do
              option(value: "", selected: params[:team_id].blank?) { "All Teams" }
              teams.each do |team|
                option(value: team.id, selected: params[:team_id] == team.id.to_s) { team.name }
              end
            end
          end
          
          div do
            label(for: "belt_rank", class: "block text-sm font-medium text-gray-700 mb-2") { "Belt Rank" }
            select(
              name: "belt_rank",
              id: "belt_rank",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            ) do
              option(value: "", selected: params[:belt_rank].blank?) { "All Belts" }
              belt_ranks.each do |rank|
                option(value: rank, selected: params[:belt_rank] == rank) { rank.humanize }
              end
            end
          end
        end
        
        div(class: "mt-4 flex justify-end space-x-3") do
          if params[:search].present? || params[:team_id].present? || params[:belt_rank].present?
            render Components::UI::Button.new(
              href: players_path,
              variant: "secondary"
            ) do
              "Clear Filters"
            end
          end
          
          render Components::UI::Button.new(
            type: "submit",
            variant: "primary"
          ) do
            "Search"
          end
        end
      end
    end
  end

  def players_grid
    div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12") do
      if players.any?
        div(class: "grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4") do
          players.each do |player|
            render Components::PlayerCardComponent.new(player: player)
          end
        end
      else
        empty_state
      end
    end
  end

  def empty_state
    div(class: "text-center py-12") do
      svg(
        class: "mx-auto h-12 w-12 text-gray-400",
        fill: "none",
        viewBox: "0 0 24 24",
        stroke: "currentColor"
      ) do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "2",
          d: "M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
        )
      end
      h3(class: "mt-2 text-sm font-medium text-gray-900") { "No players found" }
      p(class: "mt-1 text-sm text-gray-500") { "Try adjusting your search criteria or check back later." }
      
      if admin_user?
        div(class: "mt-6") do
          render Components::UI::Button.new(
            href: new_player_path,
            variant: "primary"
          ) do
            "Add the first player"
          end
        end
      end
    end
  end
end