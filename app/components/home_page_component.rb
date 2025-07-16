class Components::HomePageComponent < Components::ApplicationComponent
  def initialize(recent_seminars:, featured_seminars: [], popular_instructors: [])
    @recent_seminars = recent_seminars
    @featured_seminars = featured_seminars
    @popular_instructors = popular_instructors
  end

  private

  attr_reader :recent_seminars, :featured_seminars, :popular_instructors

  def view_template
    div(class: "min-vh-100 bg-white") do
      render_hero_section
      render_search_section
      render_collections_section if recent_seminars.any?
      render_cta_section unless user_signed_in?
    end
  end

  def render_hero_section
    div(class: "bg-dark text-white overflow-hidden") do
      div(class: "container-xxl py-5") do
        div(class: "row py-5") do
          div(class: "col-12 text-center") do
            h1(class: "display-4 fw-normal mb-4") do
              "Find your perfect seminar."
            end
            
            p(class: "lead mb-5 mx-auto", style: "max-width: 600px;") do
              "Book a seminar with world-class instructors, premium facilities, expert techniques, and comprehensive learning experiences."
            end

            div do
              link_to(
                seminars_path,
                class: "btn btn-light btn-lg px-5 py-3"
              ) do
                "Explore Seminars"
              end
            end
          end
        end
      end
    end
  end

  def render_search_section
    div(class: "position-relative", style: "margin-top: -60px; z-index: 10;") do
      div(class: "container") do
        div(class: "card shadow-lg") do
          div(class: "card-body p-4 p-md-5") do
            render Components::Seminars::SearchBarComponent.new(
              search_params: {},
              placeholder: "Where do you want to train?",
              form_url: seminars_path
            )
            
            # Category filters
            div(class: "mt-4 pt-4 border-top") do
              div(class: "d-flex flex-wrap gap-2 justify-content-center") do
                render_category_filter("Gi", "gi")
                render_category_filter("No-Gi", "no-gi")
                render_category_filter("Competition", "competition")
                render_category_filter("Fundamentals", "fundamentals")
                render_category_filter("Advanced", "advanced")
                render_category_filter("Kids", "kids")
              end
            end
          end
        end
      end
    end
  end

  def render_collections_section
    div(class: "container my-5") do
      # Recent/Upcoming Seminars
      render_seminar_collection(
        title: "This Weekend",
        subtitle: "Don't miss these upcoming seminars",
        seminars: recent_seminars.first(6),
        view_all_text: "View All Seminars",
        view_all_url: seminars_path
      )

      # Featured/Premium seminars if available
      if featured_seminars.any?
        render_seminar_collection(
          title: "Featured Seminars",
          subtitle: "Handpicked seminars with world-class instructors",
          seminars: featured_seminars.first(6),
          view_all_text: "View Featured",
          view_all_url: seminars_path(featured: true),
          additional_classes: "mt-5"
        )
      end

      # Popular instructors collection
      if popular_instructors.any?
        render_instructors_collection
      end
    end
  end

  def render_seminar_collection(title:, subtitle:, seminars:, view_all_text:, view_all_url:, additional_classes: "")
    div(class: additional_classes) do
      div(class: "d-flex justify-content-between align-items-center mb-4") do
        div do
          h2(class: "h3 fw-normal") { title }
          p(class: "text-muted mt-2") { subtitle }
        end
        
        link_to(
          view_all_url,
          class: "btn btn-outline-secondary"
        ) do
          view_all_text
        end
      end

      if seminars.any?
        div(class: "row g-4") do
          seminars.each do |seminar|
            div(class: "col-md-6 col-lg-4") do
              render Components::Seminars::CardComponent.new(seminar: seminar)
            end
          end
        end
      else
        render_empty_collection_state
      end
    end
  end

  def render_instructors_collection
    div(class: "mt-20") do
      div(class: "text-center mb-12") do
        h2(class: "text-3xl font-normal text-gray-900 tracking-tight") { "Popular Instructors" }
        p(class: "text-gray-600 mt-3 text-lg") { "Learn from the legends of the sport" }
      end

      div(class: "grid gap-8 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-6") do
        popular_instructors.first(6).each do |instructor|
          render_instructor_card(instructor)
        end
      end

      div(class: "text-center mt-12") do
        render Components::UI::Button.new(
          href: players_path,
          variant: "secondary",
          class: "text-gray-600 hover:text-gray-900"
        ) do
          "View All Instructors"
        end
      end
    end
  end

  def render_instructor_card(instructor)
    link_to(
      player_path(instructor),
      class: "group block text-center p-4 rounded-xl hover:bg-gray-50 transition-colors duration-200"
    ) do
      div(class: "relative w-20 h-20 mx-auto mb-3") do
        if instructor.image.present?
          image_tag(
            instructor.image,
            alt: instructor.name,
            class: "w-full h-full rounded-full object-cover border-2 border-gray-200 group-hover:border-blue-300 transition-colors duration-200"
          )
        else
          div(class: "w-full h-full rounded-full bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center border-2 border-gray-200 group-hover:border-blue-300 transition-colors duration-200") do
            span(class: "text-white font-semibold text-lg") do
              instructor.name.split(' ').map(&:first).join('')
            end
          end
        end
      end
      
      h3(class: "font-semibold text-gray-900 text-sm group-hover:text-blue-600 transition-colors duration-200") do
        instructor.name
      end
    end
  end

  def render_category_filter(label, value)
    link_to(
      seminars_path(category: value),
      class: "btn btn-outline-secondary btn-sm rounded-pill"
    ) do
      label
    end
  end

  def render_empty_collection_state
    div(class: "text-center py-12 bg-gray-50 rounded-xl") do
      svg(
        class: "mx-auto h-16 w-16 text-gray-300",
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
      
      h3(class: "text-lg font-medium text-gray-900 mt-4") { "No seminars scheduled" }
      p(class: "text-gray-500 mt-2") { "Check back soon for new seminar announcements!" }
    end
  end

  def render_cta_section
    div(class: "bg-dark text-white") do
      div(class: "container text-center py-5") do
        h2(class: "h3 fw-normal mb-4") do
          "Ready to elevate your game?"
        end
        
        p(class: "lead mb-4") do
          "Join thousands of BJJ practitioners discovering world-class seminars."
        end
        
        div do
          link_to(
            new_user_registration_path,
            class: "btn btn-light btn-lg px-5 py-3"
          ) do
            "Create Free Account"
          end
        end
      end
    end
  end
end
