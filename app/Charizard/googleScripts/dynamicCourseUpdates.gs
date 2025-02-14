//Edit this as needed
const TAApplicantForm = "https://docs.google.com/forms/d/1OhhO2Q0xDcuXzAOKifTgMbWGQ1R3al1Fa1AvqAIFyXU/edit";

//This function takes courses from the "CSCE Courses" spreadsheet and adds them as options to 3 questions in the TA Applicant Form
//1. Which courses have you taken at TAMU?
//2. Which courses have you taken at another university?
//3. Which courses have you TAd/Graded for?

function addCoursesToQuestionsInTAApplicantForm() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet(); // opens the spreadsheet containing courses
  var courseNumbers = sheet.getRange("B:B").getValues(); // gets course number
  var taApplicantForm = FormApp.openByUrl(TAApplicantForm);

  var allQuestions = taApplicantForm.getItems();
  var takenAtTAMUID = "";
  var takenAtAnotherUniversityID = "";
  var gradedOrTAdForID = "";

  //Probably update these queries if the questions change
  for(var i in allQuestions){
    if(allQuestions[i].getTitle().indexOf("at TAMU?") > -1){
      takenAtTAMUID = allQuestions[i].getId();
    }

    if(allQuestions[i].getTitle().indexOf("another university?") > -1){
      takenAtAnotherUniversityID = allQuestions[i].getId();
    }

    if(allQuestions[i].getTitle().indexOf("Graded for?") > -1){
      gradedOrTAdForID = allQuestions[i].getId();
    }
  }

  var takenAtTAMUQuestion = taApplicantForm.getItemById(takenAtTAMUID);
  var takenAtAnotherUniversityQuestion = taApplicantForm.getItemById(takenAtAnotherUniversityID);
  var gradedOrTAdForQuestion = taApplicantForm.getItemById(gradedOrTAdForID);

  var newOptionsTakenAtTTAMU = [];
  var newOptionsTakenAtAnotherUniversity = [];
  var newOptionsGradedOrTAdForQuestion = [];


  for(var i in courseNumbers){
    if(i > 0 && courseNumbers[i].toString() != ""){
      newOptionsTakenAtTTAMU.push(takenAtTAMUQuestion.asCheckboxItem().createChoice(courseNumbers[i].toString()));
      newOptionsTakenAtAnotherUniversity.push(takenAtAnotherUniversityQuestion.asCheckboxItem().createChoice(courseNumbers[i].toString()));
      newOptionsGradedOrTAdForQuestion.push(gradedOrTAdForQuestion.asCheckboxItem().createChoice(courseNumbers[i].toString()));
    }
  }
  
  takenAtTAMUQuestion.asCheckboxItem().setChoices(newOptionsTakenAtTTAMU);
  takenAtAnotherUniversityQuestion.asCheckboxItem().setChoices(newOptionsTakenAtAnotherUniversity);
  gradedOrTAdForQuestion.asCheckboxItem().setChoices(newOptionsGradedOrTAdForQuestion);

}

