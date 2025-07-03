class UI::Button < ApplicationComponent
  def initialize(
    variant: :primary,
    size: :base,
    href: nil,
    method: nil,
    confirm: nil,
    disabled: false,
    type: "button",
    **attributes
  )
    @variant = variant
    @size = size
    @href = href
    @method = method
    @confirm = confirm
    @disabled = disabled
    @type = type
    @attributes = attributes
  end

  def template(&block)
    if href
      link_element(&block)
    else
      button_element(&block)
    end
  end

  private

  attr_reader :variant, :size, :href, :method, :confirm, :disabled, :type, :attributes

  def link_element(&block)
    if method && method != :get
      button_to(
        href,
        method: method,
        confirm: confirm,
        disabled: disabled,
        class: button_classes,
        **attributes,
        &block
      )
    else
      link_to(
        href,
        class: button_classes,
        **attributes,
        &block
      )
    end
  end

  def button_element(&block)
    button(
      type: type,
      disabled: disabled,
      class: button_classes,
      **confirmation_attributes,
      **attributes,
      &block
    )
  end

  def button_classes
    css_classes(
      base_classes,
      variant_classes,
      size_classes,
      disabled_classes
    )
  end

  def base_classes
    "inline-flex items-center justify-center font-medium rounded-lg transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2"
  end

  def variant_classes
    case variant
    when :primary
      "bg-indigo-600 text-white hover:bg-indigo-700 focus:ring-indigo-500"
    when :secondary
      "bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500"
    when :success
      "bg-green-600 text-white hover:bg-green-700 focus:ring-green-500"
    when :danger
      "bg-red-600 text-white hover:bg-red-700 focus:ring-red-500"
    when :warning
      "bg-yellow-600 text-white hover:bg-yellow-700 focus:ring-yellow-500"
    when :outline
      "border border-gray-300 bg-white text-gray-700 hover:bg-gray-50 focus:ring-indigo-500"
    when :ghost
      "text-gray-700 hover:bg-gray-100 focus:ring-gray-500"
    when :link
      "text-indigo-600 hover:text-indigo-500 focus:ring-indigo-500"
    else
      variant_classes(:primary)
    end
  end

  def size_classes
    case size
    when :xs
      "px-2.5 py-1.5 text-xs"
    when :sm
      "px-3 py-2 text-sm"
    when :base
      "px-4 py-2 text-sm"
    when :lg
      "px-4 py-2 text-base"
    when :xl
      "px-6 py-3 text-base"
    else
      size_classes(:base)
    end
  end

  def disabled_classes
    if disabled
      "opacity-50 cursor-not-allowed"
    else
      "cursor-pointer"
    end
  end

  def confirmation_attributes
    confirm ? { "data-confirm": confirm } : {}
  end
end