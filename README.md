# TA/Grader Assignment App 
## CSCE606 Project

# https://tamu-csce-ta-portal-0646b9b7b2a9.herokuapp.com/

# https://codeclimate.com/github/stephanielam3211/CSCE606_Project

## Welcome to the TA/Grader Assignment App. This app was designed for the CSCE department at Texas A&M to use as an all in one solution for Students, Professors, and the department to use. This app will accept applications from students and reccommendations from professors. The department can then just click a button to assign applicant to a TA, Senior grader, or grader based on certain parameters. The assignments are made using the professor reccommendations, applicants degree level, GPA, Previous courses taken, hours, etc. Higher weights are given to certain paramsters such as negative reccommendations which will make the algorithm not assign that student to the professor or PHDs getting prioritized for TA assingments. This app allows the admin to quickly assign and modify assignments. 

# Usage instructions

## Admin Use
### Class inport
After login, click on the `View Classes` tab then choose file where you will select the csv for al of the classes. Then click import. An example of the csv is in the documentions folder named TA_Needs.csv. Formating must be exact. This will import all the classes into the app. 

### How to assign applicants
After importing classe, the applicants will then be able to see the classes that they can choose from. Once you are ready to assign the applicants head to the Assign TA/Grader tab. This is the mangement tab for all the assignments. Click on `Auto-Assign` in the righthand side of the page. This is configured so that it starts as a clean slate so only use knowing that it will erase any previous assignments if any. 

### How to view tables
The `Auto-assign` will redirect you to the assignments view page for assignments. This page will have all of the TA, Senior Grader, and Grader Assignents as separate tables. Below that are the admin files that are used to track the unassigned applicants, any modifications to assignments, and new classes that gets update when and assignment gets deleted as the class will now need a new TA or grader. The admin files are only for viewing. 

### Send out offers and modify assignments
Click on one of the tables to send out offers and modify offers. At the top of the table there are three buttons. The `SEND ALL OFFERS` button is a toggle that will send or unsend the TA/Grader job to all of the assignees and makes it viewable on the applicants end. You can also individually send and unsend offers to assignees.

The next button is the `REVOKE CONFIRMATION FOR ALL APPLICANTS` that will revoke the confirmation of all the assignees. This is to give the admin the option to revoke the offers of all the assignees without deleteing the assignment. You can also individually revoke the assignment for assignees if that assignee accepts and confirmed the offer through their portal. The Next button

The last button at the top is the `DELETE ALL UNCONFIRMED ASSIGNMENTS` which will remove all of the assignments where a student has not confirmed thier offer. The table doesnt show applicants that decline their position as the application will simply remove thier assignment automatically if they decline. This button is for the students that simply don't accept the offer with the admin's timeframe. The button removes the assignment from the table and creates a negative reccommendation for that student and assignment.

In the table to the right are the admin actions buttons specifically `EDIT` and `DELETE`.

`EDIT` will redirect you to the assignment page where you can change that positions assignee with one of the unassigned applicants. This will update the table with the new assignment and send add the old assignee to the unassigned applicants table.

`DELETE` will remove the assignment from the table, create a negative reccommendations for that student/posistion, and add the position to the new class needs file.

### How to Reassign after modifications
After all the modifications and deletions, head back to the manage assignments page where you first ran the Auto-Assign. The `Re-run Auto-Assign` button will now become clickable as it detects changes to the assignments that made positions open up that need to be filled. This button will also become available if a class postition is added last second to the application in the `View Classes` tab. This button will run the algortihm again except with only the unassigned applicants and the new needs. Afterwards it'll redirect to the assignment view page as before preserving all of the old assignment and adding the new ones. 

### All Positions are filled and confirmed
After assigning and re-assigning for as many times as you'd like, then you go back the manage assignments tab. Click on `EXPORT FINAL CSV`. this will get all of the assignment for every position, organized by assignment type, with all of the relevant applicant information into one singular csv.  

WARNING!! The assignments dont need to be confirmed to be sent to the final assigments cvs. This is so that the admin can easily export all the assignments for all the table whenever they'd like. For instance the Admin can export this right after making the initial assignments to get every assignees email organized by position type. This can be used for when the admin wants to send out emails to all the assignees before sending out the offers through the table. 



# For Local setup:

* Ruby version  
    ruby "3.4.1" or higher

* Configuration  
    Run this to install all the right ruby dependencies
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
# For Heroku Setup

* Ensure Heroku CLI is installed
    * https://devcenter.heroku.com/articles/heroku-cli
* Login to heroku
```sh
  heroku login
```
* Create app in Heroku
```sh
  heroku create your-app-name
```
* Push Project to Heroku
```sh
  git push heroku main
```
* Go to your app console on your heroku dashboard and add Heroku Postgress Essential 0 to add-ons

* Add env var to heroku
```sh
  heroku config:set GOOGLE_CLIENT_ID="google client id" GOOGLE_CLIENT_SECRET="google client secret"
```
* Add Python buildpack to heroku
```sh
  heroku buildpacks:add heroku/python
```
* Run migrations on Heroku
```sh
  heroku run rails db:migrate
```
* Go to OAuth portal and update the redirect uri
    * Fill out with this https://(YOUR APP URL)/auth/google_oauth2/callback
            
# How to run the test suites

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
