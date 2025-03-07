from functools import reduce
from typing import Callable, List, Dict

import numpy as np
import pandas as pd
import scipy.optimize

from rich import print

import util.Config as Config
import util.TA_Scoring as TA_Scoring
from util import SeniorGrader_Scoring
from util import Grader_Scoring
from util import Weighting
from models.Course import Course
from models.Student import Student

from pathlib import Path

from util import Scoring


class MatchConfig:
    # Functions that determine if a Student,Course pair should be disqualified from matching
    disqualifiers: List[Callable[[Student, Course], bool]]
    # Scoring functions that alter the weight between a Student, Course pair
    weight_functions: List[Callable[[Student, Course], int]]
    # Bucket Assignments for this type of matching
    bucket_config: Weighting.Buckets

    def __init__(
            self,
            disqualifiers: List[Callable[[Student, Course], bool]],
            weight_functions: List[Callable[[Student, Course], int]],
            bucket_config: Weighting.Buckets = Weighting.Buckets()
    ):
        self.disqualifiers = disqualifiers
        self.weight_functions = weight_functions
        self.bucket_config = bucket_config


TA_MATCH_CONFIG = MatchConfig(
    disqualifiers=[
        Scoring.is_instructor_and_ta_same,
        Scoring.is_below_enrollment_requirement,
    ],
    weight_functions=[
        Scoring.score_ranked_ta_preference,
        Scoring.score_gpa,
        Scoring.score_english_certification,
        Scoring.score_degree_type,
        Scoring.score_previous_ta_for_course,
        Scoring.score_courses_taken_at_tamu,
        Scoring.score_based_on_priority_and_deny_list,
        Scoring.score_prereqs,
    ],
    bucket_config=Weighting.TaBuckets()
)

SENIOR_GRADER_MATCH_CONFIG = MatchConfig(
    disqualifiers=[
        Scoring.is_instructor_and_ta_same,
        Scoring.is_avoidable_demotion,
        Scoring.is_unqualified_for_wc_course,
    ],
    weight_functions=[
        Scoring.score_ranked_ta_preference,
        Scoring.score_gpa,
        Scoring.score_courses_taken_at_tamu,
        Scoring.score_based_on_priority_and_deny_list,
        Scoring.score_prereqs
    ],
    bucket_config=Weighting.SeniorGraderBuckets()
)

GRADER_MATCH_CONFIG = MatchConfig(
    disqualifiers=[
        Scoring.is_instructor_and_ta_same,
        Scoring.is_avoidable_demotion,
        Scoring.is_unqualified_for_wc_course,
    ],
    weight_functions=[
        Scoring.score_ranked_ta_preference,
        Scoring.score_gpa,
        Scoring.score_courses_taken_at_tamu,
        Scoring.score_based_on_priority_and_deny_list,
        Scoring.score_prereqs
    ],
    bucket_config=Weighting.GraderBuckets()
)


def compute_matching_weight(student: Student, course: Course, config: MatchConfig) -> int:

    for disqualifier in config.disqualifiers:
        if disqualifier(student, course):
            return Weighting.Weights.NINFINITY

    weight = sum(
        map(
            lambda fn: fn(student, course),
            config.weight_functions
        )
    )

    return weight


