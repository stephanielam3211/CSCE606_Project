from functools import reduce
from typing import Callable, List, Dict

import numpy as np
import pandas as pd
import scipy.optimize

from rich import print

import subprocess
import json

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
    Path(Config.OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

    students_that_want_ta = np.array([student.ta_applied for student in students_np])
    filtered_students = students_np[students_that_want_ta]

    expanded_courses = []
    for course in courses_np:
        if course.tas_needed >= 1:
            for _ in range(int(course.tas_needed)):
                expanded_courses.append(course)

    if not filtered_students.size:
        print(f"[WARNING] No students available for TA matching. Total students: {len(students_np)}, Filtered: 0")
        return
    if not expanded_courses:
        print(f"[WARNING] No courses need TAs. Total courses: {len(courses_np)}, Expanded: 0")
        return

    expanded_courses_np = np.array(expanded_courses)

    weight_matrix = TA_Scoring.compute_ta_weight_matrix(filtered_students, expanded_courses_np)

    weight_matrix = np.where(np.isneginf(weight_matrix), -1e6, weight_matrix)

    num_students, num_slots = weight_matrix.shape

    if num_students > num_slots:
        pad_width = num_students - num_slots
        weight_matrix = np.hstack((weight_matrix, np.full((num_students, pad_width), -1e6)))
        expanded_courses_np = np.concatenate([expanded_courses_np, [None] * pad_width])
    elif num_slots > num_students:
        pad_height = num_slots - num_students
        weight_matrix = np.vstack((weight_matrix, np.full((pad_height, num_slots), -1e6)))
        filtered_students = np.concatenate([filtered_students, [None] * pad_height])

    matched_rows, matched_cols = scipy.optimize.linear_sum_assignment(weight_matrix, maximize=True)

    json_rows = []
    for student_idx, course_idx in zip(matched_rows, matched_cols):
        student = filtered_students[student_idx]
        course = expanded_courses_np[course_idx]

        if student is None or course is None:
            continue

        student.matched = True

        row = {
            "Course Number": course.course_numbers[0],
            "Section ID": course.section_ids[0],
            "Instructor Name": course.instructor,
            "Instructor Email": course.faculty_email,
            "Student Name": f"{student.first_name} {student.last_name}",
            "Student Email": student.email,
            "UIN": student.uin,
            "Calculated Score": weight_matrix[student_idx][course_idx]
        }
        json_rows.append(row)

    json_path = f"{Config.OUTPUT_DIR}/TA_Matches.json"
    with open(json_path, "w") as f:
        json.dump(json_rows, f, indent=2)

    print(f"TA Matches JSON written to {json_path}")
    print('Total cost for TAs:', np.array(weight_matrix)[matched_rows, matched_cols].sum())


def compute_senior_grader_matches(students_np, courses_np):
    Path(Config.OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
   
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

    json_rows = []
    
    matched_rows, matched_cols = scipy.optimize.linear_sum_assignment(senior_grader_weights_matrix, maximize=True)
       
    for student_idx, course_idx in zip(matched_rows, matched_cols):
        student = students_np[students_mask][student_idx]
        assert not student.matched
        student.matched = True
        course = courses_with_duplicated_courses_np[course_idx]
        row = {
            "Course Number": course.course_numbers[0],
            "Section ID": course.section_ids[0],
            "Instructor Name": course.instructor,
            "Instructor Email": course.faculty_email,
            "Student Name": f"{student.first_name} {student.last_name}",
            "Student Email": student.email,
            "UIN": student.uin,
            "Calculated Score": senior_grader_weights_matrix[student_idx][course_idx]
        }

        json_rows.append(row)
        
    json_path = f"{Config.OUTPUT_DIR}/Senior_Grader_Matches.json"
    with open(json_path, "w") as f:
        json.dump(json_rows, f, indent=2)

    print(f"Senior Grader Matches JSON written to {json_path}")
    print('Total cost for Senior Graders:', np.array(senior_grader_weights_matrix)[matched_rows, matched_cols].sum())

def compute_grader_matches(students_np, courses_np):
    Path(Config.OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
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

    json_rows = []
        
    matched_rows, matched_cols = scipy.optimize.linear_sum_assignment(grader_weights_matrix, maximize=True)

    for student_idx, course_idx in zip(matched_rows, matched_cols):
        student = students_np[students_mask][student_idx]
        assert not student.matched
        student.matched = True
        course = courses_with_duplicated_courses_np[course_idx]
        row = {
            "Course Number": course.course_numbers[0],
            "Section ID": course.section_ids[0],
            "Instructor Name": course.instructor,
            "Instructor Email": course.faculty_email,
            "Student Name": f"{student.first_name} {student.last_name}",
            "Student Email": student.email,
            "UIN": student.uin,
            "Calculated Score": grader_weights_matrix[student_idx][course_idx]
        }

        json_rows.append(row)
        
    json_path = f"{Config.OUTPUT_DIR}/Grader_Matches.json"
    with open(json_path, "w") as f:
        json.dump(json_rows, f, indent=2)

    print(f"Grader Matches JSON written to {json_path}")
    print('Total cost for Graders:', np.array(grader_weights_matrix)[matched_rows, matched_cols].sum())

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
 
