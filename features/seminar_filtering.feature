Feature: Seminar Discovery and Filtering
  As a visitor
  I want to discover and filter seminars using the modern search interface
  So that I can easily find relevant seminars near me or with specific instructors

  Background:
    Given the following teams exist:
      | name         |
      | Alliance     |
      | New Wave     |
      | Renzo Gracie |
    And the following players exist:
      | name           | rank        | team        |
      | Marcelo Garcia | Black Belt  | Alliance    |
      | Gordon Ryan    | Black Belt  | New Wave    |
      | John Danaher   | Black Belt  | Renzo Gracie|
    And the following seminars exist:
      | title                        | city          | address                    | player          | starts_at        | price | seminar_type |
      | Butterfly Guard Mastery      | New York      | 123 Main St, New York, NY  | Marcelo Garcia  | 2025-08-01 14:00 | 150   | Gi           |
      | No-Gi Fundamentals          | Los Angeles   | 456 Oak Ave, LA, CA        | Gordon Ryan     | 2025-08-15 10:00 | 200   | No-Gi        |
      | Submission Systems          | New York      | 789 5th Ave, New York, NY  | John Danaher    | 2025-09-01 09:00 | 250   | Both         |
      | Guard Passing Concepts      | Austin        | 321 6th St, Austin, TX     | Marcelo Garcia  | 2025-09-10 13:00 | 175   | Gi           |
      | Leg Lock Entries           | Los Angeles   | 654 Sunset Blvd, LA, CA    | Gordon Ryan     | 2025-09-20 11:00 | 225   | No-Gi        |

  Scenario: Hero search bar functionality
    When I visit the seminars page
    Then I should see the hero section with search
    And I should see "Find Your Next BJJ Seminar"
    And I should see a search input with placeholder text
    When I fill in the main search bar with "Gordon Ryan"
    And I submit the search
    Then I should see filtered results for "Gordon Ryan"

  Scenario: Filter panel is visible and functional
    When I visit the seminars page
    Then I should see the filter panel on the left sidebar
    And I should see filter sections for:
      | Location    |
      | Date Range  |
      | Instructor  |
      | Price Range |
      | Seminar Type|

  Scenario: Location filtering through filter panel
    Given I am on the seminars page
    When I fill in the location filter with "New York"
    Then the results should update automatically
    And I should see "Butterfly Guard Mastery"
    And I should see "Submission Systems"
    But I should not see "No-Gi Fundamentals"
    And I should not see "Guard Passing Concepts"
    And I should not see "Leg Lock Entries"

  Scenario: Price range filtering
    Given I am on the seminars page
    When I set the minimum price to "200"
    And I set the maximum price to "250"
    Then the results should update automatically
    And I should see "No-Gi Fundamentals"
    And I should see "Submission Systems"
    And I should see "Leg Lock Entries"
    But I should not see "Butterfly Guard Mastery"
    And I should not see "Guard Passing Concepts"

  Scenario: Seminar type filtering with checkboxes
    Given I am on the seminars page
    When I check the "No-Gi" seminar type filter
    Then the results should update automatically
    And I should see "No-Gi Fundamentals"
    And I should see "Leg Lock Entries"
    But I should not see "Butterfly Guard Mastery"
    And I should not see "Guard Passing Concepts"

  Scenario: Instructor quick-select pills
    Given I am on the seminars page
    And I should see instructor quick-select pills
    When I click on the "Marcelo Garcia" instructor pill
    Then the instructor filter should be filled with "Marcelo Garcia"
    And the results should update automatically
    And I should see "Butterfly Guard Mastery"
    And I should see "Guard Passing Concepts"

  Scenario: Clear all filters functionality
    Given I am on the seminars page
    And I have applied multiple filters:
      | filter_type | value        |
      | location    | New York     |
      | instructor  | John Danaher |
      | min_price   | 200          |
    When I click "Clear all" in the filter panel
    Then all filter inputs should be cleared
    And I should see all 5 seminars again

  Scenario: Results count display
    Given I am on the seminars page
    Then I should see "Showing all 5 seminars"
    When I apply a location filter for "Los Angeles"
    Then I should see "2 seminars found"

  Scenario: Seminar cards display key information
    When I visit the seminars page
    Then each seminar card should display:
      | Seminar title           |
      | Instructor avatars      |
      | Location                |
      | Date and time          |
      | Price badge            |
      | Seminar type badge     |
      | View Details button    |

  Scenario: Empty state with helpful message
    Given I am on the seminars page
    When I search for seminars in "Chicago"
    Then I should see "No seminars found matching your criteria"
    And I should see "Try adjusting your filters or search terms"
    And I should see a "Clear all filters" button

  Scenario: Grid view toggle (future feature)
    Given I am on the seminars page
    Then I should see view toggle buttons
    And the grid view should be active by default
    # Note: List view implementation would be future enhancement

  Scenario: Responsive design on mobile
    Given I am viewing on a mobile device
    When I visit the seminars page
    Then the filter panel should be hidden
    And the search bar should be full-width
    And seminar cards should stack vertically
    And I should see a mobile filter toggle button

  Scenario: Real-time search with debouncing
    Given I am on the seminars page
    When I start typing in the search field
    Then the search should not trigger immediately
    When I pause typing for a moment
    Then the search should execute automatically
    And results should update without page reload

  Scenario: Multiple filter combinations
    Given I am on the seminars page
    When I combine multiple filters:
      | filter_type  | value        |
      | location     | Los Angeles  |
      | seminar_type | No-Gi        |
      | max_price    | 220          |
    Then I should see "No-Gi Fundamentals"
    But I should not see "Leg Lock Entries"
    And I should not see any Gi seminars
    And I should not see any New York seminars