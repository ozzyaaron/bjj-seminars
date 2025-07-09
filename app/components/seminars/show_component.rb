class Seminars::ShowComponent < ApplicationComponent
  def initialize(seminar:, related_seminars: [])
    @seminar = seminar
    @related_seminars = related_seminars
  end

  private

  attr_reader :seminar, :related_seminars

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      seminar_header
      seminar_content
      related_seminars_section if related_seminars.any?
    end
  end

  def seminar_header
    div(class: "bg-white shadow") do
      div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-start") do
          div(class: "flex-1") do
            h1(class: "text-3xl font-bold text-gray-900") { seminar.title }
            p(class: "mt-2 text-sm text-gray-600") do
              "by #{seminar.user.name}"
            end
          end
          
          if can_edit_seminar?
            div(class: "flex space-x-3") do
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
    div(class: "max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8") do
      div(class: "grid grid-cols-1 lg:grid-cols-3 gap-8") do
        main_content
        sidebar
      end
    end
  end

  def main_content
    div(class: "lg:col-span-2") do
      seminar_images
      seminar_description
      seminar_instructors
    end
  end

  def seminar_images
    if seminar.has_images?
      div(class: "mb-8") do
        div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
          seminar.ordered_images.each do |image|
            div(class: "rounded-lg overflow-hidden cursor-pointer", "data-controller": "image-modal") do
              img(
                src: rails_blob_url(image.variant(:large)),
                alt: seminar.title,
                class: "w-full h-64 object-cover hover:scale-105 transition-transform duration-200"
              )
            end
          end
        end
      end
    end
  end

  def seminar_description
    if seminar.description.present?
      div(class: "mb-8") do
        h2(class: "text-2xl font-bold text-gray-900 mb-4") { "Description" }
        div(class: "prose max-w-none text-gray-700") do
          simple_format(seminar.description)
        end
      end
    end
  end

  def seminar_instructors
    if seminar.players.any?
      div(class: "mb-8") do
        h2(class: "text-2xl font-bold text-gray-900 mb-4") { "Instructors" }
        div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
          seminar.players.each do |player|
            render PlayerCardComponent.new(player: player)
          end
        end
      end
    end
  end

  def sidebar
    div(class: "space-y-6") do
      seminar_details_card
      seminar_location_card if seminar.address.present?
    end
  end

  def seminar_details_card
    render Components::UI::Card.new do
      div(class: "p-6") do
        h3(class: "text-lg font-semibold text-gray-900 mb-4") { "Seminar Details" }
        
        div(class: "space-y-3") do
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
      div(class: "p-6") do
        h3(class: "text-lg font-semibold text-gray-900 mb-4") { "Location" }
        
        div(class: "flex items-start space-x-3") do
          svg(class: "w-5 h-5 text-gray-400 mt-0.5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
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
          
          div(class: "flex-1") do
            p(class: "text-sm text-gray-900") { seminar.address }
            
            if seminar.latitude.present? && seminar.longitude.present?
              div(class: "mt-2") do
                a(
                  href: "https://maps.google.com/?q=#{seminar.latitude},#{seminar.longitude}",
                  target: "_blank",
                  class: "text-sm text-indigo-600 hover:text-indigo-800"
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
    div(class: "max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8 border-t border-gray-200") do
      h2(class: "text-2xl font-bold text-gray-900 mb-6") { "Related Seminars" }
      
      div(class: "grid gap-6 sm:grid-cols-2 lg:grid-cols-3") do
        related_seminars.each do |related_seminar|
          render Components::SeminarCardComponent.new(seminar: related_seminar)
        end
      end
    end
  end

  def detail_item(label, value)
    div(class: "flex justify-between") do
      span(class: "text-sm font-medium text-gray-500") { label }
      span(class: "text-sm text-gray-900") { value }
    end
  end

  def can_edit_seminar?
    user_signed_in? && (seminar.user == current_user || admin_user?)
  end
end