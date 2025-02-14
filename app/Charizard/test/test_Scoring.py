import unittest
from typing import List

from util import Scoring
from models.Course import Course
from models.Student import DegreeType, Student
from util.Weighting import Buckets, Weights


class BucketValue(unittest.TestCase):

    def testBucketValue(self):
        for i in range(Scoring.NUM_BUCKETS):
            self.assertEqual(
                Scoring.bucket_value(i),
                pow(Scoring.BASE, (Scoring.NUM_BUCKETS - i))
            )


class BelowEnrollmentDisqualifier(unittest.TestCase):

    def setUp(self) -> None:
        self.TestStudent: Student = Student.get_empty_model()
        self.TestCourse: Course = Course.get_empty_model()

    def testDisqualifyNotEnoughHours(self):
        self.TestStudent.hours_enrolled = Scoring.MINIMUM_REQUIRED_HOURS - 1

        result: bool = Scoring.is_below_enrollment_requirement(
            self.TestStudent,
            self.TestCourse
        )

        self.assertTrue(result)

    def testEnoughHoursNotDisqualified(self):
        self.TestStudent.hours_enrolled = Scoring.MINIMUM_REQUIRED_HOURS

        result: bool = Scoring.is_below_enrollment_requirement(
            self.TestStudent,
            self.TestCourse
        )

        self.assertFalse(result)


class AvoidableDemotionDisqualifier(unittest.TestCase):

    def setUp(self) -> None:
        self.TestStudent: Student = Student.get_empty_model()
        self.TestCourse: Course = Course.get_empty_model()

    def testAvoidableDemotion(self):
        self.TestStudent.courses_ta = ["TestCourse"]
        self.TestStudent.hours_enrolled = Scoring.MINIMUM_REQUIRED_HOURS

        result: bool = Scoring.is_avoidable_demotion(
            self.TestStudent,
            self.TestCourse
        )

        self.assertTrue(result)

    def testDemotionNotEnoughHours(self):
        self.TestStudent.courses_ta = ["TestCourse"]
        self.TestStudent.hours_enrolled = Scoring.MINIMUM_REQUIRED_HOURS - 1

        result: bool = Scoring.is_avoidable_demotion(
            self.TestStudent,
            self.TestCourse
        )

        self.assertFalse(result)

    def testNotADemotionNoExperience(self):
        self.TestStudent.courses_ta = []
        self.TestStudent.hours_enrolled = Scoring.MINIMUM_REQUIRED_HOURS

        result: bool = Scoring.is_avoidable_demotion(
            self.TestStudent,
            self.TestCourse
        )

        self.assertFalse(result)


class UnqualifiedForWcCourseDisqualifier(unittest.TestCase):

    def setUp(self) -> None:
        self.TestCourse: Course = Course.get_empty_model()
        self.TestStudent: Student = Student.get_empty_model()

    def testWritingIntensiveUnqualified(self):
        self.TestCourse.is_writing_or_comm_course = True
        self.TestStudent.english_certification_level = 2

        result: bool = Scoring.is_unqualified_for_wc_course(
            self.TestStudent,
            self.TestCourse
        )

        self.assertTrue(result)

    def testWritingIntensiveQualified(self):
        self.TestCourse.is_writing_or_comm_course = True
        self.TestStudent.english_certification_level = 1

        result: bool = Scoring.is_unqualified_for_wc_course(
            self.TestStudent,
            self.TestCourse
        )

        self.assertFalse(result)

    def testNotWritingIntensive(self):
        self.TestCourse.is_writing_or_comm_course = False
        self.TestStudent.english_certification_level = 2

        result_level_2: bool = Scoring.is_unqualified_for_wc_course(
            self.TestStudent,
            self.TestCourse
        )

        self.TestStudent.english_certification_level = 1

        result_level_1: bool = Scoring.is_unqualified_for_wc_course(
            self.TestStudent,
            self.TestCourse
        )

        self.assertFalse(result_level_1)
        self.assertFalse(result_level_2)


