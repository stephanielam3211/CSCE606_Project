require "rails_helper"
RSpec.describe SessionsController, type: :request do
    describe "GET /login" do
        it "renders the login page successfully" do
            get login_path
            expect(response).to have_http_status(:success)
            expect(response.body).to include("Login")
        end
    end

    describe "POST /login" do
        # dummy test, require update once have login database
        context "with valid hardcoded credentials" do
            it "logs in the admin and redirects to the home page" do
                post login_path, params: { username: 'admin', password: 'admin' }
                expect(session[:user]).to eq('admin')
                expect(response).to redirect_to(root_path)
            end
        end
    
        context "with invalid credentials" do
            it "re-renders the login page with an error message" do
                post login_path, params: { username: 'admin', password: 'wrongpassword' }
                expect(session[:user]).to be_nil
                expect(response).to have_http_status(:success)
            end
        end
    end
    
    describe "DELETE /logout" do
        before do
            post login_path, params: { username: 'admin', password: 'admin' }
        end
    
        it "logs out the user and redirects to the login page" do
            get logout_path
            expect(session[:user]).to be_nil
            expect(response).to redirect_to(login_path)
        end
    
        it "prevents accessing the home page after logout using the back button" do
            get logout_path
            get root_path
            expect(response).not_to redirect_to(root_path)
        end
    end
end