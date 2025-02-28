Feature: Course Search
  As a user
  I want to search for a course
  So that I can find relevant courses quickly

  Scenario: Searching for an existing course
    Given the following courses exist:
      | Course Name | Course Number | Section | Instructor |
    When I visit the courses page
    And I fill in "Search by Course Details" with "PROGRAMMING I"
    And I press "Search"
    Then I should see "PROGRAMMING I"
    And I should not see "INTRO PGM"