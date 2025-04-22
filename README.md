# TA/Grader Assignment App 
## CSCE606 Project

#https://tamu-ta-ee36b085db2d.herokuapp.com/

#https://codeclimate.com/github/stephanielam3211/CSCE606_Project

For Local setup:

* Ruby version  
    ruby "3.4.1" or higher

* Configuration  
    Run this to stall all the right ruby dependencies
```sh
  bundle install
```
* Setup instructions:
    * Create a google app 

      https://console.cloud.google.com/

        * Create a new project
            * go to OAuth Consent Screen and fill it out
        * Go to Create OAuth client ID 
            * Fill out the app name information
            * Add http://127.0.0.1:3000/auth/google_oauth2/callback to the redirect uri and Create
            * Save Client id and Client secret credentials
        * Create .env file in root directory of project
            * add previously saved client id to GOOGLE_CLIENT_ID="CREDENTIALS"
            * add previously saved client secret GOOGLE_CLIENT_SECRET="CREDENTIALS"
    * run rails migrations
        ```sh
          rails db:migrate
        ```
    * run app locally
        ```sh
          rails server
        ```
For Heroku Setup

* Ensure Heroku CLI is installed
    * https://devcenter.heroku.com/articles/heroku-cli
* Login to heroku
```sh
  heroku login
```
* Creat app in Heroku
```sh
  heroku create your-app-name
```
* Push Project to Heroku
```sh
  git push heroku main
```
* add env var to heroku
```sh
  heroku config:set GOOGLE_CLIENT_ID="google client id" GOOGLE_CLIENT_SECRET="google client secret"
```

* How to run the test suites

```sh
  rspec
```
```sh 
bundle exec cucumber
```
```sh 
rubocop
```
```sh 
open coverage/index.html
``` 
```
heroku run rails db:migrate
```
