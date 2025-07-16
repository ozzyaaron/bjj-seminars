# frozen_string_literal: true

module Components
  module Seminars
    class FilterPanelComponent < ApplicationComponent
      def initialize(filters: {}, players: [], form_url: nil)
        @filters = filters
        @players = players
        @form_url = form_url || seminars_path
      end

      def view_template
        div(
          class: "bg-white rounded-xl shadow-sm border border-gray-200 p-6",
          data: { controller: "filter-panel" }
        ) do
          render_filter_header
          render_filter_form
        end
      end

      private

      def render_filter_header
        div(class: "flex items-center justify-between mb-6") do
          h2(class: "text-lg font-semibold text-gray-900") { "Filters" }
          if @filters.values.any?(&:present?)
            button(
              type: "button",
              class: "text-sm text-blue-600 hover:text-blue-800 font-medium",
              data: { action: "click->filter-panel#clearAll" }
            ) { "Clear all" }
          end
        end
      end

      def render_filter_form
        form_with(url: @form_url, method: :get, data: { 
          filter_panel_target: "form",
          turbo_frame: "seminars-list"
        }) do |f|
          div(class: "space-y-6") do
            render_location_filter(f)
            render_date_filter(f)
            render_instructor_filter(f)
            render_price_filter(f)
            render_type_filter(f)
          end
        end
      end

      def render_location_filter(form)
        div(class: "border-b border-gray-100 pb-6") do
          label(class: "block text-sm font-medium text-gray-700 mb-3") { "Location" }
          form.text_field :location,
            value: @filters[:location],
            placeholder: "City or venue",
            class: css_classes(
              "w-full px-3 py-2 border border-gray-300 rounded-lg",
              "focus:ring-2 focus:ring-blue-500 focus:border-blue-500",
              "text-sm"
            ),
            data: { action: "input->filter-panel#applyFilters" }
        end
      end

      def render_date_filter(form)
        div(class: "border-b border-gray-100 pb-6") do
          label(class: "block text-sm font-medium text-gray-700 mb-3") { "Date Range" }
          div(class: "space-y-3") do
            form.date_field :start_date,
              value: @filters[:start_date],
              class: css_classes(
                "w-full px-3 py-2 border border-gray-300 rounded-lg",
                "focus:ring-2 focus:ring-blue-500 focus:border-blue-500",
                "text-sm"
              ),
              data: { action: "change->filter-panel#applyFilters" }
            
            form.date_field :end_date,
              value: @filters[:end_date],
              class: css_classes(
                "w-full px-3 py-2 border border-gray-300 rounded-lg",
                "focus:ring-2 focus:ring-blue-500 focus:border-blue-500",
                "text-sm"
              ),
              data: { action: "change->filter-panel#applyFilters" }
          end
        end
      end

      def render_instructor_filter(form)
        div(class: "border-b border-gray-100 pb-6") do
          label(class: "block text-sm font-medium text-gray-700 mb-3") { "Instructor" }
          form.text_field :instructor,
            value: @filters[:instructor],
            placeholder: "Instructor name",
            class: css_classes(
              "w-full px-3 py-2 border border-gray-300 rounded-lg",
              "focus:ring-2 focus:ring-blue-500 focus:border-blue-500",
              "text-sm"
            ),
            data: { action: "input->filter-panel#applyFilters" }
          
          # Instructor quick select buttons if we have popular instructors
          if @players.any?
            div(class: "mt-3 flex flex-wrap gap-2") do
              @players.first(5).each do |player|
                render_instructor_pill(player, form)
              end
            end
          end
        end
      end

      def render_instructor_pill(player, form)
        button(
          type: "button",
          class: css_classes(
            "px-3 py-1 text-xs rounded-full transition-colors",
            instructor_selected?(player.name) ? 
              "bg-blue-100 text-blue-800 border border-blue-300" : 
              "bg-gray-100 text-gray-700 border border-gray-300 hover:bg-gray-200"
          ),
          data: { 
            action: "click->filter-panel#toggleInstructor",
            instructor: player.name
          }
        ) { player.name }
      end

      def render_price_filter(form)
        div(class: "border-b border-gray-100 pb-6") do
          label(class: "block text-sm font-medium text-gray-700 mb-3") { "Price Range" }
          div(class: "grid grid-cols-2 gap-3") do
            form.number_field :min_price,
              value: @filters[:min_price],
              placeholder: "Min",
              min: 0,
              class: css_classes(
                "w-full px-3 py-2 border border-gray-300 rounded-lg",
                "focus:ring-2 focus:ring-blue-500 focus:border-blue-500",
                "text-sm"
              ),
              data: { action: "input->filter-panel#applyFilters" }
            
            form.number_field :max_price,
              value: @filters[:max_price],
              placeholder: "Max",
              min: 0,
              class: css_classes(
                "w-full px-3 py-2 border border-gray-300 rounded-lg",
                "focus:ring-2 focus:ring-blue-500 focus:border-blue-500",
                "text-sm"
              ),
              data: { action: "input->filter-panel#applyFilters" }
          end
        end
      end

      def render_type_filter(form)
        div do
          label(class: "block text-sm font-medium text-gray-700 mb-3") { "Seminar Type" }
          div(class: "space-y-2") do
            render_checkbox(form, "gi", "Gi")
            render_checkbox(form, "no_gi", "No-Gi")
            render_checkbox(form, "both", "Gi & No-Gi")
          end
        end
      end

      def render_checkbox(form, value, label_text)
        label(class: "flex items-center cursor-pointer hover:bg-gray-50 -mx-2 px-2 py-1 rounded") do
          form.check_box :types,
            { 
              checked: type_selected?(value),
              class: "h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded",
              data: { action: "change->filter-panel#applyFilters" }
            },
            value,
            nil
          span(class: "ml-2 text-sm text-gray-700") { label_text }
        end
      end

      def instructor_selected?(name)
        @filters[:instructor]&.downcase == name.downcase
      end

      def type_selected?(type)
        Array(@filters[:types]).include?(type)
      end
    end
  end
end