# frozen_string_literal: true

module Components
  module Seminars
    class CardComponent < ApplicationComponent
      def initialize(seminar:, show_favorite: true)
        @seminar = seminar
        @show_favorite = show_favorite
      end

      def view_template
        div(
          class: "card h-100 shadow-sm",
          data: { controller: "seminar-card" }
        ) do
          render_image_section
          render_content_section
        end
      end

      private

      def render_image_section
        div(class: "position-relative", style: "height: 250px;") do
          if @seminar.hero_image.present?
            render_seminar_image
          else
            render_placeholder_image
          end
          
          render_favorite_button if @show_favorite
          render_price_badge if @seminar.price.present?
          render_type_badges
        end
      end

      def render_seminar_image
        image_tag(
          @seminar.hero_image,
          alt: @seminar.title,
          class: "card-img-top object-fit-cover h-100"
        )
      end

      def render_placeholder_image
        div(class: "w-100 h-100 bg-light d-flex align-items-center justify-content-center") do
          svg(
            class: "text-muted",
            width: "64",
            height: "64",
            xmlns: "http://www.w3.org/2000/svg",
            fill: "none",
            viewBox: "0 0 24 24",
            stroke: "currentColor"
          ) do |s|
            s.path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "1.5",
              d: "M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
            )
          end
        end
      end

      def render_favorite_button
        button(
          type: "button",
          class: "btn btn-light btn-sm position-absolute top-0 end-0 m-2 rounded-circle",
          data: { 
            action: "click->seminar-card#toggleFavorite",
            seminar_id: @seminar.id
          }
        ) do
          svg(
            class: "text-muted",
            width: "20",
            height: "20",
            xmlns: "http://www.w3.org/2000/svg",
            fill: "none",
            viewBox: "0 0 24 24",
            stroke: "currentColor"
          ) do |s|
            s.path(
              stroke_linecap: "round",
              stroke_linejoin: "round",
              stroke_width: "2",
              d: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
            )
          end
        end
      end

      def render_price_badge
        div(class: "position-absolute top-0 start-0 m-2") do
          span(class: "badge bg-light text-dark") { format_price(@seminar.price) }
        end
      end

      def render_type_badges
        return unless @seminar.seminar_type.present?

        div(class: "position-absolute bottom-0 start-0 m-2") do
          render_type_badge(@seminar.seminar_type)
        end
      end

      def render_type_badge(type)
        badge_class = case type.downcase
        when "gi"
          "badge bg-primary"
        when "no-gi", "nogi"
          "badge bg-dark"
        when "both", "gi & no-gi"
          "badge bg-secondary"
        else
          "badge bg-secondary"
        end

        span(class: badge_class) do
          type.upcase
        end
      end

      def render_content_section
        div(class: "card-body") do
          render_header
          render_instructors
          render_location_and_date
          render_action_button
        end
      end

      def render_header
        div(class: "mb-3") do
          link_to(
            seminar_path(@seminar),
            class: "text-decoration-none"
          ) do
            h5(class: "card-title text-dark") do
              @seminar.title
            end
          end
        end
      end

      def render_instructors
        if @seminar.players.any?
          div(class: "mb-4") do
            div(class: "flex items-center gap-2 mb-2") do
              render_instructor_avatars
              render_instructor_names
            end
          end
        end
      end

      def render_instructor_avatars
        div(class: "flex -space-x-2") do
          @seminar.players.first(3).each_with_index do |player, index|
            div(
              class: "relative w-8 h-8 rounded-full border-2 border-white bg-gray-200 flex items-center justify-center",
              style: "z-index: #{10 - index}"
            ) do
              if player.image.present?
                image_tag(
                  player.image,
                  alt: player.name,
                  class: "w-full h-full rounded-full object-cover"
                )
              else
                span(class: "text-xs font-semibold text-gray-600") do
                  player.name.split(' ').map(&:first).join('')
                end
              end
            end
          end
          
          if @seminar.players.count > 3
            div(class: "relative w-8 h-8 rounded-full border-2 border-white bg-gray-100 flex items-center justify-center") do
              span(class: "text-xs font-medium text-gray-600") { "+#{@seminar.players.count - 3}" }
            end
          end
        end
      end

      def render_instructor_names
        div(class: "flex-1 min-w-0") do
          names = @seminar.players.map(&:name)
          display_names = names.first(2)
          
          p(class: "text-sm font-medium text-gray-700 truncate") do
            display_names.join(", ")
            span(class: "text-gray-500") { " +#{names.count - 2} more" } if names.count > 2
          end
        end
      end

      def render_location_and_date
        div(class: "space-y-2 mb-4") do
          if @seminar.city.present?
            div(class: "flex items-center text-sm text-gray-600") do
              svg(
                class: "w-4 h-4 mr-2 text-gray-400 flex-shrink-0",
                xmlns: "http://www.w3.org/2000/svg",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor"
              ) do |s|
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
              span(class: "truncate") { [@seminar.city, @seminar.state].compact.join(", ") }
            end
          end

          if @seminar.starts_at.present?
            div(class: "flex items-center text-sm text-gray-600") do
              svg(
                class: "w-4 h-4 mr-2 text-gray-400 flex-shrink-0",
                xmlns: "http://www.w3.org/2000/svg",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor"
              ) do |s|
                s.path(
                  stroke_linecap: "round",
                  stroke_linejoin: "round",
                  stroke_width: "2",
                  d: "M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                )
              end
              span { format_date_time(@seminar.starts_at) }
            end
          end
        end
      end

      def render_action_button
        link_to(
          seminar_path(@seminar),
          class: "btn btn-primary w-100"
        ) do
          "View Details"
        end
      end

      def format_price(price)
        return "Free" if price.zero?
        "$#{price.to_i}"
      end

      def format_date_time(datetime)
        return "" unless datetime

        if datetime.to_date == Date.current
          "Today, #{datetime.strftime('%l:%M %p').strip}"
        elsif datetime.to_date == Date.current + 1.day
          "Tomorrow, #{datetime.strftime('%l:%M %p').strip}"
        else
          datetime.strftime('%b %d, %Y at %l:%M %p').strip
        end
      end
    end
  end
end