class PrereqsScoring(unittest.TestCase):

    def setUp(self) -> None:
        self.TestCourse: Course = Course.get_empty_model()
        self.TestStudent: Student = Student.get_empty_model()
        self.TestPrereqs: List[str] = ['TestPrereq1', 'TestPrereq2', 'TestPrereq3']
        self.TestCourse.preferred_prerequisites = self.TestPrereqs

    def testAllPrereqsSatisfiedAtTamu(self):
        self.TestStudent.courses_taken_tamu = [_ for _ in self.TestPrereqs]
        self.TestStudent.courses_taken_other_university = []

        result: int = Scoring.score_prereqs(
            self.TestStudent,
            self.TestCourse
        )

        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.ALL_PREREQS_AT_TAMU)
        )

    def testAllPrereqsSatisfiedMixedLocations(self):
        self.TestStudent.courses_taken_tamu = [_ for _ in self.TestPrereqs[:2]]
        self.TestStudent.courses_taken_other_university = [_ for _ in self.TestPrereqs[2:]]

        result: int = Scoring.score_prereqs(
            self.TestStudent,
            self.TestCourse
        )

        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.ALL_PREREQS_ANY)
        )

    def testAllPrereqsSatisfiedOutsideTamu(self):
        self.TestStudent.courses_taken_tamu = []
        self.TestStudent.courses_taken_other_university = [_ for _ in self.TestPrereqs]

        result: int = Scoring.score_prereqs(
            self.TestStudent,
            self.TestCourse
        )

        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.ALL_PREREQS_ANY)
        )

    def testMissingPrereqsHaveNoEffect(self):
        self.TestStudent.courses_taken_tamu = [self.TestPrereqs[0]]
        self.TestStudent.courses_taken_other_university = [self.TestPrereqs[1]]

        result: int = Scoring.score_prereqs(
            self.TestStudent,
            self.TestCourse
        )

        self.assertEqual(
            result,
            Weights.NO_EFFECT
        )


class PriorityAndDenyListScoring(unittest.TestCase):

    def setUp(self) -> None:
        self.TestCourse: Course = Course.get_empty_model()
        self.TestStudent: Student = Student.get_empty_model()

        self.TestPriorityStudentEmail: str = "Test Priority Student Email"
        self.TestDeniedStudentEmail: str = "Test Denied Student Email"
        self.TestUnmentionedStudentEmail: str = "Test Unmentioned Student Email"

    def testStudentInPriorityList(self):
        self.TestStudent.email = self.TestPriorityStudentEmail
        self.TestCourse.ta_priority_list = [self.TestPriorityStudentEmail]

        result: int = Scoring.score_based_on_priority_and_deny_list(
            self.TestStudent,
            self.TestCourse
        )

        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.HAS_PROF_PREF)
        )

    def testStudentInDenyList(self):
        self.TestStudent.email = self.TestDeniedStudentEmail
        self.TestCourse.ta_deny_list = [self.TestDeniedStudentEmail]

        result: int = Scoring.score_based_on_priority_and_deny_list(
            self.TestStudent,
            self.TestCourse
        )

        self.assertEqual(
            result,
            Weights.NINFINITY
        )

    def testStudentNotInPriorityOrDenyList(self):
        self.TestStudent.email = self.TestUnmentionedStudentEmail

        result: int = Scoring.score_based_on_priority_and_deny_list(
            self.TestStudent,
            self.TestCourse
        )

        self.assertEqual(
            result,
            Weights.NO_EFFECT
        )


class DegreeTypeScoring(unittest.TestCase):
    def testScoreDegreeType(self):
        degree_types_to_score = {
            DegreeType.MASTERS_THESIS: 0,
            DegreeType.MASTERS_NON_THESIS: 0,
            DegreeType.PHD: Scoring.bucket_value(1)
        }

        for deg_type in degree_types_to_score:
            test_student: Student = Student.get_empty_model()
            test_student.degree_type = deg_type
            self.assertEqual(
                Scoring.score_degree_type(test_student),
                degree_types_to_score[deg_type]
            )


