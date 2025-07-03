class ApplicationLayout < ApplicationComponent
  include Phlex::Rails::Layout

  def initialize(title: "BJJ Seminar Tracker")
    @title = title
  end

  def template(&block)
    doctype

    html(lang: "en", class: "h-full bg-gray-50") do
      head do
        meta(charset: "utf-8")
        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        csrf_meta_tags
        csp_meta_tag

        title { [@title, "BJJ Seminar Tracker"].compact.join(" - ") }

        # PWA meta tags
        meta(name: "theme-color", content: "#1f2937")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "apple-mobile-web-app-status-bar-style", content: "default")
        meta(name: "apple-mobile-web-app-title", content: "BJJ Seminars")

        # Preconnect to external domains
        link(rel: "preconnect", href: "https://fonts.googleapis.com")
        link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true)

        # Stylesheets
        link(rel: "stylesheet", href: "/assets/application.tailwind.css", "data-turbo-track": "reload")
        link(rel: "stylesheet", href: "/assets/application.css", "data-turbo-track": "reload")

        # JavaScript
        script(src: "/assets/application.js", "data-turbo-track": "reload", defer: true)
      end

      body(class: "h-full") do
        div(class: "min-h-full") do
          render NavbarComponent.new
          
          main do
            render FlashMessagesComponent.new if flash.any?
            yield_content(&block)
          end
          
          render FooterComponent.new
        end

        # Service worker registration
        if Rails.env.production?
          script do
            raw <<~JS
              if ('serviceWorker' in navigator) {
                navigator.serviceWorker.register('/service-worker.js');
              }
            JS
          end
        end
      end
    end
  end

  private

  attr_reader :title

  def flash
    helpers.flash
  end
end