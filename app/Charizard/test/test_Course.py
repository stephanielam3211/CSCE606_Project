import unittest
from models.Course import Course


class TestSetByColumn(unittest.TestCase):

    testCourse: Course

    @classmethod
    def setUpClass(cls) -> None:
        cls.testCourse = Course.get_empty_model()

    def testCourseName(self):
        test_course_name = "test course name"

        self.testCourse.set_by_column(
            Course.DataFormat.COURSE_NAME,
            test_course_name
        )

        self.assertEqual(
            self.testCourse.course_name,
            test_course_name
        )

    def testCourseNumbersNonWC(self):
        test_course_number_string = "101"
        test_course_number = "101"

        self.testCourse.set_by_column(
            Course.DataFormat.COURSE_NUMS,
            test_course_number_string
        )

        self.assertTrue(
            test_course_number in self.testCourse.course_numbers,
            msg="Course Number not set correctly."
        )
        self.assertFalse(
            self.testCourse.is_writing_or_comm_course,
            msg="Course mis-identified as writing or communications course."
        )

    def testCourseNumberC(self):
        test_course_number_string = '101C'
        expected_course_number = '101'

        self.testCourse.set_by_column(
            Course.DataFormat.COURSE_NUMS,
            test_course_number_string
        )

        self.assertTrue(
            expected_course_number in self.testCourse.course_numbers,
            msg="Course Number not set correctly"
        )
        self.assertTrue(
            self.testCourse.is_writing_or_comm_course,
            msg="Failed to identify course as writing or communications course."
        )

    def testCourseNumberW(self):
        test_course_number_string = '101W'
        expected_course_number = '101'

        self.testCourse.set_by_column(
            Course.DataFormat.COURSE_NUMS,
            test_course_number_string
        )

        self.assertTrue(
            expected_course_number in self.testCourse.course_numbers,
            msg="Course Number not set correctly"
        )
        self.assertTrue(
            self.testCourse.is_writing_or_comm_course,
            msg="Failed to identify course as writing or communications course."
        )

    def testStackedCourseNonWC(self):
        test_course_number_string = "463/612"
        expected_results = ["463", "612"]

        self.testCourse.set_by_column(
            Course.DataFormat.COURSE_NUMS,
            test_course_number_string
        )

        self.assertListEqual(
            expected_results,
            self.testCourse.course_numbers,
            msg="Failed to parse stacked course numbers"
        )
        self.assertFalse(
            self.testCourse.is_writing_or_comm_course,
            msg="Incorrectly declared course type as Writing or Communication."
        )

    def testStackedCourseWC(self):
        test_course_number_string = "482/483C"
        expected_results = ["482", "483"]

        self.testCourse.set_by_column(
            Course.DataFormat.COURSE_NUMS,
            test_course_number_string
        )

        self.assertListEqual(
            expected_results,
            self.testCourse.course_numbers,
            msg="Failed to parse stacked course numbers."
        )
        self.assertTrue(
            self.testCourse.is_writing_or_comm_course,
            msg="Failed to identify Communication course."
        )

    def testSectionId(self):
        expected_section_id = "500"

        self.testCourse.set_by_column(
            Course.DataFormat.SECTION_IDS,
            expected_section_id
        )

        self.assertTrue(expected_section_id in self.testCourse.section_ids)

    def testSectionIdSlash(self):
        section_id = "200/500"
        expected_section_id1 = "200"
        expected_section_id2 = "500"
        self.testCourse.set_by_column(
            Course.DataFormat.SECTION_IDS,
            section_id
        )

        self.assertTrue(expected_section_id1 in self.testCourse.section_ids)
        self.assertTrue(expected_section_id2 in self.testCourse.section_ids)

    def testSectionIdDash(self):
        expected_section_id = "200-204"
        self.testCourse.set_by_column(
            Course.DataFormat.SECTION_IDS,
            expected_section_id
        )

        self.assertTrue(expected_section_id in self.testCourse.section_ids)

    def testSectionIdDashSlash(self):
        section_id = "200-204/500"
        expected_section_id1 = "200-204"
        expected_section_id2 = "500"
        self.testCourse.set_by_column(
            Course.DataFormat.SECTION_IDS,
            section_id
        )

        self.assertTrue(expected_section_id1 in self.testCourse.section_ids)
        self.assertTrue(expected_section_id2 in self.testCourse.section_ids)

    def testInstructorNoStrip(self):
        expected_test_name = "Miss Reveille"
        self.testCourse.set_by_column(
            Course.DataFormat.INSTRUCTOR,
            expected_test_name
        )

        self.assertEqual(
            self.testCourse.instructor,
            expected_test_name
        )

    def testInstructorStrip(self):
        test_name = "   Miss Reveille "
        expected_test_name = "Miss Reveille"
        self.testCourse.set_by_column(
            Course.DataFormat.INSTRUCTOR,
            test_name
        )

        self.assertEqual(
            self.testCourse.instructor,
            expected_test_name
        )

    def testFactEmail(self):
        expected_test_email = "miss.rev@tamu.edu"
        self.testCourse.set_by_column(
            Course.DataFormat.FACT_EMAIL,
            expected_test_email
        )

        self.assertEqual(
            self.testCourse.faculty_email,
            expected_test_email
        )

    def testFactEmailUppercase(self):
        test_email = "Miss.Rev@Tamu.Edu"
        expected_test_email = "miss.rev@tamu.edu"
        self.testCourse.set_by_column(
            Course.DataFormat.FACT_EMAIL,
            test_email
        )

        self.assertEqual(
            self.testCourse.faculty_email,
            expected_test_email
        )

    def testFactEmailStrip(self):
        test_email = "  miss.rev@tamu.edu "
        expected_test_email = "miss.rev@tamu.edu"
        self.testCourse.set_by_column(
            Course.DataFormat.FACT_EMAIL,
            test_email
        )

        self.assertEqual(
            self.testCourse.faculty_email,
            expected_test_email
        )

    def testNumTAsNeededOne(self):
        expected_num_tas = 1

        self.testCourse.set_by_column(
            Course.DataFormat.NUM_TA_NEEDED,
            expected_num_tas
        )

        self.assertEqual(
            expected_num_tas,
            self.testCourse.tas_needed
        )

    def testNumTAsNeededHalf(self):
        test_num_tas = 0.5
        expected_num_needed = 1

        self.testCourse.set_by_column(
            Course.DataFormat.NUM_TA_NEEDED,
            test_num_tas
        )

        self.assertEqual(
            expected_num_needed,
            self.testCourse.tas_needed
        )

    def testSeniorGradersNeeded(self):
        expected_senior_graders = 2

        self.testCourse.set_by_column(
            Course.DataFormat.NUM_SNR_GRADER_NEEDED,
            expected_senior_graders
        )

        self.assertEqual(
            expected_senior_graders,
            self.testCourse.senior_grader_needed
        )

    def testGradersNeeded(self):
        expected_graders = 1

        self.testCourse.set_by_column(
            Course.DataFormat.NUM_GRADER_NEEDED,
            expected_graders
        )

        self.assertEqual(
            expected_graders,
            self.testCourse.graders_needed
        )

    def testProfPreReqs(self):
        test_pre_req_list = "121,222,314,315,"
        expected_list = ["121", "222", "314", "315"]

        self.testCourse.set_by_column(
            Course.DataFormat.PROF_PRE_REQS,
            test_pre_req_list
        )

        self.assertListEqual(
            expected_list,
            self.testCourse.preferred_prerequisites
        )


class TestAugmentCoursesWithPrefs(unittest.TestCase):
    # TODO: @dhruv414
    pass
