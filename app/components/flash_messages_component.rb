class Components::FlashMessagesComponent < Components::ApplicationComponent
  def template
    return unless flash.any?

    div(class: "fixed top-4 right-4 z-50 space-y-2", "data-controller": "flash") do
      flash.each do |type, message|
        div(
          class: flash_classes(type),
          "data-flash-target": "message",
          "data-action": "click->flash#dismiss"
        ) do
          div(class: "flex items-center") do
            # Icon
            div(class: "flex-shrink-0") do
              case type.to_s
              when "notice", "success"
                success_icon
              when "alert", "error"
                error_icon
              when "warning"
                warning_icon
              else
                info_icon
              end
            end

            # Message
            div(class: "ml-3") do
              p(class: "text-sm font-medium") { message }
            end

            # Dismiss button
            div(class: "ml-auto pl-3") do
              div(class: "-mx-1.5 -my-1.5") do
                button(
                  type: "button",
                  class: "inline-flex rounded-md p-1.5 focus:outline-none focus:ring-2 focus:ring-offset-2 #{dismiss_button_classes(type)}",
                  "data-action": "click->flash#dismiss"
                ) do
                  span(class: "sr-only") { "Dismiss" }
                  # X icon
                  svg(class: "h-5 w-5", viewbox: "0 0 20 20", fill: "currentColor") do
                    path(d: "M6.28 5.22a.75.75 0 00-1.06 1.06L8.94 10l-3.72 3.72a.75.75 0 101.06 1.06L10 11.06l3.72 3.72a.75.75 0 101.06-1.06L11.06 10l3.72-3.72a.75.75 0 00-1.06-1.06L10 8.94 6.28 5.22z")
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  private

  def flash
    helpers.flash
  end

  def flash_classes(type)
    base_classes = "pointer-cursor rounded-md p-4 shadow-lg max-w-sm w-full transition-all duration-300"
    
    case type.to_s
    when "notice", "success"
      "#{base_classes} bg-green-50 border border-green-200"
    when "alert", "error"
      "#{base_classes} bg-red-50 border border-red-200"
    when "warning"
      "#{base_classes} bg-yellow-50 border border-yellow-200"
    else
      "#{base_classes} bg-blue-50 border border-blue-200"
    end
  end

  def dismiss_button_classes(type)
    case type.to_s
    when "notice", "success"
      "text-green-400 hover:text-green-600 focus:ring-green-600"
    when "alert", "error"
      "text-red-400 hover:text-red-600 focus:ring-red-600"
    when "warning"
      "text-yellow-400 hover:text-yellow-600 focus:ring-yellow-600"
    else
      "text-blue-400 hover:text-blue-600 focus:ring-blue-600"
    end
  end

  def success_icon
    svg(class: "h-5 w-5 text-green-400", viewbox: "0 0 20 20", fill: "currentColor") do
      path(fill_rule: "evenodd", d: "M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.236 4.53L8.53 10.53a.75.75 0 00-1.06 1.061l2.03 2.03a.75.75 0 001.137-.089l3.857-5.401z")
    end
  end

  def error_icon
    svg(class: "h-5 w-5 text-red-400", viewbox: "0 0 20 20", fill: "currentColor") do
      path(fill_rule: "evenodd", d: "M10 18a8 8 0 100-16 8 8 0 000 16zM8.28 7.22a.75.75 0 00-1.06 1.06L8.94 10l-1.72 1.72a.75.75 0 101.06 1.06L10 11.06l1.72 1.72a.75.75 0 101.06-1.06L11.06 10l1.72-1.72a.75.75 0 00-1.06-1.06L10 8.94 8.28 7.22z")
    end
  end

  def warning_icon
    svg(class: "h-5 w-5 text-yellow-400", viewbox: "0 0 20 20", fill: "currentColor") do
      path(fill_rule: "evenodd", d: "M8.485 2.495c.673-1.167 2.357-1.167 3.03 0l6.28 10.875c.673 1.167-.17 2.625-1.516 2.625H3.72c-1.347 0-2.19-1.458-1.515-2.625L8.485 2.495zM10 5a.75.75 0 01.75.75v3.5a.75.75 0 01-1.5 0v-3.5A.75.75 0 0110 5zm0 9a1 1 0 100-2 1 1 0 000 2z")
    end
  end

  def info_icon
    svg(class: "h-5 w-5 text-blue-400", viewbox: "0 0 20 20", fill: "currentColor") do
      path(fill_rule: "evenodd", d: "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a.75.75 0 000 1.5h.253a.25.25 0 01.244.304l-.459 2.066A1.75 1.75 0 0010.747 15H11a.75.75 0 000-1.5h-.253a.25.25 0 01-.244-.304l.459-2.066A1.75 1.75 0 009.253 9H9z")
    end
  end
end