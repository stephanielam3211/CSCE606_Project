import unittest
from typing import List

import pandas as pd

from models.Student import Student, DegreeType


class TestSetByColumn(unittest.TestCase):

    testStudent: Student

    def setUp(self) -> None:
        self.testStudent = Student.get_empty_model()

    def testTimestamp(self):
        test_timestamp = '3/24/2023 13:40:48'
        expected_timestamp = test_timestamp.strip()

        self.testStudent.set_by_column(
            Student.DataFormat.TIMESTAMP,
            test_timestamp
        )

        self.assertEqual(
            expected_timestamp,
            self.testStudent.timestamp
        )

    def testEmailLowerCased(self):
        test_email = 'SampleEmail@TAMU.eDu'
        expected_email = test_email.lower()

        self.testStudent.set_by_column(
            Student.DataFormat.EMAIL_ADDRESS,
            test_email
        )

        self.assertEqual(
            expected_email,
            self.testStudent.email
        )

    def testEmailStripped(self):
        test_email = '\tsampleemail@tamu.edu  '
        expected_email = test_email.strip()

        self.testStudent.set_by_column(
            Student.DataFormat.EMAIL_ADDRESS,
            test_email
        )

        self.assertEqual(
            expected_email,
            self.testStudent.email
        )

    def testFirstName(self):
        test_name = 'Very   Long Test Name'
        expected_first_name = 'Very'

        self.testStudent.set_by_column(
            Student.DataFormat.NAME,
            test_name
        )

        self.assertEqual(
            expected_first_name,
            self.testStudent.first_name
        )

    def testMultipleLastNames(self):
        test_name = 'Very   Long Test   Name'
        expected_last_name = 'Long Test Name'

        self.testStudent.set_by_column(
            Student.DataFormat.NAME,
            test_name
        )

        self.assertEqual(
            expected_last_name,
            self.testStudent.last_name
        )

    def testSingleLastName(self):
        test_name = 'Test Name'
        expected_last_name = 'Name'

        self.testStudent.set_by_column(
            Student.DataFormat.NAME,
            test_name
        )

        self.assertEqual(
            expected_last_name,
            self.testStudent.last_name
        )

    def testUINStripped(self):
        test_uin = ' 888001234  '
        expected_uin = test_uin.strip()

        self.testStudent.set_by_column(
            Student.DataFormat.UIN,
            test_uin
        )

        self.assertEqual(
            expected_uin,
            self.testStudent.uin
        )

    def testPhoneNumStripped(self):
        test_phone_num = '  +1 (832) 888-8888 '
        expected_phone_num = test_phone_num.strip()

        self.testStudent.set_by_column(
            Student.DataFormat.PHONE_NUMBER,
            test_phone_num
        )

        self.assertEqual(
            expected_phone_num,
            self.testStudent.phone_number
        )

    def testAdvisorEmailStripped(self):
        test_advisor = 'Advisor Guy 1 (howdy@tamu.edu )'
        expected_email = 'howdy@tamu.edu'

        self.testStudent.set_by_column(
            Student.DataFormat.ADVISOR,
            test_advisor
        )

        self.assertEqual(
            expected_email,
            self.testStudent.advisor_email
        )

    def testAdvisorEmailLowerCased(self):
        test_advisor = 'Advisor Guy 1 (HOWdY@TaMu.eDu)'
        expected_email = 'howdy@tamu.edu'

        self.testStudent.set_by_column(
            Student.DataFormat.ADVISOR,
            test_advisor
        )

        self.assertEqual(
            expected_email,
            self.testStudent.advisor_email
        )

    def testAdvisorBlank(self):
        test_advisor = ''
        expected_email = ''
        expected_name = ''

        self.testStudent.set_by_column(
            Student.DataFormat.ADVISOR,
            test_advisor
        )

        self.assertEqual(
            expected_email,
            self.testStudent.advisor_email
        )

        self.assertEqual(
            expected_name,
            self.testStudent.advisor
        )

    def testAdvisorName(self):
        test_advisor = 'Advisor Guy 1 (howdy@tamu.edu )'
        expected_name = 'Advisor Guy 1'

        self.testStudent.set_by_column(
            Student.DataFormat.ADVISOR,
            test_advisor
        )

        self.assertEqual(
            expected_name,
            self.testStudent.advisor
        )

    def testAdvisorNameWithParens(self):
        test_advisor = 'Advisor (Nickname) Guy 1 (nickname@tamu.edu)'
        expected_name = 'Advisor (Nickname) Guy 1'

        self.testStudent.set_by_column(
            Student.DataFormat.ADVISOR,
            test_advisor
        )

        self.assertEqual(
            expected_name,
            self.testStudent.advisor
        )


    def testPlannedHours(self):
        test_hrs = 9
        expected_hrs = 9

        self.testStudent.set_by_column(
            Student.DataFormat.PLANNED_HOURS,
            test_hrs
        )

        self.assertEqual(
            expected_hrs,
            self.testStudent.hours_enrolled
        )

    def testDegreeTypePhd(self):
        test_deg_type_string = 'PhD'
        expected_deg_type = DegreeType.PHD

        self.testStudent.set_by_column(
            Student.DataFormat.DEGREE_TYPE,
            test_deg_type_string
        )

        self.assertEqual(
            expected_deg_type,
            self.testStudent.degree_type
        )

    def testDegreeTypeMastersThesis(self):
        test_deg_type_string = 'Masters (Thesis)'
        expected_deg_type = DegreeType.MASTERS_THESIS

        self.testStudent.set_by_column(
            Student.DataFormat.DEGREE_TYPE,
            test_deg_type_string
        )

        self.assertEqual(
            expected_deg_type,
            self.testStudent.degree_type
        )

    def testDegreeTypeMastersNonThesis(self):
        test_deg_type_string = 'Masters (Non-Thesis)'
        expected_deg_type = DegreeType.MASTERS_NON_THESIS

        self.testStudent.set_by_column(
            Student.DataFormat.DEGREE_TYPE,
            test_deg_type_string
        )

        self.assertEqual(
            expected_deg_type,
            self.testStudent.degree_type
        )

    def testRankedCourseChoice(self):
        test_courses = 'CSCE 121 (Programming Fundamentals 1)'
        expected_courses = ['121']
        self.testStudent = Student.get_empty_model()
        self.testStudent.set_by_column(
            Student.DataFormat.FIRST_CHOICE_COURSE,
            test_courses
        )

        self.assertListEqual(
            expected_courses,
            self.testStudent.ranked_ta_preference
        )

    def testMultipleRankedCourses(self):
        test_courses = [
            'CSCE 121 (Programming Fundamentals 1)',
            'CSCE 222 (Discrete Mathematics)',
            'CSCE 489',
            'CSCE 121'
        ]
        expected_courses = ['121', '222', '489', '121']
        self.testStudent = Student.get_empty_model()

        for course in test_courses:
            self.testStudent.set_by_column(
                "Nth Choice Course",
                course
            )

        self.assertListEqual(
            expected_courses,
            self.testStudent.ranked_ta_preference
        )

    def testGPA(self):
        test_gpa = 3.75
        expected_gpa = 3.75

        self.testStudent.set_by_column(
            Student.DataFormat.GPA,
            test_gpa
        )

        self.assertEqual(
            expected_gpa,
            self.testStudent.gpa
        )

    def testCitizenshipStripped(self):
        test_country = 'United Pineapple States \n'
        expected_country = test_country.strip()

        self.testStudent.set_by_column(
            Student.DataFormat.CITIZENSHIP,
            test_country
        )

        self.assertEqual(
            expected_country,
            self.testStudent.country_of_citizenship
        )

    def testEnglCertLevel(self):
        test_engl_lvl = 1
        expected_engl_lvl = 1

        self.testStudent.set_by_column(
            Student.DataFormat.ENGL_CERTIFICATION_LVL,
            test_engl_lvl
        )

        self.assertEqual(
            expected_engl_lvl,
            self.testStudent.english_certification_level
        )

    def testCoursesAtTamu(self):
        test_courses = 'CSCE 121 (Programming Fundamentals 1),' \
                       'CSCE 222 (Discrete Mathematics),' \
                       'CSCE 489,' \
                       'CSCE 121,'
        expected_courses = ['121', '222', '489', '121']
        self.testStudent = Student.get_empty_model()

        self.testStudent.set_by_column(
            Student.DataFormat.COURSES_AT_TAMU,
            test_courses
        )

        self.assertListEqual(
            expected_courses,
            self.testStudent.courses_taken_tamu
        )

    def testCoursesAtOtherUniv(self):
        test_courses = 'CSCE 121 (Programming Fundamentals 1),'\
            'CSCE 222 (Discrete Mathematics),'\
            'CSCE 489,'\
            'CSCE 121,'
        expected_courses = ['121', '222', '489', '121']
        self.testStudent = Student.get_empty_model()

        self.testStudent.set_by_column(
            Student.DataFormat.COURSES_AT_OTHER,
            test_courses
        )

        self.assertListEqual(
            expected_courses,
            self.testStudent.courses_taken_other_university
        )

    def testCoursesTAd(self):
        test_courses = 'CSCE 121 (Programming Fundamentals 1),' \
                       'CSCE 222 (Discrete Mathematics),' \
                       'CSCE 489,' \
                       'CSCE 121,'
        expected_courses = ['121', '222', '489', '121']
        self.testStudent = Student.get_empty_model()

        self.testStudent.set_by_column(
            Student.DataFormat.COURSES_TAd,
            test_courses
        )

        self.assertListEqual(
            expected_courses,
            self.testStudent.courses_ta
        )

    def testAppliedForTA(self):
        test_positions = 'TA, Random Pos 1, Random Pos 2'

        self.testStudent.set_by_column(
            Student.DataFormat.POSITIONS_APPLIED_FOR,
            test_positions
        )

        self.assertTrue(self.testStudent.ta_applied)
        self.assertFalse(self.testStudent.senior_grader_applied)
        self.assertFalse(self.testStudent.grader_applied)

    def testAppliedForSeniorGrader(self):
        test_positions = 'Random Pos 1, Senior Grader, Random Pos 2'

        self.testStudent.set_by_column(
            Student.DataFormat.POSITIONS_APPLIED_FOR,
            test_positions
        )

        self.assertFalse(self.testStudent.ta_applied)
        self.assertTrue(self.testStudent.senior_grader_applied)
        self.assertFalse(self.testStudent.grader_applied)

    def testAppliedForGrader(self):
        test_positions = 'Random Pos 1, Grader, Random Pos 2'

        self.testStudent.set_by_column(
            Student.DataFormat.POSITIONS_APPLIED_FOR,
            test_positions
        )

        self.assertFalse(self.testStudent.ta_applied)
        self.assertFalse(self.testStudent.senior_grader_applied)
        self.assertTrue(self.testStudent.grader_applied)


class TestCleanDataFrame(unittest.TestCase):

    testColumns: List[str]

    def setUp(self) -> None:
        self.testColumns = ['col 1', 'col 2\n', 'col3', Student.DataFormat.GPA]

    def testColumnHasNewline(self):
        expected_columns = [col.replace('\n', '') for col in self.testColumns]
        test_df = pd.DataFrame(columns=self.testColumns)

        result = Student.cleanup_input_frame(test_df)

        self.assertListEqual(
            list(result.columns.array),
            expected_columns
        )

    def testGPADefaultSet(self):
        test_df = pd.DataFrame(columns=self.testColumns, data=[['', '', '', float('nan')]])

        result = Student.cleanup_input_frame(test_df)

        self.assertEqual(
            result[Student.DataFormat.GPA].iloc[0],
            Student.DataFormat.DEFAULT_GPA
        )
