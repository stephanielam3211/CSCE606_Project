#!/usr/bin/env python3

import os
import random
import sys
import numpy as np

from util import Matching

from rich import print
from rich.panel import Panel
from typing import List

from models.Student import Student
from models.Course import Course
from models.Professor import ProfessorFeedback
import util.Parsing as Parsing


def get_filename(file_objective: str, sys_arg: str = '') -> str:
    """
    Gets a valid filename from the user
    :param sys_arg: Argument that may have been passed by the user. Will check this first
    :param str file_objective: Describes the file we are prompting the user to enter
    :return: filepath entered by the user verified to exist
    """
    file = sys_arg

    if file != '' and not os.path.isfile(file):
        print(f'[red]No file found at {file}.')

    while file == '' or not os.path.isfile(file):
        file = input('Please enter a file name for the {}: '.format(file_objective))
        if os.path.isfile(file):
            break
        print(f'[red]No file found at {file}!')

    return file


def main():
    """
    Where the program starts. This function orchestrates the matching process at a high level.
    :return: n/a
    """

    print(Panel("Welcome to your TA/Grader Matching Program. You will need to have your student survey and professor "
                "feedback surveys to continue to the next step.", title="[blue]Howdy Doc!"))
    student_file_arg = '' if len(sys.argv) < 2 else sys.argv[1]
    student_file = get_filename("Student Survey", student_file_arg)
    students: List[Student] = Parsing.parse_models_from_csv(student_file, Student.get_empty_model())

    # shuffle students array to remove bias from initial ordering
    random.shuffle(students)

    courses_file_arg = '' if len(sys.argv) < 3 else sys.argv[2]
    courses_file = get_filename("Course Needs", courses_file_arg)
    courses: List[Course] = Parsing.parse_models_from_csv(courses_file, Course.get_empty_model())

    students_np = np.array(students)
    courses_np = np.array(courses)

    prof_prefs_file_arg = '' if len(sys.argv) < 4 else sys.argv[3]
    prof_prefs_file = get_filename("Professor Preferences", prof_prefs_file_arg)
    prof_prefs: List[ProfessorFeedback] = Parsing.parse_models_from_csv(prof_prefs_file, ProfessorFeedback.get_empty_model())

    Course.augment_courses_with_prefs(courses_np, prof_prefs)

    try:
        Matching.compute_ta_matches(students_np, courses_np)
    except Exception as e:
        print(f"[ERROR] TA matching failed: {e}")

    try:
        Matching.compute_senior_grader_matches(students_np, courses_np)
    except Exception as e:
        print(f"[ERROR] Senior Grader matching failed: {e}")

    try:
        Matching.compute_grader_matches(students_np, courses_np)
    except Exception as e:
        print(f"[ERROR] Grader matching failed: {e}")

    Matching.export_backups(students_np, courses_np)


if __name__ == '__main__':
    main()
