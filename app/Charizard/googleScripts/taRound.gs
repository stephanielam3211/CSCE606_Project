/*
This function takes all the faculty and emails from the faculty and emails google sheets and then
populates the "Who's your advisor" question on the TA applicant form. This script is run every time that
sheet is updated; however, you can change the run time conditions under "triggers" if need be
*/

//Edit or change this link as needed. 
const TAApplicantFormURL = "https://docs.google.com/forms/d/1OhhO2Q0xDcuXzAOKifTgMbWGQ1R3al1Fa1AvqAIFyXU/edit";

function addAdvisorsToDropdown(){
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet(); // opens the spreadsheet containing faculty and emails
  var column1 = sheet.getRange("A:A").getValues(); // change A:A to the range of the first column you want to fetch
  var column2 = sheet.getRange("B:B").getValues(); // change B:B to the range of the second column you want to fetch
  
  var namesAndEmails = [];
  
  var TAFormID = TAApplicantFormURL.match(/[-\w]{25,}/); //parse out form ID
  var taApplicantForm = FormApp.openById(TAFormID);
  var advisorQuestionId = "0";

  var allQuestions = taApplicantForm.getItems();
  for(var x in allQuestions){
    if(item[x].getTitle().indexOf("advisor") > -1){
      advisorQuestionId = item[x].getId();
      break;
    }
  }

  var advisorQuestion = taApplicantForm.getItemById(advisorQuestionId); //access advisor question so we can modify answer choices

  for (var i = 0; i < column1.length; i++) {
    if (column1[i][0] != "" && column2[i][0] != "") {
      namesAndEmails.push(advisorQuestion.asListItem().createChoice([column1[i][0] + " (" + column2[i][0]] + ")"));
    }
  }

  advisorQuestion.asListItem().setChoices(namesAndEmails);

}