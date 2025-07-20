from models.Course import Course
from models.Student import Student
import util.Scoring as Scoring
from util.Weighting import Weights
from typing import List


def compute_ta_matching_weight(student: Student, course: Course) -> int:
    """
    Computes and returns the weight for the edge from a student to a specific course
    Based on above functions
    :param student: Student object to be used as input in calculating functions
    :param course: Course object to be used as input when needed
    :return: Appropriate weight for an edge between a student and a course section,
    Is negative infinity if the student is under the minimum required hours
    """
    #print("[DEBUG] Entered TA matching logic.")
    weight = 0
    # needs to be taking at least this many hours
    if student.hours_enrolled < Scoring.MINIMUM_REQUIRED_HOURS or Scoring.is_instructor_and_ta_same(student, course):
        print(f"[SKIP] {student.email} below hour requirement")
        return Weights.NINFINITY
    
    if student.email.lower().strip() in [email.lower().strip() for email in course.ta_deny_list]:
        print(f"[SKIP] {student.email} is in TA deny list for {course.course_numbers}")
        return Weights.NINFINITY
    
    #print(f"Checking if student '{student.email}' is in deny list: {course.ta_deny_list}")


    weight += Scoring.score_ranked_ta_preference(student, course)
    weight += Scoring.score_gpa(student)
    weight += Scoring.score_english_certification(student, course)
    weight += Scoring.score_degree_type(student)
    weight += Scoring.score_previous_ta_for_course(student, course)
    weight += Scoring.score_courses_taken_at_tamu(student, course)
    weight += Scoring.score_based_on_priority_and_deny_list(student, course)
    
    weight += Scoring.score_prereqs(student, course)
        
    return weight


def compute_ta_weight_matrix(students: List[Student], courses: List[Course]) -> List[List[int]]:
    """
    Computes weights for all TAs and all course sections and delivers matrix to be used
    for algorithm
    :param students: List of Students from Input Form
    :param courses: List of Courses based on Professors preference
    :return: 2D matrix of TA weighting with each course and student
    """
    return [[compute_ta_matching_weight(student, course) for course in courses] for student in students]
