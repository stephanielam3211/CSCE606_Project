from models import Student, Course
from util.Weighting import Buckets, Weights

# constants
MINIMUM_REQUIRED_HOURS = 9
BASE = 10
NUM_BUCKETS = 5


def bucket_value(num_bucket: int) -> int:
    """
    bucket_value: returns value for the bucket based on input
    :param num_bucket: the bucket number. Range of 1 to 5 - Integer
    :return: overall bucket value based on an inverse relation with num_bucket
    bucket 5 = 1
    bucket 4 = 10
    bucket 3 = 100
    bucket 2 = 1000
    bucket 1 = 10000
    """
    return BASE**(NUM_BUCKETS - num_bucket)


# computer score override for priority and deny list
def score_based_on_priority_and_deny_list(student, course):
    if student.email in course.ta_priority_list:
        return bucket_value(Buckets.HAS_PROF_PREF)
    elif student.email in course.ta_deny_list:
        return Weights.NINFINITY
    return Weights.NO_EFFECT
    

# compute course preference
def score_ranked_ta_preference(student: Student, course: Course) -> int:
    """
    Computes Course preferences based on student input
    :param student: Student object that is used to take into account preferences
    :param course: Course object that holds course numbers to compare with student preferences
    :return: Returns bucket number based on student preference. If course is ranked highly, it is placed in
    higher bucket. If not, then placed in lower bucker or given no effect.
    """
    pos_preference = -1
    for course_number in course.course_numbers:
        for idx, student_preference in enumerate(student.ranked_ta_preference):
            if course_number == student_preference:
                pos_preference = idx
                break
    if 0 <= pos_preference <= 1:
        # if it is in their top 2 preferences, we put it in bucket 3
        # if it is their 1st preference, 2*bucket_value, otherwise 1
        return (2 - pos_preference) * bucket_value(Buckets.TA_RANKED_COURSE_TOP_2)
    elif pos_preference >= 2:
        return bucket_value(Buckets.TA_RANKED_COURSE_OTHER)
    return Weights.NO_EFFECT


def score_gpa(student: Student, _: Course = None) -> int:
    """
    Determines bucket based on student GPA. If GPA is higher than or equal to a 3.5,
    then higher bucket
    :param student: Student obj that is used to get GPA
    :param _: unused Course obj added for compatibility with generic functions.
    :return: Bucket int value based on GPA, if lower than 3.5 then no effect.
    """
    if student.gpa >= 3.5:
        return bucket_value(Buckets.GPA_ABOVE_3_5)
    return Weights.NO_EFFECT


def score_english_certification(student: Student, course: Course) -> int:
    """
    Determines bucket based on Students English Certification level. If 1 or 2, then delivers
    appropriate bucket. If Level 3, it determines if the course is being taught by the student's advisor.
    If it is, it returns infinity. If it is not, it returns negative infinity
    :param student: Student obj that is used to get English Certification
    :param course: Course obj to determine if the course is taught by advisor
    :return: Bucket value based on English certification. Otherwise determine if advisor
    """
    if student.english_certification_level == 1:
        return bucket_value(Buckets.ENGL_LEVEL_1)
    elif student.english_certification_level == 2:
        return bucket_value(Buckets.ENGL_LEVEL_2)
    else:
        if student.advisor_email == course.faculty_email:
            return Weights.INFINITY
        else:
            return Weights.NINFINITY


def score_degree_type(student: Student, _: Course = None) -> int:
    """
    Determines degree type to ensure preference is given to Phd Students
    :param student: Student obj that is used to get Student degree type
    :param _: Unused Course obj for compatibility with generics
    :return: Bucket value if PhD. Otherwise, return no effect to the weight
    """
    if student.degree_type == Student.DegreeType.PHD:
        return bucket_value(Buckets.DEG_TYPE_PHD)
    return Weights.NO_EFFECT


