Feature: User Management
  As a visitor to the BJJ Seminar Tracker
  I want to register, sign in, and manage my account
  So that I can create and manage seminars

  Scenario: User registration workflow
    Given I am on the registration page
    When I fill in "Email address" with "test@example.com"
    And I fill in "Password" with "password123"
    And I fill in "Confirm password" with "password123"
    And I click "Create account"
    Then I should be redirected to the home page
    And I should see "Welcome! Your account has been created successfully"
    And I should see "Sign out"
    And I should not see "Sign in"

  Scenario: User sign in workflow
    Given there is a user with email "user@example.com" and password "password123"
    And I am on the login page
    When I fill in "Email address" with "user@example.com"
    And I fill in "Password" with "password123"
    And I click "Sign in"
    Then I should be redirected to the home page
    And I should see "Signed in successfully"
    And I should see "Sign out"

  Scenario: Failed sign in with invalid credentials
    Given I am on the login page
    When I fill in "Email address" with "invalid@example.com"
    And I fill in "Password" with "wrongpassword"
    And I click "Sign in"
    Then I should remain on the login page
    And I should see "Invalid email or password"
    And I should see "Sign in"

  Scenario: User sign out workflow
    Given I am signed in as "user@example.com"
    And I am on the home page
    When I click "Sign out"
    Then I should be redirected to the home page
    And I should see "Signed out successfully"
    And I should see "Sign in"
    And I should not see "Sign out"

  Scenario: Invalid registration with missing fields
    Given I am on the registration page
    When I fill in "Email address" with ""
    And I fill in "Password" with "short"
    And I click "Create account"
    Then I should remain on the registration page
    And I should see "Email can't be blank"
    And I should see "Password is too short"

  Scenario: Invalid registration with existing email
    Given there is a user with email "existing@example.com"
    And I am on the registration page
    When I fill in "Email address" with "existing@example.com"
    And I fill in "Password" with "password123"
    And I click "Create account"
    Then I should remain on the registration page
    And I should see "Email has already been taken"

  Scenario: Access control for protected pages
    Given I am not signed in
    When I visit the new seminar page
    Then I should be redirected to the login page
    And I should see "You need to sign in to access this page"

  Scenario: Admin user has additional privileges
    Given I am signed in as an admin user
    When I visit the teams page
    Then I should see "Add New Team" button
    When I visit the players page
    Then I should see "Add New Player" button

  Scenario: Regular user does not see admin features
    Given I am signed in as a regular user
    When I visit the teams page
    Then I should not see "Add New Team" button
    When I visit the players page
    Then I should not see "Add New Player" button