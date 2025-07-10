module Components
  extend Phlex::Kit
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/components"), namespace: Components
)
