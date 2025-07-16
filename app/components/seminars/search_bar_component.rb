# frozen_string_literal: true

module Components
  module Seminars
    class SearchBarComponent < ApplicationComponent
      def initialize(search_params: {}, placeholder: "Search by location, instructor, or topic...", form_url: nil)
        @search_params = search_params
        @placeholder = placeholder
        @form_url = form_url
      end

      def view_template
        div(class: "w-100") do
          form_with(url: form_url, method: :get, data: { controller: "search", turbo_frame: "seminars-list" }) do |f|
            div(class: "position-relative") do
              render_search_input(f)
              render_search_icon
            end
          end
        end
      end

      private

      def form_url
        @form_url || seminars_path
      end

      def render_search_input(form)
        form.text_field :search,
          value: @search_params[:search],
          placeholder: @placeholder,
          class: "form-control form-control-lg ps-5",
          data: {
            search_target: "input",
            action: "input->search#performSearch"
          },
          autocomplete: "off"
      end

      def render_search_icon
        div(class: "position-absolute top-50 start-0 translate-middle-y ms-3") do
          svg(
            class: "text-muted",
            width: "20",
            height: "20",
            xmlns: "http://www.w3.org/2000/svg",
            viewBox: "0 0 20 20",
            fill: "currentColor"
          ) do |s|
            s.path(
              fill_rule: "evenodd",
              d: "M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z",
              clip_rule: "evenodd"
            )
          end
        end
      end
    end
  end
end