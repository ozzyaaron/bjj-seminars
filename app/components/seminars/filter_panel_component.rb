# frozen_string_literal: true

module Components
  module Seminars
    class FilterPanelComponent < ApplicationComponent
      def initialize(filters: {}, players: [], form_url: nil)
        @filters = filters
        @players = players
        @form_url_param = form_url
      end

      def view_template
        div(
          class: "card shadow-sm",
          data: { controller: "filter-panel" }
        ) do
          div(class: "card-body") do
            render_filter_header
            render_filter_form
          end
        end
      end

      private

      def render_filter_header
        div(class: "d-flex align-items-center justify-content-between mb-4") do
          h2(class: "h5 fw-semibold text-dark mb-0") { "Filters" }
          if @filters.values.any?(&:present?)
            button(
              type: "button",
              class: "btn btn-link btn-sm p-0 text-primary fw-medium",
              data: { action: "click->filter-panel#clearAll" }
            ) { "Clear all" }
          end
        end
      end

      def render_filter_form
        form_with(url: form_url, method: :get, data: { 
          filter_panel_target: "form",
          turbo_frame: "seminars-list"
        }) do |f|
          div(class: "d-flex flex-column gap-4") do
            render_location_filter(f)
            render_date_filter(f)
            render_instructor_filter(f)
            render_price_filter(f)
            render_type_filter(f)
          end
        end
      end

      def render_location_filter(form)
        div(class: "border-bottom pb-3") do
          label(class: "form-label fw-medium text-dark mb-2") { "Location" }
          form.text_field :location,
            value: @filters[:location],
            placeholder: "City or venue",
            class: "form-control",
            data: { action: "input->filter-panel#applyFilters" }
        end
      end

      def render_date_filter(form)
        div(class: "border-bottom pb-3") do
          label(class: "form-label fw-medium text-dark mb-2") { "Date Range" }
          div(class: "d-flex flex-column gap-2") do
            form.date_field :start_date,
              value: @filters[:start_date],
              class: "form-control",
              data: { action: "change->filter-panel#applyFilters" }
            
            form.date_field :end_date,
              value: @filters[:end_date],
              class: "form-control",
              data: { action: "change->filter-panel#applyFilters" }
          end
        end
      end

      def render_instructor_filter(form)
        div(class: "border-bottom pb-3") do
          label(class: "form-label fw-medium text-dark mb-2") { "Instructor" }
          form.text_field :instructor,
            value: @filters[:instructor],
            placeholder: "Instructor name",
            class: "form-control",
            data: { action: "input->filter-panel#applyFilters" }
          
          # Instructor quick select buttons if we have popular instructors
          if @players.any?
            div(class: "mt-2 d-flex flex-wrap gap-2") do
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
          class: instructor_selected?(player.name) ? 
            "btn btn-primary btn-sm" : 
            "btn btn-outline-secondary btn-sm",
          data: { 
            action: "click->filter-panel#toggleInstructor",
            instructor: player.name
          }
        ) { player.name }
      end

      def render_price_filter(form)
        div(class: "border-bottom pb-3") do
          label(class: "form-label fw-medium text-dark mb-2") { "Price Range" }
          div(class: "row g-2") do
            div(class: "col-6") do
              form.number_field :min_price,
                value: @filters[:min_price],
                placeholder: "Min",
                min: 0,
                class: "form-control",
                data: { action: "input->filter-panel#applyFilters" }
            end
            
            div(class: "col-6") do
              form.number_field :max_price,
                value: @filters[:max_price],
                placeholder: "Max",
                min: 0,
                class: "form-control",
                data: { action: "input->filter-panel#applyFilters" }
            end
          end
        end
      end

      def render_type_filter(form)
        div do
          label(class: "form-label fw-medium text-dark mb-2") { "Seminar Type" }
          div(class: "d-flex flex-column gap-2") do
            render_checkbox(form, "gi", "Gi")
            render_checkbox(form, "no_gi", "No-Gi")
            render_checkbox(form, "both", "Gi & No-Gi")
          end
        end
      end

      def render_checkbox(form, value, label_text)
        div(class: "form-check") do
          form.check_box :types,
            { 
              checked: type_selected?(value),
              class: "form-check-input",
              data: { action: "change->filter-panel#applyFilters" }
            },
            value,
            nil
          label(class: "form-check-label") { label_text }
        end
      end

      def instructor_selected?(name)
        @filters[:instructor]&.downcase == name.downcase
      end

      def type_selected?(type)
        Array(@filters[:types]).include?(type)
      end

      def form_url
        @form_url_param || seminars_path
      end
    end
  end
end