Feature: User Authentication
  As a visitor
  I want to register and login
  So that I can create and manage seminars

  Background:
    Given the following teams exist:
      | name          |
      | Gracie Barra  |
      | Alliance      |
      | Atos         |
    And the following players exist:
      | name           | rank        | team         |
      | Roger Gracie   | Black Belt  | Gracie Barra |
      | Marcus Almeida | Black Belt  | Alliance     |
      | Andre Galvao   | Black Belt  | Atos         |

  Scenario: User registration with valid information
    Given I am on the signup page
    When I fill in "user_name" with "John Smith"
    And I fill in "user_email" with "john@example.com"
    And I fill in "user_password" with "password123"
    And I fill in "user_password_confirmation" with "password123"
    And I click "Create account"
    Then I should be redirected to the home page
    And I should see "Welcome, John Smith"
    And I should see "Add Seminar"

  Scenario: User registration with invalid information
    Given I am on the signup page
    When I fill in "user_name" with ""
    And I fill in "user_email" with "invalid-email"
    And I fill in "user_password" with "short"
    And I fill in "user_password_confirmation" with "different"
    And I click "Create account"
    Then I should remain on the signup page
    And I should see "Name can't be blank"
    And I should see "Email is invalid"
    And I should see "Password is too short"
    And I should see "Password confirmation doesn't match"

  Scenario: User registration with duplicate email
    Given a user exists with email "john@example.com"
    And I am on the signup page
    When I fill in "user_name" with "John Doe"
    And I fill in "user_email" with "john@example.com"
    And I fill in "user_password" with "password123"
    And I fill in "user_password_confirmation" with "password123"
    And I click "Create account"
    Then I should remain on the signup page
    And I should see "Email has already been taken"

  Scenario: User login with valid credentials
    Given I have an account with email "john@example.com" and password "password123"
    And I am on the login page
    When I fill in "email" with "john@example.com"
    And I fill in "password" with "password123"
    And I click "Sign in"
    Then I should be redirected to the home page
    And I should see "Welcome back"
    And I should see "Add Seminar"

  Scenario: User login with invalid credentials
    Given I have an account with email "john@example.com" and password "password123"
    And I am on the login page
    When I fill in "email" with "john@example.com"
    And I fill in "password" with "wrongpassword"
    And I click "Sign in"
    Then I should remain on the login page
    And I should see "Invalid email or password"

  Scenario: Creating a seminar after registration
    Given I am on the signup page
    When I fill in "user_name" with "New Instructor"
    And I fill in "user_email" with "instructor@example.com"
    And I fill in "user_password" with "password123"
    And I fill in "user_password_confirmation" with "password123"
    And I click "Create account"
    Then I should be redirected to the home page
    When I click "Add Seminar"
    Then I should be on the new seminar page
    When I fill in "Title" with "Beginner BJJ Workshop"
    And I fill in "Description" with "A comprehensive introduction to Brazilian Jiu-Jitsu fundamentals for beginners"
    And I fill in "Address" with "123 Dojo Street, San Francisco, CA 94102"
    And I fill in "Starts at" with "2025-10-01 10:00"
    And I fill in "Price" with "150"
    And I select "Roger Gracie" from "Instructors"
    And I click "Create Seminar"
    Then I should be redirected to the seminar show page
    And I should see "Seminar created successfully"
    And I should see "Beginner BJJ Workshop"
    And I should see "Roger Gracie"
    And I should see "$150"

  Scenario: Creating a seminar after login
    Given I have an account with email "instructor@example.com" and password "password123"
    And I am on the login page
    When I fill in "email" with "instructor@example.com"
    And I fill in "password" with "password123"
    And I click "Sign in"
    And I click "Add Seminar"
    Then I should be on the new seminar page
    When I fill in "Title" with "Advanced Guard Passing"
    And I fill in "Description" with "Master the art of guard passing with these advanced techniques and concepts"
    And I fill in "Address" with "456 Training Center, Los Angeles, CA 90001"
    And I fill in "Starts at" with "2025-11-15 14:00"
    And I fill in "Price" with "200"
    And I fill in "Max participants" with "30"
    And I select "Andre Galvao" from "Instructors"
    And I click "Create Seminar"
    Then I should be redirected to the seminar show page
    And I should see "Seminar created successfully"
    And I should see "Advanced Guard Passing"
    And I should see "Andre Galvao"
    And I should see "$200"
    And I should see "30 spots available"

  Scenario: User logout
    Given I am signed in as "john@example.com"
    When I click "Sign out"
    Then I should be redirected to the home page
    And I should see "Signed out successfully"
    And I should not see "Add Seminar"
    And I should see "Get started"

  Scenario: Accessing protected pages without authentication
    When I try to visit the new seminar page
    Then I should be redirected to the login page
    And I should see "You need to sign in first"