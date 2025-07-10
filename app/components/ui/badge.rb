class Components::UI::Badge < Components::ApplicationComponent
  def initialize(
    variant: :default,
    size: :base,
    **attributes
  )
    @variant = variant
    @size = size
    @attributes = attributes
  end

  def template(&block)
    span(class: badge_classes, **attributes, &block)
  end

  private

  attr_reader :variant, :size, :attributes

  def badge_classes
    css_classes(
      base_classes,
      variant_classes,
      size_classes
    )
  end

  def base_classes
    "inline-flex items-center font-medium rounded-full"
  end

  def variant_classes
    case variant
    when :default, :gray
      "bg-gray-100 text-gray-800"
    when :primary
      "bg-indigo-100 text-indigo-800"
    when :success
      "bg-green-100 text-green-800"
    when :warning
      "bg-yellow-100 text-yellow-800"
    when :danger
      "bg-red-100 text-red-800"
    when :info, :blue
      "bg-blue-100 text-blue-800"
    when :purple
      "bg-purple-100 text-purple-800"
    when :black
      "bg-gray-900 text-white"
    when :secondary
      "bg-blue-100 text-blue-800"
    else
      variant_classes(:default)
    end
  end

  def size_classes
    case size
    when :sm
      "px-2.5 py-0.5 text-xs"
    when :base
      "px-3 py-0.5 text-sm"
    when :lg
      "px-3 py-1 text-sm"
    else
      size_classes(:base)
    end
  end
end