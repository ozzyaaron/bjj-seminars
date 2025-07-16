class Components::Seminars::IndexComponent < Components::ApplicationComponent
  def initialize(seminars:, search_params: {}, players: [])
    @seminars = seminars
    @search_params = search_params
    @players = players
  end

  private

  attr_reader :seminars, :search_params, :players

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      render_hero_section
      render_main_content
    end
  end

  def render_hero_section
    div(class: "bg-gradient-to-br from-blue-50 to-indigo-100 pb-16") do
      div(class: "max-w-7xl mx-auto pt-8 pb-8 px-4 sm:px-6 lg:px-8") do
        div(class: "text-center mb-8") do
          h1(class: "text-4xl font-bold text-gray-900 mb-4") { "Find Your Next BJJ Seminar" }
          p(class: "text-xl text-gray-600 max-w-2xl mx-auto") do
            "Discover world-class Brazilian Jiu-Jitsu seminars with top instructors near you"
          end
        end
        
        div(class: "max-w-2xl mx-auto") do
          render Components::Seminars::SearchBarComponent.new(
            search_params: search_params,
            placeholder: "Search by location, instructor, or topic..."
          )
        end
        
        if user_signed_in?
          div(class: "text-center mt-6") do
            render Components::UI::Button.new(
              href: new_seminar_path,
              variant: "primary"
            ) do
              "Host a Seminar"
            end
          end
        end
      end
    end
  end

  def render_main_content
    div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8") do
      div(class: "lg:grid lg:grid-cols-4 lg:gap-8") do
        render_filter_sidebar
        render_seminars_section
      end
    end
  end

  def render_filter_sidebar
    div(class: "hidden lg:block lg:col-span-1") do
      div(class: "sticky top-8") do
        render Components::Seminars::FilterPanelComponent.new(
          filters: search_params,
          players: players
        )
      end
    end
  end

  def render_seminars_section
    div(class: "lg:col-span-3") do
      render_results_header
      render_seminars_content
    end
  end

  def render_results_header
    div(class: "flex items-center justify-between mb-6") do
      div do
        if search_params.values.any?(&:present?)
          p(class: "text-sm text-gray-600") do
            "#{seminars.count} seminar#{'s' unless seminars.count == 1} found"
          end
        else
          p(class: "text-sm text-gray-600") do
            "Showing all #{seminars.count} seminar#{'s' unless seminars.count == 1}"
          end
        end
      end
      
      # View toggle buttons (grid/list view)
      div(class: "flex items-center space-x-2") do
        button(
          type: "button",
          class: "p-2 text-gray-400 hover:text-gray-600 transition-colors duration-200",
          data: { action: "click->seminars-view#setGridView" }
        ) do
          svg(class: "w-5 h-5", fill: "currentColor", viewBox: "0 0 20 20") do |s|
            s.path(d: "M5 3a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2V5a2 2 0 00-2-2H5zM5 11a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2v-2a2 2 0 00-2-2H5zM11 5a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V5zM11 13a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z")
          end
        end
      end
    end
  end

  def render_seminars_content
    turbo_frame_tag "seminars-list" do
      if seminars.any?
        render_seminars_grid
      else
        render_empty_state
      end
    end
  end

  def render_seminars_grid
    div(
      class: "grid gap-6 sm:grid-cols-2 xl:grid-cols-3",
      data: { controller: "seminars-view", seminars_view_target: "grid" }
    ) do
      seminars.each do |seminar|
        render Components::Seminars::CardComponent.new(seminar: seminar)
      end
    end
  end

  def render_empty_state
    div(class: "text-center py-16") do
      svg(
        class: "mx-auto h-24 w-24 text-gray-300",
        fill: "none",
        viewBox: "0 0 24 24",
        stroke: "currentColor"
      ) do |s|
        s.path(
          stroke_linecap: "round",
          stroke_linejoin: "round",
          stroke_width: "1",
          d: "M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
        )
      end
      
      div(class: "mt-8") do
        if search_params.values.any?(&:present?)
          h3(class: "text-xl font-medium text-gray-900 mb-2") { "No seminars found matching your criteria" }
          p(class: "text-gray-500 mb-6") { "Try adjusting your filters or search terms to find what you're looking for." }
          
          render Components::UI::Button.new(
            href: seminars_path,
            variant: "secondary"
          ) do
            "Clear all filters"
          end
        else
          h3(class: "text-xl font-medium text-gray-900 mb-2") { "No seminars available" }
          p(class: "text-gray-500 mb-6") { "Be the first to share an upcoming seminar with the community." }
          
          if user_signed_in?
            render Components::UI::Button.new(
              href: new_seminar_path,
              variant: "primary"
            ) do
              "Add the first seminar"
            end
          else
            render Components::UI::Button.new(
              href: new_user_registration_path,
              variant: "primary"
            ) do
              "Sign up to add seminars"
            end
          end
        end
      end
    end
  end
end