class SeminarCardComponent < ApplicationComponent
  def initialize(seminar:)
    @seminar = seminar
  end

  private

  attr_reader :seminar

  def view_template
    render UI::CardComponent.new(class: "h-full") do
      seminar_image
      card_content
    end
  end

  def seminar_image
    div(class: "aspect-w-16 aspect-h-9") do
      if seminar.images.attached? && seminar.images.first.present?
        img(
          src: rails_blob_url(seminar.images.first.variant(resize_to_limit: [400, 225])),
          alt: seminar.title,
          class: "w-full h-48 object-cover"
        )
      else
        div(class: "w-full h-48 bg-gray-200 flex items-center justify-center") do
          svg(
            class: "w-12 h-12 text-gray-400",
            fill: "none",
            stroke: "currentColor",
            viewBox: "0 0 24 24"
          ) do |s|
            s.path(
              stroke_linecap: "round",
              stroke_linejoin: "round", 
              stroke_width: "2",
              d: "M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
            )
          end
        end
      end
    end
  end

  def card_content
    div(class: "p-6") do
      div(class: "flex-1") do
        seminar_header
        seminar_details
        seminar_instructors
      end
      seminar_footer
    end
  end

  def seminar_header
    div(class: "mb-4") do
      h3(class: "text-xl font-semibold text-gray-900 mb-2") do
        a(href: seminar_path(seminar), class: "hover:text-indigo-600") do
          seminar.title
        end
      end
      
      if seminar.description.present?
        p(class: "text-gray-600 text-sm line-clamp-2") do
          seminar.description
        end
      end
    end
  end

  def seminar_details
    div(class: "space-y-2 mb-4") do
      # Date and time
      div(class: "flex items-center text-sm text-gray-500") do
        svg(class: "w-4 h-4 mr-2", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
          s.path(
            stroke_linecap: "round",
            stroke_linejoin: "round",
            stroke_width: "2",
            d: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
          )
        end
        span { seminar.starts_at.strftime("%B %d, %Y at %I:%M %p") }
      end

      # Location
      if seminar.address.present?
        div(class: "flex items-center text-sm text-gray-500") do
          svg(class: "w-4 h-4 mr-2", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
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
          span { truncate_address(seminar.address) }
        end
      end

      # Price
      if seminar.price.present? && seminar.price > 0
        div(class: "flex items-center text-sm text-gray-500") do
          svg(class: "w-4 h-4 mr-2", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do |s|
            s.path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "2", 
              d: "M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"
            )
          end
          span { "$#{seminar.price}" }
        end
      end
    end
  end

  def seminar_instructors
    if seminar.players.any?
      div(class: "mb-4") do
        p(class: "text-sm font-medium text-gray-900 mb-2") { "Instructors:" }
        div(class: "flex flex-wrap gap-1") do
          seminar.players.limit(3).each do |player|
            render UI::BadgeComponent.new(variant: "secondary", size: "sm") do
              player.name
            end
          end
          
          if seminar.players.count > 3
            render UI::BadgeComponent.new(variant: "gray", size: "sm") do
              "+#{seminar.players.count - 3} more"
            end
          end
        end
      end
    end
  end

  def seminar_footer
    div(class: "flex items-center justify-between pt-4 border-t border-gray-200") do
      div(class: "flex items-center text-sm text-gray-500") do
        span { "by #{seminar.user.name}" }
      end
      
      render UI::ButtonComponent.new(
        href: seminar_path(seminar),
        variant: "primary",
        size: "sm"
      ) do
        "View Details"
      end
    end
  end

  def truncate_address(address)
    return address if address.length <= 50
    "#{address[0...47]}..."
  end
end