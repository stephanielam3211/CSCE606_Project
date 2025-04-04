Feature: User Login and Logout with Google
  As an authenticated user
  I want to log in and log out using Google
  So that I can access the system securely

  Scenario: User logs in with Google successfully
    When I log in with Google
    Then I should see the login message "Hello, Admin User! You are logged in."
    And I should see "logout"

  Scenario: User logs out successfully
    Given I am logged in with Google
    When I click the logout link
    Then I should see "Login"
