require 'rails_helper'

RSpec.describe Seminars::CardComponent, type: :component do
  let(:user) { create(:user) }
  let(:seminar) { create(:seminar, user: user) }
  
  describe 'rendering' do
    it 'renders seminar card with basic information' do
      component = Seminars::CardComponent.new(seminar: seminar)
      rendered = render_inline(component)
      
      expect(rendered.text).to include(seminar.title)
      expect(rendered.text).to include(seminar.instructor_name)
      expect(rendered.text).to include(seminar.venue)
      expect(rendered.text).to include(seminar.location)
    end
    
    it 'renders seminar date and price' do
      component = Seminars::CardComponent.new(seminar: seminar)
      rendered = render_inline(component)
      
      expect(rendered.text).to include(seminar.seminar_date.strftime('%B %d, %Y'))
      expect(rendered.text).to include(seminar.formatted_price)
    end
    
    it 'renders belt rank badge' do
      component = Seminars::CardComponent.new(seminar: seminar)
      rendered = render_inline(component)
      
      expect(rendered.text).to include(seminar.instructor_belt.titleize)
    end
    
    it 'shows image when seminar has images' do
      seminar.images.attach(
        io: StringIO.new('fake image'),
        filename: 'test.jpg',
        content_type: 'image/jpeg'
      )
      
      component = Seminars::CardComponent.new(seminar: seminar)
      rendered = render_inline(component)
      
      expect(rendered.css('img')).to be_present
    end
    
    it 'does not show image when seminar has no images' do
      component = Seminars::CardComponent.new(seminar: seminar)
      rendered = render_inline(component)
      
      expect(rendered.css('img')).to be_empty
    end
    
    it 'renders link to seminar show page' do
      component = Seminars::CardComponent.new(seminar: seminar)
      rendered = render_inline(component)
      
      expect(rendered.css("a[href='#{seminar_path(seminar)}']")).to be_present
    end
  end
end