class Components::FooterComponent < Components::ApplicationComponent
  def template
    footer(class: "bg-gray-800 mt-12") do
      div(class: "mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8") do
        div(class: "grid grid-cols-1 md:grid-cols-3 gap-8") do
          # About section
          div do
            h3(class: "text-white font-semibold text-lg mb-4") { "BJJ Seminar Tracker" }
            p(class: "text-gray-400 text-sm") do
              plain "Find and create Brazilian Jiu-Jitsu seminars with world-class instructors. "
              plain "Connect with the global BJJ community and improve your skills."
            end
          end

          # Links section
          div do
            h3(class: "text-white font-semibold text-lg mb-4") { "Quick Links" }
            ul(class: "space-y-2") do
              li { link_to("Browse Seminars", "/seminars", class: "text-gray-400 hover:text-white text-sm") }
              li { link_to("Find Players", "/players", class: "text-gray-400 hover:text-white text-sm") }
              li { link_to("BJJ Teams", "/teams", class: "text-gray-400 hover:text-white text-sm") }
              if user_signed_in?
                li { link_to("Create Seminar", "/seminars/new", class: "text-gray-400 hover:text-white text-sm") }
              end
            end
          end

          # App info section
          div do
            h3(class: "text-white font-semibold text-lg mb-4") { "Mobile App" }
            p(class: "text-gray-400 text-sm mb-3") { "Install our PWA for the best mobile experience." }
            
            # PWA install prompt (hidden by default, shown by JavaScript)
            div(
              id: "pwa-install-prompt",
              class: "hidden",
              "data-controller": "pwa-install"
            ) do
              button(
                class: "bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded text-sm",
                "data-action": "click->pwa-install#install"
              ) { "Install App" }
            end
            
            # Social links placeholder
            div(class: "mt-4 flex space-x-4") do
              # GitHub link (placeholder)
              a(
                href: "#",
                class: "text-gray-400 hover:text-white",
                "aria-label": "GitHub"
              ) do
                svg(class: "h-5 w-5", fill: "currentColor", viewbox: "0 0 24 24") do
                  path(d: "M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z")
                end
              end
            end
          end
        end

        # Bottom section
        div(class: "border-t border-gray-700 mt-8 pt-8 flex flex-col md:flex-row justify-between items-center") do
          p(class: "text-gray-400 text-sm") do
            plain "&copy; #{Date.current.year} BJJ Seminar Tracker. Built with Ruby on Rails."
          end
          
          div(class: "mt-4 md:mt-0 flex space-x-6") do
            link_to("#", class: "text-gray-400 hover:text-white text-sm") { "Privacy" }
            link_to("#", class: "text-gray-400 hover:text-white text-sm") { "Terms" }
            link_to("#", class: "text-gray-400 hover:text-white text-sm") { "Contact" }
          end
        end
      end
    end
  end
end