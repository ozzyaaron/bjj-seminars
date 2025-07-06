Feature: Home Page
  As a visitor to the BJJ Seminar Tracker
  I want to see an informative home page
  So that I can understand what the application offers

  Scenario: Visiting the home page as a guest
    When I visit the home page
    Then I should see the application title "BJJ Seminar Tracker"
    And I should see the tagline "Discover, track, and share Brazilian Jiu-Jitsu seminars"
    And I should see navigation links for "Seminars", "Teams", and "Players"
    And I should see "Sign in" and "Sign up" links
    And I should see a call-to-action section encouraging registration

  Scenario: Home page displays recent seminars
    Given there are upcoming seminars with instructors
    When I visit the home page
    Then I should see a "Recent Seminars" section
    And I should see seminar cards with titles and instructor information
    And I should see a "View All Seminars" link

  Scenario: Home page for signed-in users
    Given I am signed in as a regular user
    When I visit the home page
    Then I should see an "Add Seminar" button
    And I should see a "Sign out" link
    And I should not see the registration call-to-action section

  Scenario: Home page shows empty state when no seminars exist
    Given there are no upcoming seminars
    When I visit the home page
    Then I should not see a "Recent Seminars" section
    But I should still see the main application content and navigation