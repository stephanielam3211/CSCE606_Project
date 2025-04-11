from __future__ import annotations

import re
from enum import Enum

from models.DataModel import DataModel


class FeedbackType(Enum):
    WANT_TO_WORK_WITH_STUDENT, RECOMMEND_AS_GOOD_TA_GRADER, DO_NOT_RECOMMEND_STUDENT, DO_NOT_WANT_TO_WORK_WITH_STUDENT = 1, 2, 3, 8


class ProfessorFeedback(DataModel):

    feedback_string_to_type = {
        "I want to work with this student" : FeedbackType.WANT_TO_WORK_WITH_STUDENT,
        "I would recommend this person as a good TA/grader": FeedbackType.RECOMMEND_AS_GOOD_TA_GRADER,
        "I would not recommend this student": FeedbackType.DO_NOT_RECOMMEND_STUDENT,
        "I do not want to work with this student": FeedbackType.DO_NOT_WANT_TO_WORK_WITH_STUDENT
    }

    class DataFormat:

        COURSE_NUM_REGEX = "\\d{3}"     # Matches 3 digit course numbers

        TIMESTAMP = "Timestamp"
        PROF_EMAIL = "Email Address"
        PROF_NAME = "Your Name (first and last)"
        SELECTED_STUDENT = "Select a TA/Grader"
        SELECTED_COURSE = "Course (e.g. CSCE 421)"
        FEEDBACK = "Feedback"
        EXTRA_COMMENTS = "Additional Feedback about this student"

        COLUMNS = [
            TIMESTAMP,
            PROF_EMAIL,
            PROF_NAME,
            SELECTED_STUDENT,
            SELECTED_COURSE,
            FEEDBACK,
            EXTRA_COMMENTS,
        ]

    def __init__(self, timestamp, professor_email, professor_name, selected_student_name, selected_student_email,
                 selected_course, student_feedback, extra_comments):
        self.timestamp = timestamp
        self.professor_email = professor_email
        self.professor_name = professor_name
        self.selected_student_name = selected_student_name
        self.selected_student_email = selected_student_email
        self.selected_course = selected_course
        self.student_feedback = student_feedback
        self.extra_comments = extra_comments

    def __eq__(self, other: ProfessorFeedback) -> bool:     # pragma: no cover
        return \
            type(self) == type(other) and \
            self.professor_name == other.professor_name and \
            self.professor_email == other.professor_email and \
            self.selected_student_name == other.selected_student_name and \
            self.selected_student_email == other.selected_student_email and \
            self.selected_course == other.selected_course and \
            self.student_feedback == other.student_feedback and \
            self.extra_comments == other.extra_comments

    def __str__(self):      # pragma: no cover
        return f'{self.timestamp=},' \
               f'{self.professor_name=},' \
               f'{self.professor_email=},' \
               f'{self.selected_student_name=},' \
               f'{self.selected_student_email=},' \
               f'{self.selected_course=},' \
               f'{self.student_feedback=},' \
               f'{self.extra_comments=}'

    @classmethod
    def get_empty_model(cls) -> ProfessorFeedback:
        return ProfessorFeedback(
            timestamp='',
            professor_email='',
            professor_name='',
            selected_student_name='',
            selected_student_email='',
            selected_course='',
            student_feedback=FeedbackType.WANT_TO_WORK_WITH_STUDENT,
            extra_comments=''
        )

    def set_by_column(self, field_title: str, value):
        if field_title == ProfessorFeedback.DataFormat.TIMESTAMP:
            self.timestamp = value.strip()
        elif field_title == ProfessorFeedback.DataFormat.PROF_EMAIL:
            self.professor_email = value.strip().lower()
        elif field_title == ProfessorFeedback.DataFormat.PROF_NAME:
            self.professor_name = value.strip()
        elif field_title == ProfessorFeedback.DataFormat.SELECTED_STUDENT:
            tokens = [token.strip() for token in value.split('(')]
            self.selected_student_name = ' '.join([token.strip() for token in tokens[0].split()])
            self.selected_student_email = '' if len(tokens) < 2 else tokens[1][:-1].strip().lower()
        elif field_title == ProfessorFeedback.DataFormat.SELECTED_COURSE:
            result = re.search(self.DataFormat.COURSE_NUM_REGEX, value)
            try:
                self.selected_course = result.group()
            except:
                raise Exception(f"invalid course selection '{value}'")
        elif field_title == ProfessorFeedback.DataFormat.EXTRA_COMMENTS:
            self.extra_comments = value
        elif field_title == ProfessorFeedback.DataFormat.FEEDBACK:
            value = value.strip()
            if value not in self.feedback_string_to_type:
                raise Exception(f"invalid professor feedback format '{value}'")
            self.student_feedback = self.feedback_string_to_type[value]
