//Change these consts if the links change or a new form is created
const professorInputSurveyURL = "https://docs.google.com/forms/d/1zR9OpDPBFnT5TZVjmfuwxm3s1FQ2-3hCDSRi4tmMGHM/edit";
const applicantInfoSpreadsheetURL = "https://docs.google.com/spreadsheets/d/19PKoJRKe2_zU29u9lczKEoHjf5HakVYtHJsACBWVznU/edit#gid=0"

/*
  This function takes every TA applicant name from the applicant form and populates the 
  "select TA/Grader" question in the survey sent out to professors.
*/
function addTAsToFinalProfRound() {
  var taApplicantForm = FormApp.getActiveForm(); //ta applicant form
  var professorInputForm = FormApp.openByUrl(professorInputSurveyURL); //professor input form
  
  var nameQuestion = taApplicantForm.getItemById(taApplicantForm.getItems()[0].getId()); //gets name of applicant, assuming name question remains first

  var items = professorInputForm.getItems();
  var taListDropdownQuestionID = "";

  //Fetches the question ID for the question on the professor input form that asks to select a TA/applicant
  for(var i in items){
    if(items[i].getTitle().indexOf("TA/Grader") > -1){
      taListDropdownQuestionID = items[i].getId();
    }
  }

  var taListDropdown = professorInputForm.getItemById(taListDropdownQuestionID); //id of dropdown (will contains TAs)
  
  // get the responses to every question from the TA Applicant Form
  var formAResponses = taApplicantForm.getResponses();
  
  // create a new array of choices for the dropdown question in professor input form
  var newChoices = [];
  
  // loop through each response and add the answer to the newChoices array if it doesn't already exist
  for (var i = 00; i < formAResponses.length; i++) {
    var name = formAResponses[i].getResponseForItem(nameQuestion).getResponse();
    var email = formAResponses[i].getRespondentEmail();

    var answer = name + " (" + email + ")";
    
    // check if the answer already exists in the newChoices array
    var exists = false;
    for (var j = 0; j < newChoices.length; j++) {
      if (newChoices[j].getValue() == answer) {
        exists = true;
        break;
      }
    }
    
    // if the answer doesn't already exist, add it to the newChoices array as a new Choice object
    if (!exists) {
      var choice = taListDropdown.asListItem().createChoice(answer);
      newChoices.push(choice);
    }
  }
  
  // set the choices for the dropdown question in the professor input form to the newChoices array
  taListDropdown.asListItem().setChoices(newChoices);
}

/*
This function populates a spreadsheet that contains basic information about TA/Grader candidates.
This spreadsheet will be shown to professors when they fill out their input sheet so they have
some idea of the qualifications of applicants.
*/
function populateApplicantSpreadsheet(){
  var taApplicantForm = FormApp.getActiveForm(); //ta applicant form

  var nameQuestionID = "";
  var degreeTypeQuestionID = "";
  var gpaQuestionID = "";
  var englishLevelQuestionID = "";
  var coursesTakenQuestionID = "";
  var priorExperienceQuestionID = "";

  var items = taApplicantForm.getItems();

  for(var i in items){
    if(items[i].getTitle().indexOf("First and Last") > -1){
      nameQuestionID = items[i].getId();
    }

    if(items[i].getTitle().indexOf("Degree Type") > -1){
      degreeTypeQuestionID = items[i].getId();
    }

    if(items[i].getTitle().indexOf("GPA") > -1){
      gpaQuestionID = items[i].getId();
    }

    if(items[i].getTitle().indexOf("English language certification") > -1){
      englishLevelQuestionID = items[i].getId();
    }

    if(items[i].getTitle().indexOf("taken at TAMU?") > -1){
      coursesTakenQuestionID = items[i].getId();
    }

    if(items[i].getTitle().indexOf("courses have you TAd for?") > -1){
      priorExperienceQuestionID = items[i].getId();
    }
    
  }


  var taApplicantFormResponses = taApplicantForm.getResponses();
  var spreadsheet = SpreadsheetApp.openByUrl(applicantInfoSpreadsheetURL);
  var sheet = spreadsheet.getSheetByName('Sheet1');

  for(var i=0; i<taApplicantFormResponses.length; i++){
    var name = "";
    var degreeType = "";
    var gpa = "";
    var englishLevel = "";
    var coursesTaken = "";
    var priorExperience = "";

    name = taApplicantFormResponses[i].getResponseForItem(taApplicantForm.getItemById(nameQuestionID)).getResponse();
    degreeType = taApplicantFormResponses[i].getResponseForItem(taApplicantForm.getItemById(degreeTypeQuestionID)).getResponse();
    gpa = taApplicantFormResponses[i].getResponseForItem(taApplicantForm.getItemById(gpaQuestionID)).getResponse();
    englishLevel = taApplicantFormResponses[i].getResponseForItem(taApplicantForm.getItemById(englishLevelQuestionID)).getResponse();

    try{
      var coursesTakenResponses = taApplicantFormResponses[i].getResponseForItem(taApplicantForm.getItemById(coursesTakenQuestionID)).getResponse();
      for(var x in coursesTakenResponses){
        coursesTaken += coursesTakenResponses[x] + ", ";
      }
      console.log(coursesTaken);
    }catch(err){
      console.log("this student has taken no courses");
    }

    try{
      priorExperienceResponses = taApplicantFormResponses[i].getResponseForItem(taApplicantForm.getItemById(priorExperienceQuestionID)).getResponse();
      for(var x in priorExperienceResponses){
        priorExperience += priorExperienceResponses[x] + ", ";
      }
      console.log(priorExperience);
    }catch(err){
      console.log("this student has no prior experiences");
    }

    sheet.appendRow([name, degreeType, gpa, englishLevel, coursesTaken, priorExperience]);
  }




}


