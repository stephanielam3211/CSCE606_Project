Feature: Submit TA Request Form
  As a student
  I want to fill out the TA request form
  So that I can apply to be a TA

  Scenario: Student submits a TA request successfully
    Given I am logged in
    And I am on the TA request form page
    When I fill in the TA form field "applicant[email]" with "johndoe@example.com"
    And I fill in the TA form field "applicant[name]" with "John Doe"
    And I fill in the TA form field "applicant[degree]" with "Masters"
    And I fill in the TA form field "applicant[positions]" with "TA"
    And I fill in the TA form field "applicant[number]" with "1234567890"
    And I fill in the TA form field "applicant[uin]" with "123456789"
    And I fill in the TA form field "applicant[hours]" with "20"
    And I fill in the TA form field "applicant[citizenship]" with "USA"
    And I fill in the TA form field "applicant[cert]" with "Native"
    And I fill in the TA form field "applicant[prev_course]" with "CSCE 606"
    And I fill in the TA form field "applicant[prev_uni]" with "NA"
    And I fill in the TA form field "applicant[prev_ta]" with "NA"
    And I fill in the TA form field "applicant[advisor]" with "Dr. Smith"
    And I fill in the TA form field "applicant[choice_1]" with "CSCE 606"
    And I fill in the TA form field "applicant[choice_2]" with "CSCE 614"
    And I fill in the TA form field "applicant[choice_3]" with "CSCE 631"
    And I fill in the TA form field "applicant[choice_4]" with "CSCE 633"
    And I fill in the TA form field "applicant[choice_5]" with "CSCE 670"
    And I fill in the TA form field "applicant[choice_6]" with "CSCE 689"
    And I fill in the TA form field "applicant[choice_7]" with "CSCE 710"
    And I fill in the TA form field "applicant[choice_8]" with "CSCE 750"
    And I fill in the TA form field "applicant[choice_9]" with "CSCE 790"
    And I fill in the TA form field "applicant[choice_10]" with "CSCE 799"
    And I press "Create Applicant"
    Then I should see "Applicant was successfully created."

  Scenario: Student submits a TA request with missing fields
    Given I am logged in
    And I am on the TA request form page
    When I fill in the TA form field "applicant[email]" with "johndoe@example.com"
    And I fill in the TA form field "applicant[name]" with "John Doe"
    And I leave the "applicant[degree]" field blank
    And I fill in the TA form field "applicant[positions]" with "TA"
    And I leave the "applicant[number]" field blank
    And I fill in the TA form field "applicant[uin]" with "123456789"
    And I fill in the TA form field "applicant[hours]" with "20"
    And I fill in the TA form field "applicant[citizenship]" with "USA"
    And I fill in the TA form field "applicant[cert]" with "Advanced"
    And I press "Create Applicant"
    Then I should see "Degree can't be blank"
    And I should see "Number can't be blank"
