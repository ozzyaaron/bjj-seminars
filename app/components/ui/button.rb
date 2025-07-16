class Components::UI::Button < Components::ApplicationComponent
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
    "btn"
  end

  def variant_classes
    case variant
    when :primary
      "btn-primary"
    when :secondary
      "btn-secondary"
    when :success
      "btn-success"
    when :danger
      "btn-danger"
    when :warning
      "btn-warning"
    when :outline
      "btn-outline-primary"
    when :ghost
      "btn-outline-secondary"
    when :link
      "btn-link"
    else
      variant_classes(:primary)
    end
  end

  def size_classes
    case size
    when :xs
      "btn-sm"
    when :sm
      "btn-sm"
    when :base
      ""
    when :lg
      "btn-lg"
    when :xl
      "btn-lg"
    else
      size_classes(:base)
    end
  end

  def disabled_classes
    disabled ? "disabled" : ""
  end

  def confirmation_attributes
    confirm ? { "data-confirm": confirm } : {}
  end
end