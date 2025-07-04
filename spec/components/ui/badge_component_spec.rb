require 'rails_helper'

RSpec.describe UI::BadgeComponent, type: :component do
  describe 'rendering' do
    it 'renders badge with default variant' do
      component = UI::BadgeComponent.new(text: 'Test Badge')
      rendered = render_inline(component)
      
      expect(rendered.css('span').first[:class]).to include('inline-flex', 'items-center', 'px-2', 'py-1')
      expect(rendered.text).to include('Test Badge')
    end
    
    it 'renders badge with primary variant' do
      component = UI::BadgeComponent.new(text: 'Primary', variant: :primary)
      rendered = render_inline(component)
      
      expect(rendered.css('span').first[:class]).to include('bg-blue-100', 'text-blue-800')
    end
    
    it 'renders badge with success variant' do
      component = UI::BadgeComponent.new(text: 'Success', variant: :success)
      rendered = render_inline(component)
      
      expect(rendered.css('span').first[:class]).to include('bg-green-100', 'text-green-800')
    end
    
    it 'renders badge with warning variant' do
      component = UI::BadgeComponent.new(text: 'Warning', variant: :warning)
      rendered = render_inline(component)
      
      expect(rendered.css('span').first[:class]).to include('bg-yellow-100', 'text-yellow-800')
    end
    
    it 'renders badge with error variant' do
      component = UI::BadgeComponent.new(text: 'Error', variant: :error)
      rendered = render_inline(component)
      
      expect(rendered.css('span').first[:class]).to include('bg-red-100', 'text-red-800')
    end
    
    it 'renders badge with purple variant for belt ranks' do
      component = UI::BadgeComponent.new(text: 'Purple Belt', variant: :purple)
      rendered = render_inline(component)
      
      expect(rendered.css('span').first[:class]).to include('bg-purple-100', 'text-purple-800')
    end
    
    it 'renders badge with custom classes' do
      component = UI::BadgeComponent.new(text: 'Custom', classes: 'custom-class')
      rendered = render_inline(component)
      
      expect(rendered.css('span').first[:class]).to include('custom-class')
    end
  end
end