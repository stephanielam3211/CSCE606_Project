Feature: User Login and Logout
  As an admin
  I want to log in and log out
  So that I can access the system securely

  Scenario: Admin logs in successfully
    When I visit the login page
    And I fill in "username" with "admin"
    And I fill in "password" with "admin"
    And I press "Login"
    Then I should see "Hello, admin! You are logged in."
    And I should see "logout"

  Scenario: Admin enters incorrect credentials
    When I visit the login page
    And I fill in "username" with "admin"
    And I fill in "password" with "wrongpassword"
    And I press "Login"
    Then I should see "Invalid username or password."

  Scenario: Admin logs out successfully
    Given I am logged in as "admin"
    When I click "logout"
    Then I should see "Login"