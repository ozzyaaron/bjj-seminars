class ApplicationComponent < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::CSRF
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::ImageTag
  include Phlex::Rails::Helpers::TimeTag

  if Rails.env.development?
    def before_template
      comment { "#{self.class.name}" }
    end
  end

  private

  def current_user
    helpers.current_user
  end

  def user_signed_in?
    current_user.present?
  end

  def admin_user?
    current_user&.admin?
  end

  def css_classes(*classes)
    classes.compact.join(" ")
  end

  def conditional_classes(base_classes, conditional_hash = {})
    classes = [base_classes]
    conditional_hash.each do |condition, class_names|
      classes << class_names if condition
    end
    css_classes(*classes)
  end
end