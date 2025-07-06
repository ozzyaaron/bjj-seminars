Feature: Component Functionality
  As a user of the BJJ Seminar Tracker
  I want all pages to render correctly with their components
  So that I can navigate and use the application effectively

  Scenario: Seminars index page renders correctly
    Given there are seminars with instructors
    When I visit the seminars page
    Then I should see "BJJ Seminars" as the page heading
    And I should see seminar cards displaying seminar information
    And I should see search and filter options

  Scenario: Teams index page renders correctly
    Given there are teams with players
    When I visit the teams page
    Then I should see "BJJ Teams" as the page heading
    And I should see team cards with team information
    And I should see a search option for teams

  Scenario: Players index page renders correctly
    Given there are players in teams
    When I visit the players page
    Then I should see "BJJ Players" as the page heading
    And I should see player information with belt ranks
    And I should see filter options for teams and belt ranks

  Scenario: Authentication forms render correctly
    When I visit the login page
    Then I should see "Sign in to your account" heading
    And I should see email and password fields
    And I should see a "Sign in" button

    When I visit the registration page
    Then I should see "Create your account" heading
    And I should see email and password fields
    And I should see a "Create account" button

  Scenario: Seminar creation form renders for authenticated users
    Given I am signed in as a regular user
    When I visit the new seminar page
    Then I should see "Add New Seminar" as the page heading
    And I should see form sections for basic information, date & time, location, images, and instructors
    And I should see a "Create Seminar" button

  Scenario: Admin pages render for admin users
    Given I am signed in as an admin user
    When I visit the new team page
    Then I should see "Add New Team" as the page heading
    And I should see team creation form fields

    When I visit the new player page
    Then I should see "Add New Player" as the page heading
    And I should see player creation form fields including belt rank options