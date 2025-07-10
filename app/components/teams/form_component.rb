class Components::Teams::FormComponent < Components::ApplicationComponent
  def initialize(team:, action_url: nil)
    @team = team
    @action_url = action_url || (team.persisted? ? team_path(team) : teams_path)
  end

  private

  attr_reader :team, :action_url

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
              team.persisted? ? "Edit Team" : "Add New Team"
            end
            p(class: "mt-2 text-sm text-gray-600") do
              "Manage BJJ team information and details"
            end
          end
          
          render Components::UI::Button.new(
            href: team.persisted? ? team_path(team) : teams_path,
            variant: "secondary"
          ) do
            "Cancel"
          end
        end
      end
    end
  end

  def form_content
    div(class: "max-w-2xl mx-auto py-8 px-4 sm:px-6 lg:px-8") do
      render Components::UI::Card.new do
        div(class: "p-6") do
          render_errors if team.errors.any?
          
          form_with(model: team, url: action_url, local: true, class: "space-y-6") do |form|
            basic_info_section
            contact_info_section
            description_section
            form_actions
          end
        end
      end
    end
  end

  def basic_info_section
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Basic Information" }
      
      div do
        label(for: "team_name", class: "block text-sm font-medium text-gray-700 mb-2") { "Team Name *" }
        input(
          type: "text",
          name: "team[name]",
          id: "team_name",
          value: team.name,
          required: true,
          class: input_classes(team.errors[:name].present?),
          placeholder: "e.g., Gracie Barra, Alliance BJJ"
        )
        render_field_errors(team.errors[:name])
      end
      
      div do
        label(for: "team_location", class: "block text-sm font-medium text-gray-700 mb-2") { "Location" }
        input(
          type: "text",
          name: "team[location]",
          id: "team_location",
          value: team.location,
          class: input_classes(team.errors[:location].present?),
          placeholder: "e.g., Los Angeles, CA"
        )
        render_field_errors(team.errors[:location])
      end
    end
  end

  def contact_info_section
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Contact Information" }
      
      div do
        label(for: "team_website", class: "block text-sm font-medium text-gray-700 mb-2") { "Website" }
        input(
          type: "url",
          name: "team[website]",
          id: "team_website",
          value: team.website,
          class: input_classes(team.errors[:website].present?),
          placeholder: "https://example.com"
        )
        render_field_errors(team.errors[:website])
        p(class: "mt-1 text-sm text-gray-500") { "Optional: Team website or social media page" }
      end
    end
  end

  def description_section
    div(class: "space-y-4") do
      h2(class: "text-lg font-semibold text-gray-900") { "Description" }
      
      div do
        label(for: "team_description", class: "block text-sm font-medium text-gray-700 mb-2") { "About the Team" }
        textarea(
          name: "team[description]",
          id: "team_description",
          rows: 4,
          class: input_classes(team.errors[:description].present?),
          placeholder: "Tell us about the team's history, philosophy, and what makes it special..."
        ) { team.description }
        render_field_errors(team.errors[:description])
      end
    end
  end

  def form_actions
    div(class: "flex justify-end space-x-3 pt-6 border-t border-gray-200") do
      render Components::UI::Button.new(
        href: team.persisted? ? team_path(team) : teams_path,
        variant: "secondary"
      ) do
        "Cancel"
      end
      
      render Components::UI::Button.new(
        type: "submit",
        variant: "primary"
      ) do
        team.persisted? ? "Update Team" : "Create Team"
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
              team.errors.full_messages.each do |message|
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