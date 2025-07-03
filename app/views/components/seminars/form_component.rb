class Seminars::FormComponent < ApplicationComponent
  def initialize(seminar:, teams:, players:, action_url: nil)
    @seminar = seminar
    @teams = teams
    @players = players
    @action_url = action_url || (seminar.persisted? ? seminar_path(seminar) : seminars_path)
  end

  private

  attr_reader :seminar, :teams, :players, :action_url

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      form_header
      form_content
    end
  end

  def form_header
    div(class: "bg-white shadow") do
      div(class: "max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8") do
        div(class: "flex justify-between items-center") do
          div do
            h1(class: "text-3xl font-bold text-gray-900") do
              seminar.persisted? ? "Edit Seminar" : "Add New Seminar"
            end
            p(class: "mt-2 text-sm text-gray-600") do
              "Share your BJJ seminar with the community"
            end
          end
          
          render UI::ButtonComponent.new(
            href: seminar.persisted? ? seminar_path(seminar) : seminars_path,
            variant: "secondary"
          ) do
            "Cancel"
          end
        end
      end
    end
  end

  def form_content
    div(class: "max-w-4xl mx-auto py-8 px-4 sm:px-6 lg:px-8") do
      render UI::CardComponent.new do
        div(class: "p-6") do
          render_errors if seminar.errors.any?
          
          form_with(model: seminar, url: action_url, local: true, class: "space-y-6") do |form|
            basic_info_section(form)
            datetime_section(form)
            location_section(form)
            instructors_section(form)
            additional_info_section(form)
            form_actions(form)
          end
        end
      end
    end
  end

  def basic_info_section(form)
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Basic Information" }
      
      div do
        label(for: "seminar_title", class: "block text-sm font-medium text-gray-700 mb-2") { "Title *" }
        input(
          type: "text",
          name: "seminar[title]",
          id: "seminar_title",
          value: seminar.title,
          required: true,
          class: input_classes(seminar.errors[:title].present?),
          placeholder: "e.g., Guard Passing Fundamentals with John Doe"
        )
        render_field_errors(seminar.errors[:title])
      end
      
      div do
        label(for: "seminar_description", class: "block text-sm font-medium text-gray-700 mb-2") { "Description" }
        textarea(
          name: "seminar[description]",
          id: "seminar_description",
          rows: 4,
          class: input_classes(seminar.errors[:description].present?),
          placeholder: "Describe what will be covered in the seminar..."
        ) { seminar.description }
        render_field_errors(seminar.errors[:description])
      end
    end
  end

  def datetime_section(form)
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Date & Time" }
      
      div do
        label(for: "seminar_starts_at", class: "block text-sm font-medium text-gray-700 mb-2") { "Start Date & Time *" }
        input(
          type: "datetime-local",
          name: "seminar[starts_at]",
          id: "seminar_starts_at",
          value: seminar.starts_at&.strftime("%Y-%m-%dT%H:%M"),
          required: true,
          class: input_classes(seminar.errors[:starts_at].present?)
        )
        render_field_errors(seminar.errors[:starts_at])
      end
    end
  end

  def location_section(form)
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Location" }
      
      div do
        label(for: "seminar_address", class: "block text-sm font-medium text-gray-700 mb-2") { "Address" }
        input(
          type: "text",
          name: "seminar[address]",
          id: "seminar_address",
          value: seminar.address,
          class: input_classes(seminar.errors[:address].present?),
          placeholder: "123 Main St, City, State, ZIP"
        )
        render_field_errors(seminar.errors[:address])
        p(class: "mt-1 text-sm text-gray-500") { "We'll use this to show location on maps and help people find your seminar" }
      end
    end
  end

  def instructors_section(form)
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Instructors" }
      
      div do
        label(class: "block text-sm font-medium text-gray-700 mb-2") { "Select Instructors" }
        div(class: "grid grid-cols-1 md:grid-cols-2 gap-3 max-h-64 overflow-y-auto border border-gray-300 rounded-md p-3") do
          players.each do |player|
            div(class: "flex items-center") do
              input(
                type: "checkbox",
                name: "seminar[player_ids][]",
                id: "player_#{player.id}",
                value: player.id,
                checked: seminar.players.include?(player),
                class: "h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
              )
              label(
                for: "player_#{player.id}",
                class: "ml-2 block text-sm text-gray-900"
              ) do
                "#{player.name} (#{player.team.name})"
              end
            end
          end
        end
        p(class: "mt-1 text-sm text-gray-500") { "Select the instructors who will be teaching this seminar" }
      end
    end
  end

  def additional_info_section(form)
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Additional Information" }
      
      div(class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
        div do
          label(for: "seminar_price", class: "block text-sm font-medium text-gray-700 mb-2") { "Price ($)" }
          input(
            type: "number",
            name: "seminar[price]",
            id: "seminar_price",
            value: seminar.price,
            min: 0,
            step: 0.01,
            class: input_classes(seminar.errors[:price].present?),
            placeholder: "0.00"
          )
          render_field_errors(seminar.errors[:price])
        end
        
        div do
          label(for: "seminar_max_participants", class: "block text-sm font-medium text-gray-700 mb-2") { "Max Participants" }
          input(
            type: "number",
            name: "seminar[max_participants]",
            id: "seminar_max_participants",
            value: seminar.max_participants,
            min: 1,
            class: input_classes(seminar.errors[:max_participants].present?),
            placeholder: "Leave blank for unlimited"
          )
          render_field_errors(seminar.errors[:max_participants])
        end
      end
    end
  end

  def form_actions(form)
    div(class: "flex justify-end space-x-3 pt-6 border-t border-gray-200") do
      render UI::ButtonComponent.new(
        href: seminar.persisted? ? seminar_path(seminar) : seminars_path,
        variant: "secondary"
      ) do
        "Cancel"
      end
      
      render UI::ButtonComponent.new(
        type: "submit",
        variant: "primary"
      ) do
        seminar.persisted? ? "Update Seminar" : "Create Seminar"
      end
    end
  end

  def render_errors
    div(class: "rounded-md bg-red-50 p-4 mb-6") do
      div(class: "flex") do
        div(class: "ml-3") do
          h3(class: "text-sm font-medium text-red-800") do
            "Please fix the following errors:"
          end
          div(class: "mt-2 text-sm text-red-700") do
            ul(class: "list-disc pl-5 space-y-1") do
              seminar.errors.full_messages.each do |message|
                li { message }
              end
            end
          end
        end
      end
    end
  end

  def render_field_errors(errors)
    return unless errors.present?

    div(class: "mt-1") do
      errors.each do |error|
        p(class: "text-sm text-red-600") { error }
      end
    end
  end

  def input_classes(has_error = false)
    base_classes = "mt-1 block w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
    
    if has_error
      "#{base_classes} border-red-300 text-red-900 placeholder-red-300 focus:ring-red-500 focus:border-red-500"
    else
      "#{base_classes} border-gray-300 text-gray-900 placeholder-gray-500"
    end
  end
end