class TestScoreRankedTAPreference(unittest.TestCase):
    testCourse: Course = None
    testStudent: Student = None
    testCourseNumberOne: str = 'TestCourseOne'
    testCourseNumberTwo: str = 'TestCourseTwo'
    testCourseNumberThree: str = 'TestCourseThree'

    @classmethod
    def setUpClass(cls) -> None:
        cls.testCourse = Course.get_empty_model()
        cls.testStudent = Student.get_empty_model()
        cls.testStudent.ranked_ta_preference = [
            cls.testCourseNumberOne,
            cls.testCourseNumberTwo,
            cls.testCourseNumberThree
        ]

    def testFirstChoice(self):
        self.testCourse.course_numbers = [self.testCourseNumberOne]
        result = Scoring.score_ranked_ta_preference(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            2 * Scoring.bucket_value(Buckets.TA_RANKED_COURSE_TOP_2)
        )

    def testSecondChoice(self):
        self.testCourse.course_numbers = [self.testCourseNumberTwo]
        result = Scoring.score_ranked_ta_preference(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            1 * Scoring.bucket_value(Buckets.TA_RANKED_COURSE_TOP_2)
        )

    def testOtherChoice(self):
        self.testCourse.course_numbers = [self.testCourseNumberThree]
        result = Scoring.score_ranked_ta_preference(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.TA_RANKED_COURSE_OTHER)
        )

    def testNotChosen(self):
        self.testCourse.course_numbers = ['TestCourseNotRankedByTA']
        result = Scoring.score_ranked_ta_preference(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            Weights.NO_EFFECT
        )


class TestScoreGPA(unittest.TestCase):
    testStudent: Student = None

    @classmethod
    def setUpClass(cls) -> None:
        cls.testStudent = Student.get_empty_model()

    def testGpaGreater3Pt5(self):
        self.testStudent.gpa = 4.0
        result = Scoring.score_gpa(self.testStudent)
        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.GPA_ABOVE_3_5)
        )

    def testGpaEq3Pt5(self):
        self.testStudent.gpa = 3.5
        result = Scoring.score_gpa(self.testStudent)
        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.GPA_ABOVE_3_5)
        )

    def testGpaLessThan3Pt5(self):
        self.testStudent.gpa = 3.2
        result = Scoring.score_gpa(self.testStudent)
        self.assertEqual(
            result,
            Weights.NO_EFFECT
        )


class TestScoreEnglishCertification(unittest.TestCase):
    testStudent: Student
    testCourse: Course
    testCourseInstructor: str = 'TestCourseInstructor'
    testNonInstructorAdvisor: str = 'TestNonInstructorAdvisor'

    @classmethod
    def setUpClass(cls) -> None:
        cls.testStudent = Student.get_empty_model()
        cls.testCourse = Course.get_empty_model()
        cls.testCourse.instructor = cls.testCourseInstructor

    def testEnglishLevel1(self):
        self.testStudent.english_certification_level = 1
        result = Scoring.score_english_certification(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.ENGL_LEVEL_1)
        )

    def testEnglishLevel2(self):
        self.testStudent.english_certification_level = 2
        result = Scoring.score_english_certification(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.ENGL_LEVEL_2)
        )

    def testEnglishLevelThreeOrHigherAdvisorsCourse(self):
        self.testStudent.english_certification_level = 3
        self.testStudent.advisor_email = self.testCourseInstructor
        self.testCourse.faculty_email = self.testCourseInstructor

        result = Scoring.score_english_certification(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            Weights.INFINITY
        )

    def testEnglishLevelThreeOrHigherNotAdvisorCourse(self):
        self.testStudent.english_certification_level = 3
        self.testCourse.faculty_email = self.testCourseInstructor
        self.testStudent.advisor_email = self.testNonInstructorAdvisor

        result = Scoring.score_english_certification(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            Weights.NINFINITY
        )


