# frozen_string_literal: true

require "test_helper"

class ApplicantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @applicant = applicants(:one)
  end

  test "should get index" do
    get applicants_url
    assert_response :success
  end

  test "should get new" do
    get new_applicant_url
    assert_response :success
  end

  test "should create applicant" do
    assert_difference("Applicant.count") do
      post applicants_url,
params: { applicant: { advisor: @applicant.advisor, cert: @applicant.cert,
choice_1: @applicant.choice_1, choice_10: @applicant.choice_10, choice_2: @applicant.choice_2, choice_3: @applicant.choice_3, choice_4: @applicant.choice_4, choice_5: @applicant.choice_5, choice_6: @applicant.choice_6, choice_7: @applicant.choice_7, choice_8: @applicant.choice_8, choice_9: @applicant.choice_9, citizenship: @applicant.citizenship, degree: @applicant.degree, email: @applicant.email, hours: @applicant.hours, name: @applicant.name, number: @applicant.number, positions: @applicant.positions, prev_course: @applicant.prev_course, prev_ta: @applicant.prev_ta, prev_uni: @applicant.prev_uni, uin: @applicant.uin } }
    end

    assert_redirected_to applicant_url(Applicant.last)
  end

  test "should show applicant" do
    get applicant_url(@applicant)
    assert_response :success
  end

  test "should get edit" do
    get edit_applicant_url(@applicant)
    assert_response :success
  end

  test "should update applicant" do
    patch applicant_url(@applicant),
params: { applicant: { advisor: @applicant.advisor, cert: @applicant.cert,
choice_1: @applicant.choice_1, choice_10: @applicant.choice_10, choice_2: @applicant.choice_2, choice_3: @applicant.choice_3, choice_4: @applicant.choice_4, choice_5: @applicant.choice_5, choice_6: @applicant.choice_6, choice_7: @applicant.choice_7, choice_8: @applicant.choice_8, choice_9: @applicant.choice_9, citizenship: @applicant.citizenship, degree: @applicant.degree, email: @applicant.email, hours: @applicant.hours, name: @applicant.name, number: @applicant.number, positions: @applicant.positions, prev_course: @applicant.prev_course, prev_ta: @applicant.prev_ta, prev_uni: @applicant.prev_uni, uin: @applicant.uin } }
    assert_redirected_to applicant_url(@applicant)
  end

  test "should destroy applicant" do
    assert_difference("Applicant.count", -1) do
      delete applicant_url(@applicant)
    end

    assert_redirected_to applicants_url
  end
end
