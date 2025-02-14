import unittest

from models import Professor
from models.Professor import ProfessorFeedback


class TestSetByColumn(unittest.TestCase):

    testProfessor: ProfessorFeedback
    testSelectedStudentEntry: str

    def setUp(self) -> None:
        self.testProfessor = ProfessorFeedback.get_empty_model()
        self.testSelectedStudentEntry = 'Long Student Name  (studentEmail@TAMU.eDu)'
        self.testSelectedStudentName = 'Long Student Name'
        self.testSelectedStudentEmail = 'studentemail@tamu.edu'

    def testTimestamp(self):
        test_timestamp = '3/24/2023 13:40:48'
        expected_timestamp = test_timestamp.strip()

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.TIMESTAMP,
            test_timestamp
        )

        self.assertEqual(
            expected_timestamp,
            self.testProfessor.timestamp
        )

    def testProfEmail(self):
        test_email = 'tEsTProfEmaiL@tamu.EDU '
        expected_email = test_email.lower().strip()

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.PROF_EMAIL,
            test_email
        )

        self.assertEqual(
            expected_email,
            self.testProfessor.professor_email
        )

    def testProfName(self):
        test_name = ' Test Prof Name  '
        expected_name = test_name.strip()

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.PROF_NAME,
            test_name
        )

        self.assertEqual(
            expected_name,
            self.testProfessor.professor_name
        )

    def testSelectedStudentName(self):
        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.SELECTED_STUDENT,
            self.testSelectedStudentEntry
        )

        self.assertEqual(
            self.testSelectedStudentName,
            self.testProfessor.selected_student_name
        )

    def testSelectedStudentEmail(self):
        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.SELECTED_STUDENT,
            self.testSelectedStudentEntry
        )

        self.assertEqual(
            self.testSelectedStudentEmail,
            self.testProfessor.selected_student_email
        )

    def testSelectedCourse(self):
        test_course_name = 'CSCE 121'
        expected_selected_course = '121'

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.SELECTED_COURSE,
            test_course_name
        )

        self.assertEqual(
            expected_selected_course,
            self.testProfessor.selected_course
        )

    def testSelectedCourseEmpty(self):
        test_course_name = 'CSCE NOT REAL'

        with self.assertRaises(Exception):
            self.testProfessor.set_by_column(
                ProfessorFeedback.DataFormat.SELECTED_COURSE,
                test_course_name
            )

    def testExtraComments(self):
        test_extra_comments = 'Test Comment '

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.EXTRA_COMMENTS,
            test_extra_comments
        )

        self.assertEqual(
            test_extra_comments,
            self.testProfessor.extra_comments
        )

    def testFeedbackWantToWork(self):
        test_want_to_work = 'I want to work with this student'
        expected_feedback: Professor.FeedbackType = Professor.FeedbackType.WANT_TO_WORK_WITH_STUDENT

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.FEEDBACK,
            test_want_to_work
        )

        self.assertEqual(
            expected_feedback,
            self.testProfessor.student_feedback
        )

    def testFeedbackRecommend(self):
        test_feedback_string = 'I would recommend this person as a good TA/grader'
        expected_feedback: Professor.FeedbackType = Professor.FeedbackType.RECOMMEND_AS_GOOD_TA_GRADER

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.FEEDBACK,
            test_feedback_string
        )

        self.assertEqual(
            expected_feedback,
            self.testProfessor.student_feedback
        )

    def testFeedbackDoNotRecommend(self):
        test_feedback_string = 'I would not recommend this student'
        expected_feedback: Professor.FeedbackType = Professor.FeedbackType.DO_NOT_RECOMMEND_STUDENT

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.FEEDBACK,
            test_feedback_string
        )

        self.assertEqual(
            expected_feedback,
            self.testProfessor.student_feedback
        )

    def testFeedbackDoNotWant(self):
        test_feedback_string = 'I do not want to work with this student'
        expected_feedback: Professor.FeedbackType = Professor.FeedbackType.DO_NOT_WANT_TO_WORK_WITH_STUDENT

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.FEEDBACK,
            test_feedback_string
        )

        self.assertEqual(
            expected_feedback,
            self.testProfessor.student_feedback
        )

    def testFeedbackValidWhitespace(self):
        test_feedback_string = '    \tI do not want to work with this student\n\n\t'
        expected_feedback: Professor.FeedbackType = Professor.FeedbackType.DO_NOT_WANT_TO_WORK_WITH_STUDENT

        self.testProfessor.set_by_column(
            ProfessorFeedback.DataFormat.FEEDBACK,
            test_feedback_string
        )

        self.assertEqual(
            expected_feedback,
            self.testProfessor.student_feedback
        )

    def testInvalidFeedbackString(self):
        test_feedback_string = 'Invalid Feedback String :('
        expected_feedback: Professor.FeedbackType = Professor.FeedbackType.DO_NOT_WANT_TO_WORK_WITH_STUDENT

        with self.assertRaises(Exception):
            self.testProfessor.set_by_column(
                ProfessorFeedback.DataFormat.FEEDBACK,
                test_feedback_string
            )
