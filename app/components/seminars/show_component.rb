class Components::Seminars::ShowComponent < Components::ApplicationComponent
  def initialize(seminar:, related_seminars: [])
    @seminar = seminar
    @related_seminars = related_seminars
  end

  private

  attr_reader :seminar, :related_seminars

  def view_template
    div(class: "min-vh-100 bg-light") do
      seminar_header
      seminar_content
      related_seminars_section if related_seminars.any?
    end
  end

  def seminar_header
    div(class: "bg-white shadow-sm") do
      div(class: "container-fluid py-4 px-3 px-md-4") do
        div(class: "d-flex justify-content-between align-items-start") do
          div(class: "flex-grow-1") do
            h1(class: "display-6 fw-bold text-dark") { seminar.title }
            p(class: "mt-2 small text-muted") do
              "by #{seminar.user.name}"
            end
          end
          
          if can_edit_seminar?
            div(class: "d-flex gap-3") do
              render Components::UI::Button.new(
                href: edit_seminar_path(seminar),
                variant: "secondary"
              ) do
                "Edit"
              end
              
              render Components::UI::Button.new(
                href: seminar_path(seminar),
                method: :delete,
                variant: "danger",
                confirm: "Are you sure you want to delete this seminar?"
              ) do
                "Delete"
              end
            end
          end
        end
      end
    end
  end

  def seminar_content
    div(class: "container-fluid py-4 px-3 px-md-4") do
      div(class: "row g-4") do
        main_content
        sidebar
      end
    end
  end

  def main_content
    div(class: "col-lg-8") do
      seminar_images
      seminar_description
      seminar_instructors
    end
  end

  def seminar_images
    if seminar.has_images?
      div(class: "mb-4") do
        div(class: "row row-cols-1 row-cols-md-2 g-3") do
          seminar.ordered_images.each do |image|
            div(class: "col") do
              div(class: "rounded overflow-hidden", "data-controller": "image-modal", style: "cursor: pointer;") do
                img(
                  src: rails_blob_url(image.variant(:large)),
                  alt: seminar.title,
                  class: "img-fluid object-fit-cover",
                  style: "height: 16rem; width: 100%;"
                )
              end
            end
          end
        end
      end
    end
  end

  def seminar_description
    if seminar.description.present?
      div(class: "mb-4") do
        h2(class: "h4 fw-bold text-dark mb-3") { "Description" }
        div(class: "text-muted") do
          simple_format(seminar.description)
        end
      end
    end
  end

  def seminar_instructors
    if seminar.players.any?
      div(class: "mb-4") do
        h2(class: "h4 fw-bold text-dark mb-3") { "Instructors" }
        div(class: "row row-cols-1 row-cols-md-2 g-3") do
          seminar.players.each do |player|
            div(class: "col") do
              render Components::PlayerCardComponent.new(player: player)
            end
          end
        end
      end
    end
  end

  def sidebar
    div(class: "col-lg-4") do
      div(class: "d-flex flex-column gap-4") do
        seminar_details_card
        seminar_location_card if seminar.address.present?
      end
    end
  end

  def seminar_details_card
    render Components::UI::Card.new do
      div(class: "card-body") do
        h3(class: "h5 fw-semibold text-dark mb-3") { "Seminar Details" }
        
        div(class: "d-flex flex-column gap-3") do
          detail_item("Date & Time", seminar.starts_at.strftime("%B %d, %Y at %I:%M %p"))
          
          if seminar.price.present? && seminar.price > 0
            detail_item("Price", "$#{seminar.price}")
          end
          
          if seminar.max_participants.present?
            detail_item("Max Participants", seminar.max_participants.to_s)
          end
          
          detail_item("Posted", time_ago_in_words(seminar.created_at) + " ago")
        end
      end
    end
  end

  def seminar_location_card
    render Components::UI::Card.new do
      div(class: "card-body") do
        h3(class: "h5 fw-semibold text-dark mb-3") { "Location" }
        
        div(class: "d-flex align-items-start gap-3") do
          svg(class: "text-muted", width: "20", height: "20", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
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
          
          div(class: "flex-grow-1") do
            p(class: "small text-dark mb-0") { seminar.address }
            
            if seminar.latitude.present? && seminar.longitude.present?
              div(class: "mt-2") do
                a(
                  href: "https://maps.google.com/?q=#{seminar.latitude},#{seminar.longitude}",
                  target: "_blank",
                  class: "small text-primary text-decoration-none"
                ) do
                  "View on Google Maps"
                end
              end
            end
          end
        end
      end
    end
  end

  def related_seminars_section
    div(class: "container-fluid py-4 px-3 px-md-4 border-top") do
      h2(class: "h4 fw-bold text-dark mb-4") { "Related Seminars" }
      
      div(class: "row row-cols-1 row-cols-sm-2 row-cols-lg-3 g-4") do
        related_seminars.each do |related_seminar|
          div(class: "col") do
            render Components::SeminarCardComponent.new(seminar: related_seminar)
          end
        end
      end
    end
  end

  def detail_item(label, value)
    div(class: "d-flex justify-content-between") do
      span(class: "small fw-medium text-muted") { label }
      span(class: "small text-dark") { value }
    end
  end

  def can_edit_seminar?
    user_signed_in? && (seminar.user == current_user || admin_user?)
  end
end