def score_previous_ta_for_course(student: Student, course: Course) -> int:
    """
    Determines score based on if student previously TA'd for course.
    :param student: Student obj with courses the student has TA'd for
    :param course: Course obj that is used to compare with the courses the student has
    TA'd for
    :return: Value for bucket based on Student experience. Bucket valued higher if TA has experience
    in course, otherwise no effect added to weight.
    """
    for student_ta_course in student.courses_ta:
        if student_ta_course in course.course_numbers:
            return bucket_value(Buckets.PREV_TA_FOR_THIS_COURSE)
    return Weights.NO_EFFECT


def score_courses_taken_at_tamu(student: Student, course: Course) -> int:
    """
    Determines score based on if student previously taken course at TAMU.
    :param student: Student obj with courses the student has taken
    :param course: Course obj that is used to compare with the courses the student has taken
    :return: Bucket value based on student's previous courses. If course is taken, return
    appropriate bucket value, or no effect if course is not taken
    """
    for student_taken_course in student.courses_taken_tamu:
        if student_taken_course in course.course_numbers:
            return bucket_value(Buckets.HAS_TAKEN_COURSE)
    return Weights.NO_EFFECT


def score_prereqs(student: Student, course: Course) -> int:
    """
    Determine if the student meets the prereqs for a given course.
    If they meet the prereqs with courses they've taken at TAMU alone, they get the highest weight for this function
    If they meet the prereqs with some combo of tamu courses and outside courses, they get the next highest weight
    Else the prereqs are not met, so they get no weight from this function
    :param student: Student
    :param course: Course
    :return: Weight as described above.
    """

    is_taken = [False for _ in course.preferred_prerequisites]
    for i, prereq in enumerate(course.preferred_prerequisites):
        if prereq in student.courses_taken_tamu:
            is_taken[i] = True

    if all(is_taken):
        return bucket_value(Buckets.ALL_PREREQS_AT_TAMU)

    # all satisfied
    for i, prereq in enumerate(course.preferred_prerequisites):
        if prereq in student.courses_taken_other_university:
            is_taken[i] = True
    if all(is_taken):
        return bucket_value(Buckets.ALL_PREREQS_ANY)
    # not all satisfied
    return Weights.NO_EFFECT


def is_instructor_and_ta_same(student: Student, course: Course) -> bool:
    """
    If the student under consideration is the instructor for the course, we want to avoid that matching
    This happens when Grad students also teach a class themselves. This helper function uses
    emails to determine if the TA under consideration is also the instructor for the course
    :param student: the student under consideration
    :param course: the course under consideration
    :return: True if student and course instructor are the same, false otherwise
    """

    return student.email == course.faculty_email


def is_below_enrollment_requirement(student: Student, _: Course) -> bool:
    """
    Check If the student under consideration is below the minimum required hours
    :param student: The student under consideration
    :param _: Course object. Kept for compatibility with generic functions that expect student,course params
    :return: True if the student fails to meet the minimum. False otherwise.
    """
    return student.hours_enrolled < MINIMUM_REQUIRED_HOURS


def is_avoidable_demotion(student: Student, _: Course) -> bool:
    """
    We consider a demotion avoidable if the applicant:
        - has enough hours to be considered for a TA role
        - has TA'd at least 1 course before

    If they've been employed as a TA before, we do not want to demote them to grader unless they don't meet the hours
    requirement to be a TA

    :param student: the student under consideration
    :param _: Course object. Kept for compatibility with generic functions that expect student,course params
    :return: True if the student's demotion is avoidable as described above, false otherwise.
    """

    return len(student.courses_ta) > 0 and student.hours_enrolled >= MINIMUM_REQUIRED_HOURS


def is_unqualified_for_wc_course(student: Student, course: Course) -> bool:
    """
    For Writing or Comms intensive courses, we require english level 1 or lower to be considered for a grading role
    :param student: the student under consideration
    :param course: the course under consideration
    :return: True if the course is a writing course, and the student is unqualified. False otherwise
    """

    return course.is_writing_or_comm_course and student.english_certification_level > 1
