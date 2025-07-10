class Components::Seminars::IndexComponent < Components::ApplicationComponent
  def initialize(seminars:, search_params: {})
    @seminars = seminars
    @search_params = search_params
  end

  private

  attr_reader :seminars, :search_params

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      page_header
      search_section
      seminars_grid
    end
  end

  def page_header
    div(class: "bg-white shadow") do
      div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-center") do
          div do
            h1(class: "text-3xl font-bold text-gray-900") { "BJJ Seminars" }
            p(class: "mt-2 text-sm text-gray-600") { "Discover upcoming Brazilian Jiu-Jitsu seminars" }
          end
          
          if user_signed_in?
            render Components::UI::Button.new(
              href: new_seminar_path,
              variant: "primary"
            ) do
              "Add Seminar"
            end
          end
        end
      end
    end
  end

  def search_section
    div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
      form_with(url: seminars_path, method: :get, local: true, class: "mb-6") do |form|
        div(class: "grid grid-cols-1 md:grid-cols-3 gap-4") do
          div do
            label(for: "search", class: "block text-sm font-medium text-gray-700 mb-2") { "Search" }
            input(
              type: "text",
              name: "search",
              id: "search",
              value: search_params[:search],
              placeholder: "Search seminars, instructors, or descriptions...",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            )
          end
          
          div do
            label(for: "location", class: "block text-sm font-medium text-gray-700 mb-2") { "Location" }
            input(
              type: "text",
              name: "location",
              id: "location",
              value: search_params[:location],
              placeholder: "City, state, or address...",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            )
          end
          
          div do
            label(for: "instructor", class: "block text-sm font-medium text-gray-700 mb-2") { "Instructor" }
            input(
              type: "text",
              name: "instructor",
              id: "instructor",
              value: search_params[:instructor],
              placeholder: "Instructor name...",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            )
          end
        end
        
        div(class: "mt-4 flex justify-end space-x-3") do
          if search_params[:search].present? || search_params[:location].present? || search_params[:instructor].present?
            render Components::UI::Button.new(
              href: seminars_path,
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

  def seminars_grid
    div(class: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12") do
      if seminars.any?
        div(class: "grid gap-6 sm:grid-cols-2 lg:grid-cols-3") do
          seminars.each do |seminar|
            render Components::SeminarCardComponent.new(seminar: seminar)
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
          d: "M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4"
        )
      end
      h3(class: "mt-2 text-sm font-medium text-gray-900") { "No seminars found" }
      p(class: "mt-1 text-sm text-gray-500") { "Try adjusting your search criteria or check back later for new seminars." }
      
      if user_signed_in?
        div(class: "mt-6") do
          render Components::UI::Button.new(
            href: new_seminar_path,
            variant: "primary"
          ) do
            "Add the first seminar"
          end
        end
      end
    end
  end
end