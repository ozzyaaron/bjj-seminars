class Auth::LoginFormComponent < ApplicationComponent
  def initialize(action_url: login_path)
    @action_url = action_url
  end

  private

  attr_reader :action_url

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
        "Sign in to your account"
      end
      p(class: "mt-2 text-center text-sm text-gray-600") do
        "Or "
        a(href: new_user_registration_path, 
          class: "font-medium text-indigo-600 hover:text-indigo-500") do
          "create a new account"
        end
      end
    end
  end

  def form_section
    form_with(url: action_url, local: true, class: "mt-8 space-y-6") do |form|
      div(class: "space-y-4") do
        div do
          label(for: "email", class: "block text-sm font-medium text-gray-700") { "Email address" }
          input(
            id: "email",
            name: "email", 
            type: "email",
            autocomplete: "email",
            required: true,
            class: "mt-1 appearance-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm",
            placeholder: "Email address"
          )
        end

        div do
          label(for: "password", class: "block text-sm font-medium text-gray-700") { "Password" }
          input(
            id: "password",
            name: "password",
            type: "password", 
            autocomplete: "current-password",
            required: true,
            class: "mt-1 appearance-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 focus:z-10 sm:text-sm",
            placeholder: "Password"
          )
        end
      end

      div do
        render UI::Button.new(
          type: "submit",
          variant: "primary", 
          size: "lg",
          class: "group relative w-full flex justify-center"
        ) do
          "Sign in"
        end
      end
    end
  end

  def footer_section
    div(class: "text-center") do
      p(class: "mt-2 text-xs text-gray-500") do
        "By signing in, you agree to our terms of service and privacy policy."
      end
    end
  end
end