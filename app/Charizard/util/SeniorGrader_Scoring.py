from models.Course import Course
from models.Student import Student
from util import Scoring
from util.Weighting import Weights
from typing import List

def compute_senior_grader_matching_weight(student: Student, course: Course):
    weight = 0
    if Scoring.is_instructor_and_ta_same(student, course):
        return Weights.NINFINITY

    # TODO: Check that this logic is required for Senior Grader
    if student.courses_ta and student.hours_enrolled >= 9:
        return Weights.NINFINITY

    if course.is_writing_or_comm_course and student.english_certification_level > 1:
        return Weights.NINFINITY
    
    if student.email.lower().strip() in [email.lower().strip() for email in course.ta_deny_list]:
        return Weights.NINFINITY

    weight += Scoring.score_ranked_ta_preference(student, course)
    weight += Scoring.score_gpa(student)
    weight += Scoring.score_courses_taken_at_tamu(student, course)
    weight += Scoring.score_based_on_priority_and_deny_list(student, course)
    weight += Scoring.score_prereqs(student, course)
    
    return weight


def compute_senior_grader_weight_matrix(students: List[Student], courses: List[Course]) -> List[List[int]]:
    return [[compute_senior_grader_matching_weight(student, course) for course in courses] for student in students]