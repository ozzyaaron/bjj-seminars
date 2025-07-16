Feature: Home Page Discovery Experience
  As a potential BJJ practitioner
  I want an engaging home page that helps me discover seminars
  So that I can quickly find learning opportunities

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

  Scenario: Hero section displays compelling messaging
    When I visit the home page
    Then I should see the hero section with:
      | Train with the World's Best                                    |
      | Discover exclusive BJJ seminars with legendary instructors     |
      | Explore Seminars button                                        |

  Scenario: Hero search functionality
    When I visit the home page
    Then I should see a prominent search section
    And I should see "Find Your Perfect Seminar"
    And I should see a search input with placeholder "Where do you want to train? Who do you want to learn from?"
    When I fill in the hero search with "Marcelo Garcia"
    And I submit the search
    Then I should be redirected to the seminars page
    And I should see search results filtered by "Marcelo Garcia"

  Scenario: This Weekend collection with seminars
    Given there are upcoming seminars this weekend:
      | title                   | city        | player          | starts_at        |
      | Weekend Guard Workshop  | New York    | Marcelo Garcia  | 2025-07-19 10:00 |
      | No-Gi Competition Prep  | Los Angeles | Gordon Ryan     | 2025-07-20 14:00 |
    When I visit the home page
    Then I should see the "This Weekend" collection
    And I should see "Don't miss these upcoming seminars"
    And I should see "Weekend Guard Workshop"
    And I should see "No-Gi Competition Prep"
    And I should see "View All Seminars" button

  Scenario: Popular instructors carousel
    Given there are popular instructors with seminar history
    When I visit the home page
    Then I should see the "Popular Instructors" section
    And I should see "Learn from the legends of the sport"
    And I should see instructor cards with:
      | Avatar or initials |
      | Instructor name    |
      | Belt rank         |
    When I click on an instructor card
    Then I should be taken to their profile page

  Scenario: Empty state when no seminars exist
    Given there are no upcoming seminars
    When I visit the home page
    Then I should not see the "This Weekend" collection
    And I should still see the hero section
    And I should still see the search functionality

  Scenario: Call-to-action for unauthenticated users
    Given I am not signed in
    When I visit the home page
    Then I should see the CTA section
    And I should see "Ready to elevate your game?"
    And I should see "Join thousands of BJJ practitioners"
    And I should see "Create Free Account" button
    And I should see "Sign In" button

  Scenario: Authenticated user experience
    Given I am signed in as a regular user
    When I visit the home page
    Then I should see "Host a Seminar" button in the hero
    And I should not see the registration CTA section

  Scenario: Responsive design on mobile
    Given I am viewing on a mobile device
    When I visit the home page
    Then the hero section should be mobile-optimized
    And the search section should be full-width
    And the collections should stack vertically
    And instructor cards should be responsive

  Scenario: Featured seminars collection (when available)
    Given there are featured seminars:
      | title                  | city     | player        | featured |
      | Championship Seminar   | Austin   | John Danaher  | true     |
      | Elite Training Camp    | Miami    | Gordon Ryan   | true     |
    When I visit the home page
    Then I should see the "Featured Seminars" collection
    And I should see "Handpicked seminars with world-class instructors"
    And I should see "Championship Seminar"
    And I should see "Elite Training Camp"
    And I should see "View Featured" button

  Scenario: Navigation from home page elements
    Given there are upcoming seminars
    When I visit the home page
    And I click "Explore Seminars" in the hero
    Then I should be on the seminars page
    When I go back to the home page
    And I click "View All Seminars" in a collection
    Then I should be on the seminars page with all seminars shown

  Scenario: Visual hierarchy and design elements
    When I visit the home page
    Then I should see a gradient background in the hero
    And I should see proper spacing between sections
    And the search section should have a white background with shadow
    And collection titles should be prominently displayed
    And the CTA section should have a contrasting background