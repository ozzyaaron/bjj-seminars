class Components::UI::Card < Components::ApplicationComponent
  def initialize(
    padding: :base,
    shadow: :base,
    border: true,
    background: :white,
    **attributes
  )
    @padding = padding
    @shadow = shadow
    @border = border
    @background = background
    @attributes = attributes
  end

  def template(&block)
    div(class: card_classes, **attributes, &block)
  end

  private

  attr_reader :padding, :shadow, :border, :background, :attributes

  def card_classes
    css_classes(
      base_classes,
      padding_classes,
      shadow_classes,
      border_classes,
      background_classes
    )
  end

  def base_classes
    "rounded-lg"
  end

  def padding_classes
    case padding
    when :none
      ""
    when :sm
      "p-4"
    when :base
      "p-6"
    when :lg
      "p-8"
    when :xl
      "p-12"
    else
      padding_classes(:base)
    end
  end

  def shadow_classes
    case shadow
    when :none
      ""
    when :sm
      "shadow-sm"
    when :base
      "shadow-md"
    when :lg
      "shadow-lg"
    when :xl
      "shadow-xl"
    else
      shadow_classes(:base)
    end
  end

  def border_classes
    border ? "border border-gray-200" : ""
  end

  def background_classes
    case background
    when :white
      "bg-white"
    when :gray
      "bg-gray-50"
    when :transparent
      ""
    else
      background_classes(:white)
    end
  end
end
