
# Charizard

## TA Matching

The Department of Computer Science at Texas A&M needs a better approach to assigning TAs and other educational positions to professors. To address this, we designed a software application that will allow for a more efficient matching process for TAs, graders, and senior graders. 

## Setup

- Ensure Python 3 is installed on your system.
- Run ``source setup.sh`` to create a virtual environment and install the necessary dependencies for the project.
  - You are likely to see exactly 1 "No such directory" error. This is normal and a side effect of multi-platform support.

## Input Control Flow and Requirements
All the necessary input forms can be found at this link - https://drive.google.com/drive/u/2/folders/19NkJCj2hkGBxRfQsPsk2_aA0FJvh3R0L

This program requires three CSVs to produce TA and Grader matchings.

There are two Google forms that produce two out of the three CSVs, "TA Applicant Form" and "Final Round - Professor Preferences". The TA Applicant form should ideally be sent out well before the Professor Preferences form as this allows professors to basic information on applicants before submitting input.

Before the TA Applicant form is sent out, ensure that the spreadsheet "faculty and emails" is up to date with relevant names and emails. Any time a change is made to this document, a Google App Script will run that will take all the names and emails in that spreadshet and populate the list of answer choices for the question "Who is your advisor (if applicable)?" in the TA Applicant Form. The code for the Google Script can be accessed by opening the spreadsheet, clicking "Extensions", and then selecting "Apps Script".

Additionally, ensure that the "CSCE Courses" spreadsheet is filled out with accurate information. Another Google Script will run every time this is updated to populate answer choice options for three questions in the Applicant Form.

Once the TA Applicant form is sent out, two Google App Scripts will run on each submission. One script will take each name and email and populate the list of answer choices for the question  "Select a TA/Grader". This is done so that the user does not need to manually enter in every single applicant name for that one drop down. These app scripts can be accessed by opening the TA Applicant Form in edit mode, clicking the three dots in the top right, and selecting "Script Editor". Save the responses from the TA Applicant form as one of the 3 necessary CSV inputs for the program.

After responses are collected from the "Final Round - Professor Preferences" form, save those results as a CSV as that will be another required input file for the program.

Finally, the user will need to provde a "TA_Needs.csv" that will need the same information found in the sample TA_Needs.csv provided in this repository. Please keep in mind that the "Professor Pre-Reqs" entry needs to be inputted as a comma separated list of course numbers (e.g. "121, 412, 465".

Please note that changes to the input form could potentially affect the underlying Google App Scripts populating some of the fields and answer choices, so edit those as needed. Additionally, the runtime conditions for these scripts can be changed as needed.

## Usage

Run the TA matching program with ```python main.py input/TA_Applicants.csv input/TA_Needs.csv input/Prof_prefs.csv```.

## Updating Weights

This program generates edge weights for its matching using a bucketing system. Certain qualities about a TA or course
will result in a TA->Course edge weight being increased by a certain amount based on which bucket that quality is
assigned to. Generally, bucket 1 is the most highly weighted, then bucket 2, etc.

To see what the current weight assignments look like, check out the Buckets class in the ``Weighting.py`` file.

If you want to make a certain trait more or less important, you can modify the bucket values in this class.