class TestScoreDegreeType(unittest.TestCase):
    testStudent: Student = None

    @classmethod
    def setUpClass(cls) -> None:
        cls.testStudent = Student.get_empty_model()

    def testDegreeTypePhD(self):
        self.testStudent.degree_type = DegreeType.PHD
        result = Scoring.score_degree_type(self.testStudent)

        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.DEG_TYPE_PHD)
        )

    def testDegreeTypeMastersNonThesis(self):
        self.testStudent.degree_type = DegreeType.MASTERS_NON_THESIS
        result = Scoring.score_degree_type(self.testStudent)

        self.assertEqual(
            result,
            Weights.NO_EFFECT
        )

    def testDegreeTypeMastersThesis(self):
        self.testStudent.degree_type = DegreeType.MASTERS_THESIS
        result = Scoring.score_degree_type(self.testStudent)

        self.assertEqual(
            result,
            Weights.NO_EFFECT
        )


class TestScorePreviousTAForCourse(unittest.TestCase):
    testCourse: Course = None
    testStudent: Student = None
    testCourseNumber: str

    @classmethod
    def setUpClass(cls) -> None:
        cls.testCourseNumber = 'TestCourseNumber'
        cls.testCourse = Course.get_empty_model()
        cls.testCourse.course_numbers = [cls.testCourseNumber]
        cls.testStudent = Student.get_empty_model()

    def testStudentHasTAdCourse(self):
        self.testStudent.courses_ta = [
            'RandomCourse',
            self.testCourseNumber
        ]
        result = Scoring.score_previous_ta_for_course(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            Scoring.bucket_value(Buckets.PREV_TA_FOR_THIS_COURSE)
        )

    def testStudentHasNotTAdCourse(self):
        self.testStudent.courses_ta = [
            'RandomCourse'
        ]
        result = Scoring.score_previous_ta_for_course(
            self.testStudent,
            self.testCourse
        )

        self.assertEqual(
            result,
            Weights.NO_EFFECT
        )


class TestCoursesTaken(unittest.TestCase):
    test_student: Student = None
    test_course: Course = None

    @classmethod
    def setUpClass(cls) -> None:
        cls.test_student: Student = Student.get_empty_model()
        cls.test_student.courses_taken_tamu = ['TestCourseNum']
        cls.test_course = Course.get_empty_model()

    def testStudentHasNotTakenCourse(self):
        self.test_course.course_numbers = ['NotTestCourseNum', 'NotTestCourseNum2']
        result = Scoring.score_courses_taken_at_tamu(self.test_student, self.test_course)

        self.assertEqual(result, 0)

    def testStudentHasTakenCourse(self):
        self.test_course.course_numbers = ['NotTestCourseNum', 'TestCourseNum']
        result = Scoring.score_courses_taken_at_tamu(self.test_student, self.test_course)

        self.assertEqual(result, Scoring.bucket_value(2))


class TestInstructorAndTASame(unittest.TestCase):
    testStudent: Student
    testCourse: Course
    testEmail: str = "TEST_EMAIL@TEST_DOMAIN.COM"

    @classmethod
    def setUpClass(cls) -> None:
        cls.testStudent = Student.get_empty_model()

        cls.testCourse = Course.get_empty_model()
        cls.testCourse.faculty_email = cls.testEmail

    def testStudentAndInstructorAreIdentical(self):
        self.testStudent.email = self.testEmail

        result = Scoring.is_instructor_and_ta_same(
            self.testStudent,
            self.testCourse
        )

        self.assertTrue(result)

    def testStudentAndInstructorAreDistinct(self):
        self.testStudent.email = "DISTINCT_EMAIL@TEST_DOMAIN.COM"

        result = Scoring.is_instructor_and_ta_same(
            self.testStudent,
            self.testCourse
        )

        self.assertFalse(result)


if __name__ == '__main__':
    unittest.main()
