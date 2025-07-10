class Components::Teams::IndexComponent < Components::ApplicationComponent
  def initialize(teams:)
    @teams = teams
  end

  private

  attr_reader :teams

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      page_header
      search_section
      teams_grid
    end
  end

  def page_header
    div(class: "bg-white shadow") do
      div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-center") do
          div do
            h1(class: "text-3xl font-bold text-gray-900") { "BJJ Teams" }
            p(class: "mt-2 text-sm text-gray-600") { "Discover Brazilian Jiu-Jitsu teams and academies" }
          end
          
          if admin_user?
            render Components::UI::Button.new(
              href: new_team_path,
              variant: "primary"
            ) do
              "Add Team"
            end
          end
        end
      end
    end
  end

  def search_section
    div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
      form_with(url: teams_path, method: :get, local: true, class: "mb-6") do |form|
        div(class: "max-w-md") do
          label(for: "search", class: "block text-sm font-medium text-gray-700 mb-2") { "Search Teams" }
          div(class: "flex space-x-3") do
            input(
              type: "text",
              name: "search",
              id: "search",
              value: params[:search],
              placeholder: "Search by team name or location...",
              class: "flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            )
            
            render Components::UI::Button.new(
              type: "submit",
              variant: "primary"
            ) do
              "Search"
            end
            
            if params[:search].present?
              render Components::UI::Button.new(
                href: teams_path,
                variant: "secondary"
              ) do
                "Clear"
              end
            end
          end
        end
      end
    end
  end

  def teams_grid
    div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12") do
      if teams.any?
        div(class: "grid gap-6 sm:grid-cols-2 lg:grid-cols-3") do
          teams.each do |team|
            render Components::TeamCardComponent.new(team: team)
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
          d: "M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
        )
      end
      h3(class: "mt-2 text-sm font-medium text-gray-900") { "No teams found" }
      p(class: "mt-1 text-sm text-gray-500") { "Try adjusting your search criteria or check back later." }
      
      if admin_user?
        div(class: "mt-6") do
          render Components::UI::Button.new(
            href: new_team_path,
            variant: "primary"
          ) do
            "Add the first team"
          end
        end
      end
    end
  end
end