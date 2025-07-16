require 'rails_helper'

RSpec.describe Components::Seminars::SearchBarComponent, type: :request do
  describe 'component rendering' do
    let(:search_params) { {} }
    let(:placeholder) { "Search seminars..." }
    let(:form_url) { nil }

    # Create a minimal test controller to render the component
    controller(ApplicationController) do
      def test_search_bar
        @component = Components::Seminars::SearchBarComponent.new(
          search_params: params[:search_params] || {},
          placeholder: params[:placeholder] || "Search seminars...",
          form_url: params[:form_url]
        )
        render inline: "<%= render @component %>"
      end
    end

    before do
      routes.draw { get 'test_search_bar' => 'anonymous#test_search_bar' }
    end

    it 'renders a form with search functionality' do
      get :test_search_bar
      
      expect(response).to have_http_status(:success)
      expect(response.body).to include('form')
      expect(response.body).to include('method="get"')
      expect(response.body).to include('data-controller="search"')
    end

    it 'includes search input with correct attributes' do
      get :test_search_bar
      
      expect(response.body).to include('type="text"')
      expect(response.body).to include('name="search"')
      expect(response.body).to include('Search seminars...')
      expect(response.body).to include('data-search-target="input"')
    end

    it 'includes search icon' do
      get :test_search_bar
      
      expect(response.body).to include('<svg')
      expect(response.body).to include('h-5 w-5')
    end

    context 'with search params' do
      it 'populates the input with existing search value' do
        get :test_search_bar, params: { search_params: { search: 'Gordon Ryan' } }
        
        expect(response.body).to include('value="Gordon Ryan"')
      end
    end

    context 'with custom placeholder' do
      it 'uses the custom placeholder text' do
        get :test_search_bar, params: { placeholder: "Find your perfect seminar..." }
        
        expect(response.body).to include('placeholder="Find your perfect seminar..."')
      end
    end

    it 'applies responsive styling classes' do
      get :test_search_bar
      
      expect(response.body).to include('focus:ring-2')
      expect(response.body).to include('hover:shadow-md')
      expect(response.body).to include('rounded-xl')
    end

    it 'includes accessibility features' do
      get :test_search_bar
      
      expect(response.body).to include('autocomplete="off"')
      expect(response.body).to include('focus:border-blue-500')
    end
  end
end