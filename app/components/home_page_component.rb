class HomePageComponent < ApplicationComponent
  def initialize(recent_seminars:)
    @recent_seminars = recent_seminars
  end

  private

  attr_reader :recent_seminars

  def view_template
    div(class: "min-h-screen bg-gray-50") do
      hero_section
      recent_seminars_section if recent_seminars.any?
      cta_section unless user_signed_in?
    end
  end

  def hero_section
    div(class: "bg-white") do
      div(class: "max-w-7xl mx-auto py-16 px-4 sm:py-24 sm:px-6 lg:px-8") do
        div(class: "text-center") do
          h1(class: "text-4xl font-extrabold text-gray-900 sm:text-5xl md:text-6xl") do
            span(class: "block") { "BJJ Seminar" }
            span(class: "block text-indigo-600") { "Tracker" }
          end
          p(class: "mt-3 max-w-md mx-auto text-base text-gray-500 sm:text-lg md:mt-5 md:text-xl md:max-w-3xl") do
            "Discover, track, and share Brazilian Jiu-Jitsu seminars with world-class instructors. Find seminars near you and connect with the BJJ community."
          end

          if user_signed_in?
            div(class: "mt-5 max-w-md mx-auto sm:flex sm:justify-center md:mt-8") do
              render Components::UI::Button.new(
                href: new_seminar_path,
                variant: "primary",
                size: "lg",
                class: "w-full sm:w-auto"
              ) do
                "Add Seminar"
              end
            end
          end
        end
      end
    end
  end

  def recent_seminars_section
    div(class: "max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8") do
      div(class: "lg:text-center mb-12") do
        h2(class: "text-base text-indigo-600 font-semibold tracking-wide uppercase") { "Upcoming" }
        p(class: "mt-2 text-3xl leading-8 font-extrabold tracking-tight text-gray-900 sm:text-4xl") do
          "Recent Seminars"
        end
        p(class: "mt-4 max-w-2xl text-xl text-gray-500 lg:mx-auto") do
          "Discover the latest BJJ seminars happening around the world"
        end
      end

      div(class: "grid gap-6 sm:grid-cols-2 lg:grid-cols-3") do
        recent_seminars.each do |seminar|
          render Components::SeminarCardComponent.new(seminar: seminar)
        end
      end

      div(class: "mt-8 text-center") do
        render Components::UI::Button.new(
          href: seminars_path,
          variant: "secondary"
        ) do
          "View All Seminars"
        end
      end
    end
  end

  def cta_section
    div(class: "bg-indigo-700") do
      div(class: "max-w-2xl mx-auto text-center py-16 px-4 sm:py-20 sm:px-6 lg:px-8") do
        h2(class: "text-3xl font-extrabold text-white sm:text-4xl") do
          span(class: "block") { "Ready to start tracking?" }
          span(class: "block") { "Join the community today." }
        end
        p(class: "mt-4 text-lg leading-6 text-indigo-200") do
          "Create your account and start discovering amazing BJJ seminars in your area."
        end
        div(class: "mt-8 flex justify-center space-x-4") do
          render Components::UI::Button.new(
            href: new_user_registration_path,
            variant: "primary",
            class: "bg-white text-indigo-600 hover:bg-gray-50"
          ) do
            "Get started"
          end
          render Components::UI::Button.new(
            href: login_path,
            variant: "secondary",
            class: "border-white text-white hover:bg-indigo-600"
          ) do
            "Sign in"
          end
        end
      end
    end
  end
end
