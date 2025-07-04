class RateLimitsInfoComponent < ApplicationComponent
  def view_template
    render UI::CardComponent.new do
      div(class: "p-6") do
        h2(class: "text-2xl font-bold text-gray-900 mb-4") { "Rate Limits & Fair Usage" }
        
        div(class: "prose max-w-none") do
          p(class: "text-gray-700 mb-4") do
            "To ensure fair usage and prevent abuse, we have implemented the following rate limits:"
          end
          
          rate_limits_list
          
          div(class: "mt-6 p-4 bg-blue-50 rounded-md") do
            h3(class: "text-lg font-semibold text-blue-900 mb-2") { "Why Rate Limits?" }
            p(class: "text-blue-800 text-sm") do
              "Rate limits help us maintain a high-quality service for all users by preventing spam, " \
              "protecting against abuse, and ensuring our servers remain responsive. These limits " \
              "are generous for normal usage and should not affect legitimate users."
            end
          end
          
          admin_info if admin_user?
        end
      end
    end
  end

  private

  def rate_limits_list
    ul(class: "space-y-3 text-gray-700") do
      li(class: "flex items-start") do
        limit_icon
        div(class: "ml-3") do
          strong { "Account Creation: " }
          span { "1 account per IP address per day" }
        end
      end
      
      li(class: "flex items-start") do
        limit_icon
        div(class: "ml-3") do
          strong { "Seminar Creation: " }
          span { "25 seminars per user per day" }
        end
      end
      
      li(class: "flex items-start") do
        limit_icon
        div(class: "ml-3") do
          strong { "Login Attempts: " }
          span { "5 attempts per IP per hour, 3 attempts per email per hour" }
        end
      end
      
      li(class: "flex items-start") do
        limit_icon
        div(class: "ml-3") do
          strong { "Image Uploads: " }
          span { "Maximum 10 images per seminar, 5MB per image" }
        end
      end
      
      li(class: "flex items-start") do
        limit_icon
        div(class: "ml-3") do
          strong { "General Requests: " }
          span { "300 requests per IP per hour" }
        end
      end
    end
  end

  def admin_info
    div(class: "mt-6 p-4 bg-green-50 rounded-md") do
      h3(class: "text-lg font-semibold text-green-900 mb-2") { "Admin Privileges" }
      p(class: "text-green-800 text-sm") do
        "As an administrator, you have elevated rate limits and can manage teams and players. " \
        "Please use these privileges responsibly."
      end
    end
  end

  def limit_icon
    div(class: "flex-shrink-0 mt-0.5") do
      svg(class: "w-4 h-4 text-indigo-500", fill: "currentColor", viewBox: "0 0 20 20") do |s|
        s.path(
          fill_rule: "evenodd",
          d: "M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z",
          clip_rule: "evenodd"
        )
      end
    end
  end
end