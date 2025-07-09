class Auth::RegistrationFormComponent < ApplicationComponent
  def initialize(user:, action_url: nil)
    @user = user
    @action_url = action_url
  end

  private

  attr_reader :user

  def action_url
    @action_url || user_registration_path
  end

  def view_template
    div(class: "min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8") do
      div(class: "max-w-md w-full space-y-8") do
        header_section
        form_section
        footer_section
      end
    end
  end

  def header_section
    div do
      h2(class: "mt-6 text-center text-3xl font-extrabold text-gray-900") do
        "Create your account"
      end
      p(class: "mt-2 text-center text-sm text-gray-600") do
        "Or "
        a(href: login_path, 
          class: "font-medium text-indigo-600 hover:text-indigo-500") do
          "sign in to existing account"
        end
      end
    end
  end

  def form_section
    form_with(model: user, url: action_url, local: true, class: "mt-8 space-y-6") do |form|
      render_errors if user.errors.any?

      div(class: "space-y-4") do
        div do
          label(for: "user_name", class: "block text-sm font-medium text-gray-700") { "Full name" }
          input(
            id: "user_name",
            name: "user[name]",
            type: "text",
            autocomplete: "name",
            required: true,
            value: user.name,
            class: input_classes(user.errors[:name].present?),
            placeholder: "Full name"
          )
          render_field_errors(user.errors[:name])
        end

        div do
          label(for: "user_email", class: "block text-sm font-medium text-gray-700") { "Email address" }
          input(
            id: "user_email", 
            name: "user[email]",
            type: "email",
            autocomplete: "email",
            required: true,
            value: user.email,
            class: input_classes(user.errors[:email].present?),
            placeholder: "Email address"
          )
          render_field_errors(user.errors[:email])
        end

        div do
          label(for: "user_password", class: "block text-sm font-medium text-gray-700") { "Password" }
          input(
            id: "user_password",
            name: "user[password]",
            type: "password",
            autocomplete: "new-password", 
            required: true,
            class: input_classes(user.errors[:password].present?),
            placeholder: "Password (minimum 8 characters)"
          )
          render_field_errors(user.errors[:password])
        end

        div do
          label(for: "user_password_confirmation", class: "block text-sm font-medium text-gray-700") { "Confirm password" }
          input(
            id: "user_password_confirmation",
            name: "user[password_confirmation]", 
            type: "password",
            autocomplete: "new-password",
            required: true,
            class: input_classes(user.errors[:password_confirmation].present?),
            placeholder: "Confirm password"
          )
          render_field_errors(user.errors[:password_confirmation])
        end
      end

      div do
        render Components::UI::Button.new(
          type: "submit",
          variant: "primary",
          size: "lg", 
          class: "group relative w-full flex justify-center"
        ) do
          "Create account"
        end
      end
    end
  end

  def footer_section
    div(class: "text-center") do
      p(class: "mt-2 text-xs text-gray-500") do
        "By creating an account, you agree to our terms of service and privacy policy."
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
              user.errors.full_messages.each do |message|
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
    base_classes = "mt-1 appearance-none relative block w-full px-3 py-2 border placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:z-10 sm:text-sm"
    
    if has_error
      "#{base_classes} border-red-300 focus:ring-red-500 focus:border-red-500"
    else
      "#{base_classes} border-gray-300 focus:ring-indigo-500 focus:border-indigo-500"
    end
  end
end