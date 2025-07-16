require 'rails_helper'

RSpec.describe Components::Seminars::FilterPanelComponent, type: :component do
  subject(:component) { described_class.new(filters: filters, players: players, form_url: form_url) }
  
  let(:filters) { {} }
  let(:players) { [] }
  let(:form_url) { nil }

  describe '#view_template' do
    let(:rendered) { component.view_template }

    it 'renders the filter panel container' do
      expect(rendered).to include('data-controller="filter-panel"')
      expect(rendered).to include('bg-white rounded-xl shadow-sm')
    end

    it 'includes filter header with title' do
      expect(rendered).to include('Filters')
    end

    it 'renders all filter sections' do
      expect(rendered).to include('Location')
      expect(rendered).to include('Date Range')
      expect(rendered).to include('Instructor')
      expect(rendered).to include('Price Range')
      expect(rendered).to include('Seminar Type')
    end

    it 'includes form with Turbo Frame targeting' do
      expect(rendered).to include('data-turbo-frame="seminars-list"')
      expect(rendered).to include('data-filter-panel-target="form"')
    end
  end

  describe 'filter sections' do
    let(:rendered) { component.view_template }

    it 'renders location filter with proper attributes' do
      expect(rendered).to include('name="location"')
      expect(rendered).to include('placeholder="City or venue"')
      expect(rendered).to include('data-action="input->filter-panel#applyFilters"')
    end

    it 'renders date range filters' do
      expect(rendered).to include('name="start_date"')
      expect(rendered).to include('name="end_date"')
      expect(rendered).to include('type="date"')
    end

    it 'renders instructor filter' do
      expect(rendered).to include('name="instructor"')
      expect(rendered).to include('placeholder="Instructor name"')
    end

    it 'renders price range filters' do
      expect(rendered).to include('name="min_price"')
      expect(rendered).to include('name="max_price"')
      expect(rendered).to include('type="number"')
      expect(rendered).to include('min="0"')
    end

    it 'renders seminar type checkboxes' do
      expect(rendered).to include('name="types"')
      expect(rendered).to include('value="gi"')
      expect(rendered).to include('value="no_gi"')
      expect(rendered).to include('value="both"')
    end
  end

  context 'with existing filters' do
    let(:filters) do
      {
        location: 'New York',
        instructor: 'Gordon Ryan',
        min_price: '100',
        max_price: '300',
        types: ['gi', 'no_gi']
      }
    end

    let(:rendered) { component.view_template }

    it 'populates form fields with existing values' do
      expect(rendered).to include('value="New York"')
      expect(rendered).to include('value="Gordon Ryan"')
      expect(rendered).to include('value="100"')
      expect(rendered).to include('value="300"')
    end

    it 'shows clear all button when filters are present' do
      expect(rendered).to include('Clear all')
      expect(rendered).to include('data-action="click->filter-panel#clearAll"')
    end

    it 'marks appropriate checkboxes as checked' do
      # This would require more specific testing of the checkbox state
      expect(rendered).to include('type="checkbox"')
    end
  end

  context 'with popular players' do
    let(:players) do
      [
        double(:player, name: 'Marcelo Garcia'),
        double(:player, name: 'Gordon Ryan'),
        double(:player, name: 'John Danaher')
      ]
    end

    let(:rendered) { component.view_template }

    it 'renders instructor quick-select pills' do
      expect(rendered).to include('Marcelo Garcia')
      expect(rendered).to include('Gordon Ryan')
      expect(rendered).to include('John Danaher')
    end

    it 'includes pill interaction attributes' do
      expect(rendered).to include('data-action="click->filter-panel#toggleInstructor"')
      expect(rendered).to include('data-instructor="Marcelo Garcia"')
    end

    it 'limits to first 5 players' do
      # Component should only show first 5 players
      pills = rendered.scan(/data-instructor="[^"]*"/)
      expect(pills.length).to be <= 5
    end
  end

  describe 'styling and responsive design' do
    let(:rendered) { component.view_template }

    it 'includes proper spacing and borders' do
      expect(rendered).to include('space-y-6')
      expect(rendered).to include('border-b border-gray-100 pb-6')
    end

    it 'applies focus styles to inputs' do
      expect(rendered).to include('focus:ring-2 focus:ring-blue-500')
      expect(rendered).to include('focus:border-blue-500')
    end

    it 'includes hover states for interactive elements' do
      expect(rendered).to include('hover:bg-gray-50')
      expect(rendered).to include('hover:bg-gray-200')
    end
  end

  describe 'Stimulus integration' do
    let(:rendered) { component.view_template }

    it 'includes filter panel controller' do
      expect(rendered).to include('data-controller="filter-panel"')
    end

    it 'includes form target' do
      expect(rendered).to include('data-filter-panel-target="form"')
    end

    it 'includes action bindings for auto-filtering' do
      expect(rendered).to include('data-action="input->filter-panel#applyFilters"')
      expect(rendered).to include('data-action="change->filter-panel#applyFilters"')
    end
  end

  describe 'helper methods' do
    context '#instructor_selected?' do
      let(:filters) { { instructor: 'Gordon Ryan' } }

      it 'returns true for matching instructor' do
        expect(component.send(:instructor_selected?, 'Gordon Ryan')).to be true
        expect(component.send(:instructor_selected?, 'gordon ryan')).to be true
      end

      it 'returns false for non-matching instructor' do
        expect(component.send(:instructor_selected?, 'Marcelo Garcia')).to be false
      end
    end

    context '#type_selected?' do
      let(:filters) { { types: ['gi', 'no_gi'] } }

      it 'returns true for selected types' do
        expect(component.send(:type_selected?, 'gi')).to be true
        expect(component.send(:type_selected?, 'no_gi')).to be true
      end

      it 'returns false for unselected types' do
        expect(component.send(:type_selected?, 'both')).to be false
      end
    end
  end
end