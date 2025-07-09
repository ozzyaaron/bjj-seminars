Feature: Admin Workflows
  As an admin user
  I want to manage teams, players, and users
  So that I can maintain the platform's data integrity

  Background:
    Given I am signed in as an admin user

  Scenario: Creating a new team
    Given I am on the new team page
    When I fill in "Name" with "Gracie Barra"
    And I fill in "Description" with "A global Brazilian Jiu-Jitsu team founded by Carlos Gracie Jr."
    And I select "BR" from "Country"
    And I click "Create Team"
    Then I should be redirected to the team show page
    And I should see "Team created successfully"
    And I should see "Gracie Barra"

  Scenario: Creating team with invalid data
    Given I am on the new team page
    When I fill in "Name" with ""
    And I click "Create Team"
    Then I should remain on the new team page
    And I should see "Name can't be blank"

  Scenario: Editing an existing team
    Given there is a team named "Alliance"
    And I am on the team edit page
    When I fill in "Name" with "Alliance Jiu Jitsu"
    And I fill in "Description" with "Updated team description"
    And I click "Update Team"
    Then I should be redirected to the team show page
    And I should see "Team updated successfully"
    And I should see "Alliance Jiu Jitsu"

  Scenario: Viewing teams index with admin controls
    Given there are multiple teams available
    When I visit the teams page
    Then I should see "BJJ Teams"
    And I should see "Add New Team" button
    And I should see "Edit" links for each team
    And I should see "Delete" links for each team

  Scenario: Creating a new player
    Given there is a team named "ATOS"
    And I am on the new player page
    When I fill in "Name" with "Marcus Buchecha"
    And I fill in "Nationality" with "Brazil"
    And I select "ATOS" from "Team"
    And I fill in "Bio" with "Multiple-time world champion in Brazilian Jiu-Jitsu"
    And I click "Create Player"
    Then I should be redirected to the player show page
    And I should see "Player created successfully"
    And I should see "Marcus Buchecha"

  Scenario: Creating player with invalid data
    Given I am on the new player page
    When I fill in "Name" with ""
    And I click "Create Player"
    Then I should remain on the new player page
    And I should see "Name can't be blank"

  Scenario: Editing an existing player
    Given there is a player named "John Doe"
    And I am on the player edit page
    When I fill in "Name" with "John Smith"
    And I fill in "Bio" with "Updated player biography"
    And I click "Update Player"
    Then I should be redirected to the player show page
    And I should see "Player updated successfully"
    And I should see "John Smith"

  Scenario: Viewing players index with admin controls
    Given there are multiple players available
    When I visit the players page
    Then I should see "BJJ Players"
    And I should see "Add New Player" button
    And I should see "Edit" links for each player
    And I should see "Delete" links for each player

  Scenario: Deleting a team
    Given there is a team named "Test Team"
    And I am on the team show page
    When I click "Delete Team"
    And I confirm the deletion
    Then I should be redirected to the teams index page
    And I should see "Team deleted successfully"
    And I should not see "Test Team"

  Scenario: Deleting a player
    Given there is a player named "Test Player"
    And I am on the player show page
    When I click "Delete Player"
    And I confirm the deletion
    Then I should be redirected to the players index page
    And I should see "Player deleted successfully"
    And I should not see "Test Player"

  Scenario: Assigning players to teams
    Given there is a team named "Checkmat"
    And there is a player named "Rafael Mendes" without a team
    And I am on the player edit page
    When I select "Checkmat" from "Team"
    And I click "Update Player"
    Then I should see "Player updated successfully"
    And I should see "Checkmat" in the team section

  Scenario: Regular user cannot access admin features
    Given I am signed in as a regular user
    When I try to visit the new team page
    Then I should be redirected to the home page
    And I should see "You are not authorized to access this page"

  Scenario: Regular user cannot access admin features for players
    Given I am signed in as a regular user
    When I try to visit the new player page
    Then I should be redirected to the home page
    And I should see "You are not authorized to access this page"

  Scenario: Managing team relationships
    Given there is a team named "Atos" with 3 players
    And I am on the team show page
    Then I should see all 3 players listed
    And I should see their names and bio information
    When I click on a player's name
    Then I should be taken to that player's profile page