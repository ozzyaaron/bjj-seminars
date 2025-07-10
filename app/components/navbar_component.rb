class Components::NavbarComponent < Components::ApplicationComponent
  def template
    nav(class: "bg-gray-800") do
      div(class: "mx-auto max-w-7xl px-4 sm:px-6 lg:px-8") do
        div(class: "flex h-16 items-center justify-between") do
          # Logo and brand
          div(class: "flex items-center") do
            link_to("/", class: "flex-shrink-0") do
              div(class: "flex items-center") do
                # Logo placeholder
                div(class: "h-8 w-8 rounded bg-indigo-500 flex items-center justify-center") do
                  span(class: "text-white font-bold text-sm") { "BJJ" }
                end
                span(class: "ml-2 text-white font-semibold text-lg") { "Seminar Tracker" }
              end
            end

            # Desktop navigation
            div(class: "hidden md:block") do
              div(class: "ml-10 flex items-baseline space-x-4") do
                nav_link("Seminars", "/seminars")
                nav_link("Players", "/players")
                nav_link("Teams", "/teams")
              end
            end
          end

          # User menu
          div(class: "hidden md:block") do
            div(class: "ml-4 flex items-center md:ml-6") do
              if user_signed_in?
                user_menu
              else
                guest_menu
              end
            end
          end

          # Mobile menu button
          div(class: "-mr-2 flex md:hidden") do
            button(
              type: "button",
              class: "inline-flex items-center justify-center rounded-md bg-gray-800 p-2 text-gray-400 hover:bg-gray-700 hover:text-white",
              "data-controller": "mobile-menu",
              "data-action": "click->mobile-menu#toggle"
            ) do
              span(class: "sr-only") { "Open main menu" }
              # Hamburger icon
              svg(class: "h-6 w-6", fill: "none", viewbox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor") do
                path(stroke_linecap: "round", stroke_linejoin: "round", d: "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5")
              end
            end
          end
        end
      end

      # Mobile menu
      div(class: "md:hidden hidden", "data-mobile-menu-target": "menu") do
        div(class: "space-y-1 px-2 pb-3 pt-2 sm:px-3") do
          nav_link_mobile("Seminars", "/seminars")
          nav_link_mobile("Players", "/players")
          nav_link_mobile("Teams", "/teams")
        end
        
        div(class: "border-t border-gray-700 pb-3 pt-4") do
          if user_signed_in?
            mobile_user_menu
          else
            mobile_guest_menu
          end
        end
      end
    end
  end

  private

  def nav_link(text, path, active: false)
    active_class = active ? "bg-gray-900 text-white" : "text-gray-300 hover:bg-gray-700 hover:text-white"
    
    link_to(
      path,
      class: "#{active_class} rounded-md px-3 py-2 text-sm font-medium"
    ) { text }
  end

  def nav_link_mobile(text, path, active: false)
    active_class = active ? "bg-gray-900 text-white" : "text-gray-300 hover:bg-gray-700 hover:text-white"
    
    link_to(
      path,
      class: "#{active_class} block rounded-md px-3 py-2 text-base font-medium"
    ) { text }
  end

  def user_menu
    div(class: "flex items-center space-x-4") do
      # Notifications (if user has notification requests)
      if current_user.notification_requests.active.any?
        link_to(
          "/notifications",
          class: "text-gray-400 hover:text-white p-1 rounded-full hover:bg-gray-700"
        ) do
          # Bell icon
          svg(class: "h-6 w-6", fill: "none", viewbox: "0 0 24 24", stroke_width: "1.5", stroke: "currentColor") do
            path(stroke_linecap: "round", stroke_linejoin: "round", d: "M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75v-.7V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0")
          end
        end
      end

      # Create seminar button
      if current_user.can_create_seminar?
        link_to(
          "/seminars/new",
          class: "bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-2 rounded-md text-sm font-medium"
        ) { "Create Seminar" }
      end

      # User dropdown
      div(class: "relative", "data-controller": "dropdown") do
        button(
          class: "flex items-center text-sm rounded-full text-white hover:text-gray-300",
          "data-action": "click->dropdown#toggle"
        ) do
          span { current_user.email }
          # Chevron down
          svg(class: "ml-1 h-4 w-4", fill: "currentColor", viewbox: "0 0 20 20") do
            path(fill_rule: "evenodd", d: "M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z")
          end
        end

        div(
          class: "hidden absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50",
          "data-dropdown-target": "menu"
        ) do
          link_to("/profile", class: "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100") { "Profile" }
          link_to("/my_seminars", class: "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100") { "My Seminars" }
          link_to("/notifications", class: "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100") { "Notifications" }
          
          if admin_user?
            div(class: "border-t border-gray-100")
            link_to("/admin", class: "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100") { "Admin" }
          end
          
          div(class: "border-t border-gray-100")
          button_to(
            "/logout",
            method: :delete,
            class: "block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
          ) { "Sign out" }
        end
      end
    end
  end

  def guest_menu
    div(class: "flex items-center space-x-4") do
      link_to("/login", class: "text-gray-300 hover:text-white px-3 py-2 rounded-md text-sm font-medium") { "Sign in" }
      link_to("/register", class: "bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-2 rounded-md text-sm font-medium") { "Sign up" }
    end
  end

  def mobile_user_menu
    div(class: "flex items-center px-5") do
      div(class: "text-base font-medium leading-none text-white") { current_user.email }
    end
    div(class: "mt-3 space-y-1 px-2") do
      nav_link_mobile("Profile", "/profile")
      nav_link_mobile("My Seminars", "/my_seminars")
      nav_link_mobile("Notifications", "/notifications")
      
      if admin_user?
        nav_link_mobile("Admin", "/admin")
      end
      
      button_to(
        "/logout",
        method: :delete,
        class: "block w-full text-left text-gray-300 hover:bg-gray-700 hover:text-white rounded-md px-3 py-2 text-base font-medium"
      ) { "Sign out" }
    end
  end

  def mobile_guest_menu
    div(class: "mt-3 space-y-1 px-2") do
      nav_link_mobile("Sign in", "/login")
      nav_link_mobile("Sign up", "/register")
    end
  end
end