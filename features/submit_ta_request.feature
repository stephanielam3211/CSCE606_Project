Feature: Submit TA Request Form
  As a student
  I want to fill out the TA request form
  So that I can apply to be a TA

  Scenario: Student submits a TA request successfully via hidden field
    Given I am logged in
    Given the course "CSCE 606" exists
    And I am on the TA request form page
    When I fill in the TA form field "applicant[email]" with "johndoe@example.com"
    And I fill in the TA form field "applicant[name]" with "John Doe"
    And I fill in the TA form field "applicant[degree]" with "Masters (Thesis)"
    And I fill in the hidden TA form field "positions_hidden" with "TA"
    And I fill in the TA form field "applicant[number]" with "1234567890"
    And I fill in the TA form field "applicant[uin]" with "123456789"
    And I fill in the TA form field "applicant[hours]" with "20"
    And I fill in the TA form field "applicant[citizenship]" with "USA"
    And I fill in the TA form field "applicant[cert]" with "Native"
    And I fill in the TA form field "applicant[prev_course]" with "CSCE 606"
    And I fill in the TA form field "applicant[prev_uni]" with "NA"
    And I fill in the TA form field "applicant[prev_ta]" with "NA"
    And I fill in the TA form field "applicant[advisor]" with "Dr. Smith"
    And I select "CSCE 606" from "applicant[choice_1]"
    And I press the TA form button "Submit Application"
    Then I should see the success message "Applicant was successfully created."

  Scenario: Student submits a TA request with missing fields
    Given I am logged in
    And I am on the TA request form page
    When I fill in the TA form field "applicant[email]" with "johndoe@example.com"
    And I fill in the TA form field "applicant[name]" with "John Doe"
    And I fill in the TA form field "applicant[degree]" with "Masters (Thesis)"
    And I leave the "applicant[number]" field blank
    And I fill in the TA form field "applicant[uin]" with "123456789"
    And I fill in the TA form field "applicant[hours]" with "20"
    And I fill in the TA form field "applicant[citizenship]" with "USA"
    And I fill in the TA form field "applicant[cert]" with "1"
    And I press the TA form button "Submit Application"
    Then I should see "Number can't be blank"