require 'rails_helper'

RSpec.describe Components::Seminars::CardComponent, type: :component do
  subject(:component) { described_class.new(seminar: seminar, show_favorite: show_favorite) }
  
  let(:show_favorite) { true }
  let(:team) { create(:team) }
  let(:player) { create(:player, name: 'Gordon Ryan', team: team) }
  let(:user) { create(:user) }
  let(:seminar) do
    create(:seminar, 
      title: 'No-Gi Fundamentals',
      city: 'Los Angeles',
      state: 'CA',
      price: 200,
      seminar_type: 'No-Gi',
      starts_at: Time.current + 2.days,
      user: user
    ).tap { |s| s.players << player }
  end

  describe '#view_template' do
    let(:rendered) { component.view_template }

    it 'renders the card container with proper styling' do
      expect(rendered).to include('group bg-white rounded-xl')
      expect(rendered).to include('hover:shadow-lg transition-all duration-300')
      expect(rendered).to include('data-controller="seminar-card"')
    end

    it 'includes seminar title as a link' do
      expect(rendered).to include('No-Gi Fundamentals')
      expect(rendered).to include("href=\"#{Rails.application.routes.url_helpers.seminar_path(seminar)}\"")
    end

    it 'displays instructor information' do
      expect(rendered).to include('Gordon Ryan')
    end

    it 'shows location information' do
      expect(rendered).to include('Los Angeles, CA')
    end

    it 'displays price badge' do
      expect(rendered).to include('$200')
    end

    it 'shows seminar type badge' do
      expect(rendered).to include('NO-GI')
    end

    it 'includes action button' do
      expect(rendered).to include('View Details')
      expect(rendered).to include("href=\"#{Rails.application.routes.url_helpers.seminar_path(seminar)}\"")
    end
  end

  describe 'image section' do
    context 'when seminar has an image' do
      let(:seminar) { create(:seminar, user: user) }

      before do
        allow(seminar).to receive(:image).and_return(double(present?: true))
      end

      let(:rendered) { component.view_template }

      it 'renders the seminar image' do
        expect(rendered).to include('object-cover group-hover:scale-105')
      end
    end

    context 'when seminar has no image' do
      let(:rendered) { component.view_template }

      it 'renders placeholder image with icon' do
        expect(rendered).to include('bg-gradient-to-br from-blue-50 to-blue-100')
        expect(rendered).to include('<svg')
        expect(rendered).to include('w-16 h-16 text-blue-300')
      end
    end
  end

  describe 'favorite button' do
    context 'when show_favorite is true' do
      let(:rendered) { component.view_template }

      it 'renders favorite button' do
        expect(rendered).to include('data-action="click->seminar-card#toggleFavorite"')
        expect(rendered).to include("data-seminar-id=\"#{seminar.id}\"")
      end

      it 'includes heart icon' do
        expect(rendered).to include('<svg')
        expect(rendered).to include('w-5 h-5')
      end
    end

    context 'when show_favorite is false' do
      let(:show_favorite) { false }
      let(:rendered) { component.view_template }

      it 'does not render favorite button' do
        expect(rendered).not_to include('toggleFavorite')
      end
    end
  end

  describe 'instructor avatars' do
    context 'with single instructor' do
      let(:rendered) { component.view_template }

      it 'renders single avatar' do
        expect(rendered).to include('flex -space-x-2')
        expect(rendered).to include('w-8 h-8 rounded-full')
      end

      context 'when instructor has no image' do
        it 'renders initials avatar' do
          expect(rendered).to include('GR') # Gordon Ryan initials
        end
      end
    end

    context 'with multiple instructors' do
      let(:player2) { create(:player, name: 'Marcelo Garcia', team: team) }
      let(:player3) { create(:player, name: 'John Danaher', team: team) }
      let(:player4) { create(:player, name: 'Craig Jones', team: team) }

      before do
        seminar.players << [player2, player3, player4]
      end

      let(:rendered) { component.view_template }

      it 'renders multiple avatars with proper stacking' do
        expect(rendered).to include('-space-x-2')
        expect(rendered).to include('z-index:')
      end

      it 'shows overflow indicator for more than 3 instructors' do
        expect(rendered).to include('+1') # Should show +1 for the 4th instructor
      end

      it 'displays instructor names with overflow handling' do
        expect(rendered).to include('Gordon Ryan, Marcelo Garcia')
        expect(rendered).to include('+2 more')
      end
    end
  end

  describe 'date and time formatting' do
    context 'for today' do
      let(:seminar) { create(:seminar, starts_at: Time.current, user: user) }
      let(:rendered) { component.view_template }

      it 'shows "Today" with time' do
        expect(rendered).to include('Today,')
      end
    end

    context 'for tomorrow' do
      let(:seminar) { create(:seminar, starts_at: Time.current + 1.day, user: user) }
      let(:rendered) { component.view_template }

      it 'shows "Tomorrow" with time' do
        expect(rendered).to include('Tomorrow,')
      end
    end

    context 'for future date' do
      let(:seminar) { create(:seminar, starts_at: Time.current + 1.week, user: user) }
      let(:rendered) { component.view_template }

      it 'shows full date format' do
        expected_date = (Time.current + 1.week).strftime('%b %d, %Y at')
        expect(rendered).to include(expected_date)
      end
    end
  end

  describe 'price formatting' do
    context 'with positive price' do
      let(:seminar) { create(:seminar, price: 150, user: user) }
      let(:rendered) { component.view_template }

      it 'displays price with dollar sign' do
        expect(rendered).to include('$150')
      end
    end

    context 'with zero price' do
      let(:seminar) { create(:seminar, price: 0, user: user) }
      let(:rendered) { component.view_template }

      it 'displays "Free"' do
        expect(rendered).to include('Free')
      end
    end
  end

  describe 'seminar type badges' do
    context 'for Gi seminars' do
      let(:seminar) { create(:seminar, seminar_type: 'Gi', user: user) }
      let(:rendered) { component.view_template }

      it 'renders blue badge' do
        expect(rendered).to include('bg-blue-500/90 text-white')
        expect(rendered).to include('GI')
      end
    end

    context 'for No-Gi seminars' do
      let(:seminar) { create(:seminar, seminar_type: 'No-Gi', user: user) }
      let(:rendered) { component.view_template }

      it 'renders dark badge' do
        expect(rendered).to include('bg-gray-800/90 text-white')
        expect(rendered).to include('NO-GI')
      end
    end

    context 'for Both type seminars' do
      let(:seminar) { create(:seminar, seminar_type: 'Both', user: user) }
      let(:rendered) { component.view_template }

      it 'renders purple badge' do
        expect(rendered).to include('bg-purple-500/90 text-white')
        expect(rendered).to include('BOTH')
      end
    end
  end

  describe 'responsive design classes' do
    let(:rendered) { component.view_template }

    it 'includes responsive image aspect ratio' do
      expect(rendered).to include('aspect-[4/3]')
    end

    it 'includes proper text sizing and spacing' do
      expect(rendered).to include('text-lg font-semibold')
      expect(rendered).to include('line-clamp-2')
    end

    it 'includes responsive layout classes' do
      expect(rendered).to include('flex items-center')
      expect(rendered).to include('space-y-2')
    end
  end

  describe 'accessibility features' do
    let(:rendered) { component.view_template }

    it 'includes proper alt text for images' do
      expect(rendered).to include("alt=\"#{seminar.title}\"")
    end

    it 'includes focus states for interactive elements' do
      expect(rendered).to include('focus:ring-4 focus:ring-blue-300')
    end

    it 'includes proper button semantics' do
      expect(rendered).to include('type="button"')
    end
  end
end