def compute_ta_matches(students_np, courses_np):
    # Ensure the output directory exists!
    Path(Config.OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
    with open(f'{Config.OUTPUT_DIR}/TA_Matches.csv', 'w') as ta_matches:
        # which courses do I want
        # the courses where .tas_needed >= 1

        # boolean mask for courses that need TAs
        students_that_want_ta = np.array([student.ta_applied for student in students_np])
        courses_that_need_ta = np.array([True if course.tas_needed >= 1 else False for course in courses_np])
        ta_weights_matrix = TA_Scoring.compute_ta_weight_matrix(students_np[students_that_want_ta], courses_np[courses_that_need_ta])

        matched_rows, matched_cols = scipy.optimize.linear_sum_assignment(ta_weights_matrix, maximize=True)
        header = 'Course Number,Section ID,Instructor Name,Instructor Email,Student Name,Student Email,Calculated Score\n'
        ta_matches.write(header)
        for student_idx, course_idx in zip(matched_rows, matched_cols):
            student = students_np[students_that_want_ta][student_idx]
            student.matched = True
            course = courses_np[courses_that_need_ta][course_idx]
            row = course.course_numbers[0] + ',' + course.section_ids[0] + ',' + course.instructor + ',' + course.faculty_email + ',' + (student.first_name + ' ' + student.last_name) + ',' + student.email + ',' + str(ta_weights_matrix[student_idx][course_idx]) + '\n'
            ta_matches.write(row)

        print('total cost for TAs: ', np.array(ta_weights_matrix)[matched_rows, matched_cols].sum())


def compute_senior_grader_matches(students_np, courses_np):
    with open(f'{Config.OUTPUT_DIR}/Senior_Grader_Matches.csv', 'w') as senior_grader_matches:
        # students that want senior grader role
        students_that_want_senior_grader = np.array([student.senior_grader_applied for student in students_np])
        students_that_have_been_matched = np.array([student.matched for student in students_np])
        students_mask = np.logical_and(students_that_want_senior_grader, np.logical_not(students_that_have_been_matched))

        # courses that need senior graders
        courses_that_need_senior_grader = np.array([True if course.senior_grader_needed >= 1 else False for course in courses_np])

        # Assumption is that there will only be 2 senior graders at most - TODO: make this generalized
        courses_with_multiple_senior_graders = np.array([True if course.senior_grader_needed > 1 else False for course in courses_np])
        courses_with_duplicated_courses_np = np.concatenate((courses_np[courses_that_need_senior_grader], courses_np[courses_with_multiple_senior_graders]))

        senior_grader_weights_matrix = SeniorGrader_Scoring.compute_senior_grader_weight_matrix(students_np[students_mask], courses_with_duplicated_courses_np)

        matched_rows, matched_cols = scipy.optimize.linear_sum_assignment(senior_grader_weights_matrix, maximize=True)
        header = 'Course Number,Section ID,Instructor Name,Instructor Email,Student Name,Student Email,Calculated Score\n'
        senior_grader_matches.write(header)
        for student_idx, course_idx in zip(matched_rows, matched_cols):
            student = students_np[students_mask][student_idx]
            assert not student.matched
            student.matched = True
            course = courses_with_duplicated_courses_np[course_idx]
            row = course.course_numbers[0] + ',' + course.section_ids[0] + ',' + course.instructor + ',' + course.faculty_email + ',' + (student.first_name + ' ' + student.last_name) + ',' + student.email + ',' + str(senior_grader_weights_matrix[student_idx][course_idx]) + '\n'
            senior_grader_matches.write(row)

        print('total cost for Senior Graders: ', np.array(senior_grader_weights_matrix)[matched_rows, matched_cols].sum())


def compute_grader_matches(students_np, courses_np):
    with open(f'{Config.OUTPUT_DIR}/Grader_Matches.csv', 'w') as grader_matches:
        # students that want grader role
        students_that_want_grader = np.array([student.grader_applied for student in students_np])
        students_that_have_been_matched = np.array([student.matched for student in students_np])
        students_mask = np.logical_and(students_that_want_grader, np.logical_not(students_that_have_been_matched))

        # courses that need graders
        courses_that_need_grader = np.array([True if course.graders_needed >= 1 else False for course in courses_np])

        # Assumption is that there will only be 2 graders at most
        courses_with_multiple_graders = np.array([True if course.graders_needed > 1 else False for course in courses_np])
        courses_with_duplicated_courses_np = np.concatenate((courses_np[courses_that_need_grader], courses_np[courses_with_multiple_graders]))

        grader_weights_matrix = Grader_Scoring.compute_grader_weight_matrix(students_np[students_mask], courses_with_duplicated_courses_np)

        matched_rows, matched_cols = scipy.optimize.linear_sum_assignment(grader_weights_matrix, maximize=True)
        header = 'Course Number,Section ID,Instructor Name,Instructor Email,Student Name,Student Email,Calculated Score\n'
        grader_matches.write(header)
        for student_idx, course_idx in zip(matched_rows, matched_cols):
            student = students_np[students_mask][student_idx]
            assert not student.matched
            student.matched = True
            course = courses_with_duplicated_courses_np[course_idx]
            row = course.course_numbers[0] + ',' + course.section_ids[0] + ',' + course.instructor + ',' + course.faculty_email + ',' + (student.first_name + ' ' + student.last_name) + ',' + student.email + ',' + str(grader_weights_matrix[student_idx][course_idx]) + '\n'
            grader_matches.write(row)

        print('total cost for Graders: ', np.array(grader_weights_matrix)[matched_rows, matched_cols].sum())


def compute_backups(students: List[Student], courses: List[Course], config: MatchConfig):

    columns = [
        "Course Number",
        "Section ID",
        "Instructor Name",
        "Instructor Email",
        "Student Name",
        "Student Email",
        "Calculated Score"
    ]

    df_dict: Dict[str, List] = {col: [] for col in columns}

    for course in courses:
        best_match = reduce(
            lambda a, b: a if a[0] > b[0] else b,
            map(
                lambda student: (compute_matching_weight(student, course, config), student),
                students
            )
        )
        best_weight: int = best_match[0]
        best_student: Student = best_match[1]

        df_dict["Course Number"].append(course.course_numbers[0])
        df_dict["Section ID"].append(course.section_ids[0])
        df_dict["Instructor Name"].append(course.instructor)
        df_dict["Instructor Email"].append(course.faculty_email)
        df_dict["Student Name"].append(best_student.first_name + ' ' + best_student.last_name)
        df_dict["Student Email"].append(best_student.email)
        df_dict["Calculated Score"].append(best_weight)

    backup_df: pd.DataFrame = pd.DataFrame(df_dict)

    return backup_df


def export_backups(students_np: np.array, courses_np: np.array):
    export_unassigned_applicants(students_np)

def ordinal(n):
    """Returns the ordinal string of a number (1st, 2nd, 3rd, 4th, etc.)."""
    if 10 <= n % 100 <= 20:
        suffix = "th"
    else:
        suffix = {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
    return f"{n}{suffix}"

def export_unassigned_applicants(students_np: np.array):
    unassigned_applicants = list(
        filter(lambda student: not student.matched, students_np)
    )

    columns = [
        "Timestamp",
        "Email Address",
        "First and Last Name",
        "UIN",
        "Phone Number",
        "How many hours do you plan to be enrolled in?",
        "Degree Type?",
    ] + [f"{ordinal(i+1)} Choice Course" for i in range(10)] + [
        "GPA",
        "Country of Citizenship?",
        "English language certification level?",
        "Which courses have you taken at TAMU?",
        "Which courses have you taken at another university?",
        "Which courses have you TAd for?",
        "Who is your advisor (if applicable)?",
        "What position are you applying for?"
    ]

    df_dict: Dict[str, List] = {col: [] for col in columns}

    for student in unassigned_applicants:
        df_dict["Timestamp"].append(student.timestamp)
        df_dict["Email Address"].append(student.email)
        df_dict["First and Last Name"].append(f"{student.first_name} {student.last_name}")
        df_dict["UIN"].append(student.uin)
        df_dict["Phone Number"].append(student.phone_number)
        df_dict["How many hours do you plan to be enrolled in?"].append(student.hours_enrolled)
        df_dict["Degree Type?"].append(student.degree_type.name if student.degree_type else "Unknown")

        # Handling TA preferences (ensure at most 10 choices, pad with empty if less)
        ta_choices = student.ranked_ta_preference[:10] + [""] * (10 - len(student.ranked_ta_preference))
        for i in range(10):
            df_dict[f"{ordinal(i+1)} Choice Course"].append(ta_choices[i])

        df_dict["GPA"].append(student.gpa)
        df_dict["Country of Citizenship?"].append(student.country_of_citizenship)
        df_dict["English language certification level?"].append(student.english_certification_level)
        df_dict["Which courses have you taken at TAMU?"].append(", ".join(student.courses_taken_tamu))
        df_dict["Which courses have you taken at another university?"].append(", ".join(student.courses_taken_other_university))
        df_dict["Which courses have you TAd for?"].append(", ".join(student.courses_ta))
        df_dict["Who is your advisor (if applicable)?"].append(student.advisor)

        # Setting applied position based on application fields
        positions = []
        if student.ta_applied:
            positions.append("TA")
        if student.senior_grader_applied:
            positions.append("Senior Grader")
        if student.grader_applied:
            positions.append("Grader")
        df_dict["What position are you applying for?"].append(", ".join(positions))

    unassigned_df: pd.DataFrame = pd.DataFrame(df_dict)
    Path(Config.OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
    unassigned_df.to_csv(f"{Config.OUTPUT_DIR}/Unassigned_Applicants.csv", index=False)
