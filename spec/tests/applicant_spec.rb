# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicantsController, type: :controller do
  let!(:applicant1) do
    Applicant.create!(
      name:        "Alice",
      email:       "alice@example.com",
      uin:         "111",
      degree:      "Masters",
      positions:   "TA",
      number:      "123-456-7899",
      hours:       "11",
      citizenship: "US",
      cert:        "Yes",
      gpa:        "3.8",
      choice_1:    "CSCE 606",# <-- Add at least one choice
      confirm: SecureRandom.hex(10)
    )
  end

  let!(:applicant2) do
    Applicant.create!(
      name:        "Bob",
      email:       "bob@example.com",
      uin:         "222",
      degree:      "PhD",
      positions:   "RA",
      number:      "123-987-6543",
      hours:       "10",
      citizenship: "US",
      cert:        "No",
      gpa:        "3.9",
      choice_1:    "CSCE 607",   # <-- Add at least one choice
      confirm: SecureRandom.hex(4)
    )
  end

  describe "coverage of controller actions" do
    it "#index, #search, #search_email, #search_uin in one go" do
      get :index
      expect(response).to be_successful
      expect(assigns(:applicants).map(&:name)).to eq([ "Alice", "Bob" ])
      get :index, params: { sort: "email", direction: "desc" }
      expect(assigns(:applicants).map(&:email)).to eq([ "bob@example.com", "alice@example.com" ])
      get :search, params: { term: "Ali" }, format: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body).first["name"]).to eq("Alice")
      get :search_email, params: { term: "bob@" }, format: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body).first["email"]).to eq("bob@example.com")
      get :search_uin, params: { term: "111" }, format: :json
      expect(response).to be_successful
      expect(JSON.parse(response.body).first["uin"]).to eq(111)
    end

    it "#show and #new" do
      # show
      applicant = Applicant.create!(name: "test",
        email: "test@example.com",
        uin: "123",
        degree: "PhD",
        positions: "TA",
        number: "123-234-4444",
        hours: "10",
        citizenship: "US",
        cert:        "No",
        gpa:        "3.9",
        choice_1:    "CSCE 607",   # <-- Add at least one choice
        confirm: SecureRandom.hex(10))
      get :show, params: { id: applicant.id }
      expect(response).to be_successful
      expect(assigns(:applicant)).to eq(applicant)

      # new
      get :new
      expect(response).to be_successful
      expect(assigns(:applicant)).to be_a_new(Applicant)
    end

    it "#create" do
    stub_const("TaMatch", nil)
    stub_const("SeniorGraderMatch", nil)
    stub_const("GraderMatch", nil)
      expect {
        post :create, params: {
          applicant: {
            name:        "Charlie",
            email:       "charlie@example.com",
            uin:         "333",
            degree:      "Masters",
            positions:   "TA",
            number:      "000-111-2222",
            hours:       "10",
            citizenship: "US",
            cert:        "Yes",
            choice_1:    "CSCE 608", # Provide at least one choice
            gpa:        "3.5",
            confirm: SecureRandom.hex(4)
          }
        }
      }.to change(Applicant, :count).by(1)
      expect(response).to redirect_to(applicant_path(Applicant.last))

      Blacklist.create!(student_email: "blacklisted@example.com")
      post :create, params: {
        applicant: {
          name:        "Eve",
          email:       "blacklisted@example.com",
          uin:         "444",
          degree:      "PhD",
          positions:   "RA",
          number:      "888-999-9999",
          hours:       "15",
          citizenship: "US",
          cert:        "No",
          choice_1:    "CSCE 610",
          confirm: SecureRandom.hex(4)
        }
      }
      applicant = Applicant.find_by(email: "blacklisted@example.com")
      expect(applicant.name).to eq("*Eve")
      expect {
        post :create, params: { applicant: { name: "", email: "" } }
      }.not_to change(Applicant, :count)
      expect(response).to render_template(:new)
    end

    it "#update" do
      patch :update, params: { id: applicant1.id, applicant: { name: "Alice Updated" } }
      expect(response).to redirect_to(applicant_path(applicant1))
      expect(applicant1.reload.name).to eq("Alice Updated")

      patch :update, params: { id: applicant1.id, applicant: { name: "" } }
      expect(response).to render_template(:edit)
    end

    it "#destroy and #wipe_applicants" do
      expect {
        delete :destroy, params: { id: applicant2.id }
      }.to change(Applicant, :count).by(-1)
      expect(response).to redirect_to(root_path)

      expect(Applicant.count).to be > 0
      delete :wipe_applicants
      expect(Applicant.count).to eq(0)
      expect(response).to redirect_to(root_path)
    end

    it "#my_application" do
      session[:email] = "alice@example.com"
      get :my_application
      expect(assigns(:applicant)).to eq(applicant1)
      expect(response).to render_template(:my_application)

      session[:email] = "missing@example.com"
      get :my_application
      expect(assigns(:applicant)).to be_nil
      expect(response).to render_template(:my_application)
    end
  end
end
