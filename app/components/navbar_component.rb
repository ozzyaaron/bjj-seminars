class Components::NavbarComponent < Components::ApplicationComponent
  def template
    nav(class: "navbar navbar-expand-md navbar-dark bg-dark") do
      div(class: "container-fluid") do
        # Logo and brand
        link_to("/", class: "navbar-brand d-flex align-items-center") do
          div(class: "d-flex align-items-center") do
            # Logo placeholder
            div(class: "rounded bg-primary d-flex align-items-center justify-content-center me-2", style: "width: 2rem; height: 2rem;") do
              span(class: "text-white fw-bold small") { "BJJ" }
            end
            span(class: "text-white fw-semibold") { "Seminar Tracker" }
          end
        end

        # Mobile menu button
        button(
          type: "button",
          class: "navbar-toggler",
          "data-bs-toggle": "collapse",
          "data-bs-target": "#navbarNav"
        ) do
          span(class: "navbar-toggler-icon")
        end

        # Navigation
        div(class: "collapse navbar-collapse", id: "navbarNav") do
          ul(class: "navbar-nav me-auto") do
            nav_link_item("Seminars", "/seminars")
            nav_link_item("Players", "/players")
            nav_link_item("Teams", "/teams")
          end

          # User menu
          div(class: "d-flex align-items-center") do
            if user_signed_in?
              user_menu
            else
              guest_menu
            end
          end
        end
    end
  end

  private

  def nav_link_item(text, path)
    li(class: "nav-item") do
      link_to(path, class: css_classes(
        "nav-link",
        request.path == path ? "active" : ""
      )) do
        text
      end
    end
  end

  def user_menu
    div(class: "d-flex align-items-center gap-2") do
      # Notifications (if user has notification requests)
      if current_user.notification_requests.active.any?
        link_to(
          "/notifications",
          class: "btn btn-outline-light btn-sm"
        ) do
          # Bell icon
          svg(width: "16", height: "16", fill: "currentColor", viewbox: "0 0 24 24") do
            path(d: "M14.857 17.082a23.848 23.848 0 005.454-1.31A8.967 8.967 0 0118 9.75v-.7V9A6 6 0 006 9v.75a8.967 8.967 0 01-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 01-5.714 0m5.714 0a3 3 0 11-5.714 0")
          end
        end
      end

      # Create seminar button
      if current_user.can_create_seminar?
        link_to(
          "/seminars/new",
          class: "btn btn-primary btn-sm"
        ) { "Create Seminar" }
      end

      # User dropdown
      div(class: "dropdown") do
        button(
          class: "btn btn-dark dropdown-toggle d-flex align-items-center",
          "data-bs-toggle": "dropdown"
        ) do
          span { current_user.email }
        end

        ul(class: "dropdown-menu") do
          li { link_to("/profile", class: "dropdown-item") { "Profile" } }
          li { link_to("/my_seminars", class: "dropdown-item") { "My Seminars" } }
          li { link_to("/notifications", class: "dropdown-item") { "Notifications" } }
          
          if admin_user?
            li { hr(class: "dropdown-divider") }
            li { link_to("/admin", class: "dropdown-item") { "Admin" } }
          end
          
          li { hr(class: "dropdown-divider") }
          li {
            button_to(
              "/logout",
              method: :delete,
              class: "dropdown-item"
            ) { "Sign out" }
          }
        end
      end
    end
  end

  def guest_menu
    div(class: "d-flex align-items-center gap-2") do
      link_to("/login", class: "btn btn-outline-light btn-sm") { "Sign in" }
      link_to("/register", class: "btn btn-primary btn-sm") { "Sign up" }
    end
  end

end