Feature: Seminar Management
  As a registered user
  I want to create, view, edit, and delete seminars
  So that I can share and manage BJJ seminar information

  Background:
    Given I am signed in as "instructor@example.com"

  Scenario: Creating a new seminar successfully
    Given I am on the new seminar page
    When I fill in "Title" with "Guard Passing Fundamentals"
    And I fill in "Description" with "Comprehensive workshop covering basic to advanced guard passing techniques for all skill levels."
    And I fill in "Address" with "123 Main Street"
    And I fill in "City" with "San Francisco"
    And I select "CA" from "State"
    And I fill in "Zip code" with "94102"
    And I select "US" from "Country"
    And I fill in "Starts at" with "2025-08-01 14:00"
    And I fill in "Ends at" with "2025-08-01 17:00"
    And I click "Create Seminar"
    Then I should be redirected to the seminar show page
    And I should see "Seminar created successfully"
    And I should see "Guard Passing Fundamentals"
    And I should see "instructor@example.com"

  Scenario: Creating seminar with invalid data
    Given I am on the new seminar page
    When I fill in "Title" with ""
    And I fill in "Description" with "Short"
    And I click "Create Seminar"
    Then I should remain on the new seminar page
    And I should see "Title can't be blank"
    And I should see "Description is too short"

  Scenario: Viewing a seminar as the owner
    Given I have created a seminar titled "Submission Escapes"
    When I visit the seminar show page
    Then I should see "Submission Escapes"
    And I should see "Edit Seminar" button
    And I should see "Delete Seminar" button

  Scenario: Viewing a seminar as another user
    Given there is a seminar titled "Open Guard Techniques" created by another user
    When I visit the seminar show page
    Then I should see "Open Guard Techniques"
    And I should not see "Edit Seminar" button
    And I should not see "Delete Seminar" button

  Scenario: Editing my own seminar
    Given I have created a seminar titled "Original Title"
    And I am on the seminar edit page
    When I fill in "Title" with "Updated Title"
    And I fill in "Description" with "Updated description with sufficient length for validation"
    And I click "Update Seminar"
    Then I should be redirected to the seminar show page
    And I should see "Seminar updated successfully"
    And I should see "Updated Title"

  Scenario: Cannot edit another user's seminar
    Given there is a seminar created by another user
    When I try to visit the edit page for that seminar
    Then I should be redirected to the home page
    And I should see "You are not authorized to edit this seminar"

  Scenario: Deleting my own seminar
    Given I have created a seminar titled "Test Seminar"
    And I am on the seminar show page
    When I click "Delete Seminar"
    And I confirm the deletion
    Then I should be redirected to the seminars index page
    And I should see "Seminar deleted successfully"
    And I should not see "Test Seminar"

  Scenario: Cannot delete another user's seminar
    Given there is a seminar created by another user
    When I try to delete that seminar
    Then I should be redirected to the home page
    And I should see "You are not authorized to delete this seminar"

  Scenario: Viewing seminars index page
    Given there are multiple seminars available
    When I visit the seminars page
    Then I should see "BJJ Seminars"
    And I should see seminar cards with titles and details
    And I should see search and filter options
    And I should see "Add New Seminar" button

  Scenario: Searching for seminars
    Given there is a seminar titled "Guard Passing Workshop"
    And there is a seminar titled "Submission Defense Clinic"
    When I visit the seminars page
    And I fill in the search field with "Guard"
    And I click "Search"
    Then I should see "Guard Passing Workshop"
    And I should not see "Submission Defense Clinic"

  Scenario: Adding images to a seminar
    Given I am on the new seminar page
    When I fill in all required seminar fields
    And I attach an image file "seminar_photo.jpg"
    And I click "Create Seminar"
    Then I should see the seminar with the uploaded image
    And the image should be displayed in the seminar card

  Scenario: Hitting daily seminar creation limit
    Given I have already created 25 seminars today
    When I try to create another seminar
    Then I should see "Daily seminar creation limit reached"
    And the seminar should not be created

  Scenario: Admin can edit any seminar
    Given I am signed in as an admin user
    And there is a seminar created by another user
    When I visit the seminar show page
    Then I should see "Edit Seminar" button
    And I should see "Delete Seminar" button