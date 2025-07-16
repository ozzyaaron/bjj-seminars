class Components::Seminars::IndexComponent < Components::ApplicationComponent
  include Phlex::Rails::Helpers::TurboFrameTag
  def initialize(seminars:, search_params: {}, players: [])
    @seminars = seminars
    @search_params = search_params
    @players = players
  end

  private

  attr_reader :seminars, :search_params, :players

  def view_template
    div(class: "min-vh-100 bg-light") do
      render_hero_section
      render_main_content
    end
  end

  def render_hero_section
    div(class: "bg-primary text-white pb-5") do
      div(class: "container-fluid py-4 px-3 px-md-4") do
        div(class: "text-center mb-4") do
          h1(class: "display-4 fw-bold mb-4") { "Find Your Next BJJ Seminar" }
          p(class: "lead mx-auto", style: "max-width: 48rem;") do
            "Discover world-class Brazilian Jiu-Jitsu seminars with top instructors near you"
          end
        end
        
        div(class: "mx-auto", style: "max-width: 48rem;") do
          render Components::Seminars::SearchBarComponent.new(
            search_params: search_params,
            placeholder: "Search by location, instructor, or topic..."
          )
        end
        
        if user_signed_in?
          div(class: "text-center mt-4") do
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
    div(class: "container-fluid px-3 px-md-4 py-4") do
      div(class: "row") do
        render_filter_sidebar
        render_seminars_section
      end
    end
  end

  def render_filter_sidebar
    div(class: "d-none d-lg-block col-lg-3") do
      div(class: "sticky-top", style: "top: 2rem;") do
        render Components::Seminars::FilterPanelComponent.new(
          filters: search_params,
          players: players,
          form_url: seminars_path
        )
      end
    end
  end

  def render_seminars_section
    div(class: "col-lg-9") do
      render_results_header
      render_seminars_content
    end
  end

  def render_results_header
    div(class: "d-flex align-items-center justify-content-between mb-4") do
      div do
        if search_params.values.any?(&:present?)
          p(class: "small text-muted mb-0") do
            "#{seminars.count} seminar#{'s' unless seminars.count == 1} found"
          end
        else
          p(class: "small text-muted mb-0") do
            "Showing all #{seminars.count} seminar#{'s' unless seminars.count == 1}"
          end
        end
      end
      
      # View toggle buttons (grid/list view)
      div(class: "d-flex align-items-center gap-2") do
        button(
          type: "button",
          class: "btn btn-sm btn-outline-secondary p-2",
          data: { action: "click->seminars-view#setGridView" }
        ) do
          svg(width: "20", height: "20", fill: "currentColor", viewBox: "0 0 20 20") do |s|
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
      class: "row row-cols-1 row-cols-sm-2 row-cols-xl-3 g-4",
      data: { controller: "seminars-view", seminars_view_target: "grid" }
    ) do
      seminars.each do |seminar|
        div(class: "col") do
          render Components::Seminars::CardComponent.new(seminar: seminar)
        end
      end
    end
  end

  def render_empty_state
    div(class: "text-center py-5") do
      svg(
        class: "mx-auto text-muted",
        width: "96",
        height: "96",
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
      
      div(class: "mt-4") do
        if search_params.values.any?(&:present?)
          h3(class: "h5 fw-normal text-dark mb-2") { "No seminars found matching your criteria" }
          p(class: "text-muted mb-4") { "Try adjusting your filters or search terms to find what you're looking for." }
          
          render Components::UI::Button.new(
            href: seminars_path,
            variant: "secondary"
          ) do
            "Clear all filters"
          end
        else
          h3(class: "h5 fw-normal text-dark mb-2") { "No seminars available" }
          p(class: "text-muted mb-4") { "Be the first to share an upcoming seminar with the community." }
          
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