from __future__ import annotations

import re
from enum import Enum

import pandas as pd
from typing import List

from models.DataModel import DataModel


class DegreeType(Enum):
    MASTERS_NON_THESIS, MASTERS_THESIS, PHD = 1, 2, 3


class Student(DataModel):

    class DataFormat:
        COURSE_NUMBER_REGEX = "\\d{3}"
        DEFAULT_GPA = 3.5

        TIMESTAMP = "Timestamp"
        EMAIL_ADDRESS = "Email Address"
        NAME = "First and Last Name"
        UIN = "UIN"
        PHONE_NUMBER = "Phone Number"
        PLANNED_HOURS = "How many hours do you plan to be enrolled in?"
        DEGREE_TYPE = "Degree Type?"
        FIRST_CHOICE_COURSE = "1st Choice Course"
        SECOND_CHOICE_COURSE = "2nd Choice Course"
        THIRD_CHOICE_COURSE = "3rd Choice Course"
        FOURTH_CHOICE_COURSE = "4th Choice Course"
        FIFTH_CHOICE_COURSE = "5th Choice Course"
        SIXTH_CHOICE_COURSE = "6th Choice Course"
        SEVENTH_CHOICE_COURSE = "7th Choice Course"
        EIGHTH_CHOICE_COURSE = "8th Choice Course"
        NINTH_CHOICE_COURSE = "9th Choice Course"
        TENTH_CHOICE_COURSE = "10th Choice Course"
        GPA = "GPA"
        CITIZENSHIP = "Country of Citizenship?"
        ENGL_CERTIFICATION_LVL = "English language certification level?"
        COURSES_AT_TAMU = "Which courses have you taken at TAMU?"
        COURSES_AT_OTHER = "Which courses have you taken at another university?"
        COURSES_TAd = "Which courses have you TAd for?"
        ADVISOR = "Who is your advisor (if applicable)?"
        POSITIONS_APPLIED_FOR = "What position are you applying for?"

        NUM_ALLOWED_CHOICES = 10
        COLUMNS=[
            TIMESTAMP,
            EMAIL_ADDRESS,
            NAME,
            UIN,
            PHONE_NUMBER,
            PLANNED_HOURS,
            DEGREE_TYPE,
            FIRST_CHOICE_COURSE,
            SECOND_CHOICE_COURSE,
            THIRD_CHOICE_COURSE,
            FOURTH_CHOICE_COURSE,
            FIFTH_CHOICE_COURSE,
            SIXTH_CHOICE_COURSE,
            SEVENTH_CHOICE_COURSE,
            EIGHTH_CHOICE_COURSE,
            NINTH_CHOICE_COURSE,
            TENTH_CHOICE_COURSE,
            GPA,
            CITIZENSHIP,
            ENGL_CERTIFICATION_LVL,
            COURSES_AT_TAMU,
            COURSES_AT_OTHER,
            COURSES_TAd,
            ADVISOR,
            POSITIONS_APPLIED_FOR
        ]

    def __init__(
            self, timestamp, email, first_name, last_name, uin, phone_number, hours_enrolled, degree_type,
            ranked_ta_preference, gpa, country_of_citizenship, english_certification_level, courses_taken_tamu,
            courses_taken_other_university, courses_ta, advisor, advisor_email,
            ta_applied, senior_grader_applied, grader_applied
    ):
        self.timestamp: str = timestamp
        self.email: str = email
        self.first_name: str = first_name
        self.last_name: str = last_name
        self.uin: str = uin
        self.phone_number: str = phone_number
        self.hours_enrolled: int = hours_enrolled
        self.degree_type: DegreeType = degree_type
        self.ranked_ta_preference: List[str] = ranked_ta_preference
        self.gpa = gpa
        self.country_of_citizenship = country_of_citizenship
        self.english_certification_level = english_certification_level
        self.courses_taken_tamu = courses_taken_tamu
        self.courses_taken_other_university = courses_taken_other_university
        self.courses_ta = courses_ta
        self.advisor: str = advisor
        self.advisor_email: str = advisor_email
        self.ta_applied = ta_applied
        self.senior_grader_applied = senior_grader_applied
        self.grader_applied = grader_applied
        # use during the algorithm
        self.matched = False

    def __eq__(self, other):    # pragma: no cover
        if type(other) != Student:
            return False

        return \
            self.first_name == other.first_name and \
            self.last_name == other.last_name and \
            self.uin == other.uin and \
            self.phone_number == other.phone_number and \
            self.hours_enrolled == other.hours_enrolled and \
            self.degree_type == other.degree_type and \
            self.ranked_ta_preference == other.ranked_ta_preference and \
            self.gpa == other.gpa and \
            self.country_of_citizenship == other.country_of_citizenship and \
            self.courses_taken_tamu == other.courses_taken_tamu and \
            self.courses_taken_other_university == other.courses_taken_other_university and \
            self.courses_ta == other.courses_ta and \
            self.advisor == other.advisor and \
            self.advisor_email == other.advisor_email and \
            self.ta_applied == other.ta_applied and \
            self.senior_grader_applied == other.senior_grader_applied and \
            self.grader_applied == other.grader_applied

    def __str__(self):  # pragma: no cover
        return \
            f'{self.timestamp=},' + \
            f'{self.email=},' + \
            f'{self.first_name=},' + \
            f'{self.last_name=},' + \
            f'{self.uin=},' + \
            f'{self.phone_number=},' + \
            f'{self.hours_enrolled=},' + \
            f'{self.degree_type=},' + \
            f'{self.ranked_ta_preference=},' + \
            f'{self.gpa=},' + \
            f'{self.country_of_citizenship=},' + \
            f'{self.english_certification_level=},' + \
            f'{self.courses_taken_tamu=},' + \
            f'{self.courses_taken_other_university=},' + \
            f'{self.courses_ta=},' + \
            f'{self.advisor=},' + \
            f'{self.advisor_email=},' + \
            f'{self.ta_applied=},' + \
            f'{self.senior_grader_applied=},' + \
            f'{self.grader_applied=}'

    def set_by_column(self, field_title: str, value):
        if field_title == Student.DataFormat.TIMESTAMP:
            self.timestamp = value
        elif field_title == Student.DataFormat.NAME:
            name_tokens = [token.strip() for token in value.split()]
            self.first_name = name_tokens[0]
            self.last_name = " ".join(name_tokens[1:])
        elif field_title == Student.DataFormat.EMAIL_ADDRESS:
            self.email = value.strip().lower()
        elif field_title == Student.DataFormat.UIN:
            self.uin = str(value).strip()
        elif field_title == Student.DataFormat.PHONE_NUMBER:
            self.phone_number = value.strip()
        elif field_title == Student.DataFormat.ADVISOR:
            # Advisor format (if present): Name (email)
            if len(value) > 0:
                advisor_tokens = [token for token in value.split('(')]
                self.advisor = '' if len(advisor_tokens) == 0 else '('.join(advisor_tokens[:-1]).strip()
                self.advisor_email = '' if len(advisor_tokens) <= 1 else advisor_tokens[-1][:-1].lower().strip()
        elif field_title == Student.DataFormat.PLANNED_HOURS:
            self.hours_enrolled = value
        elif field_title == Student.DataFormat.DEGREE_TYPE:
            if value == "PhD":
                self.degree_type = DegreeType.PHD
            elif value == "Masters (Thesis)":
                self.degree_type = DegreeType.MASTERS_THESIS
            else:
                self.degree_type = DegreeType.MASTERS_NON_THESIS
        elif "Choice Course" in field_title:
            course_num = self._parse_course_number(str(value))
            if len(course_num.strip()) > 0:
                self.ranked_ta_preference.append(course_num)
        elif field_title == Student.DataFormat.GPA:
            self.gpa = value
        elif field_title == Student.DataFormat.CITIZENSHIP:
            self.country_of_citizenship = value.strip()
        elif field_title == Student.DataFormat.ENGL_CERTIFICATION_LVL:
            self.english_certification_level = value
        elif field_title == Student.DataFormat.COURSES_AT_TAMU:
            self.courses_taken_tamu = re.findall(Student.DataFormat.COURSE_NUMBER_REGEX, str(value))
        elif field_title == Student.DataFormat.COURSES_AT_OTHER:
            self.courses_taken_other_university = re.findall(Student.DataFormat.COURSE_NUMBER_REGEX, str(value))
        elif field_title == Student.DataFormat.COURSES_TAd:
            self.courses_ta = re.findall(Student.DataFormat.COURSE_NUMBER_REGEX, str(value))
        elif field_title == Student.DataFormat.POSITIONS_APPLIED_FOR:
            positions = set([token.upper().strip() for token in value.split(',')])
            if 'TA' in positions:
                self.ta_applied = True
            if 'SENIOR GRADER' in positions:
                self.senior_grader_applied = True
            if 'GRADER' in positions:
                self.grader_applied = True

    @classmethod
    def _parse_course_number(cls, course: str) -> str:
        """
        Course info in our input forms can be in the form of a title ("CSCE 121 Intro to Programming")
        or a number ("121"). Either way, we want a function to extract the 3 digit course number
        :param course: The course title / number string
        :return: the 3 digit course number
        """
        result = re.search(Student.DataFormat.COURSE_NUMBER_REGEX, course)

        return result.group() if result else ''

    @classmethod
    def get_empty_model(cls) -> Student:
        return Student(
            timestamp='',
            email='',
            first_name='',
            last_name='',
            uin='',
            phone_number='',
            hours_enrolled=0,
            degree_type=DegreeType.MASTERS_NON_THESIS,
            ranked_ta_preference=[],
            gpa=0.0,
            country_of_citizenship='',
            english_certification_level=0,
            courses_taken_tamu=[],
            courses_taken_other_university=[],
            courses_ta=[],
            advisor='',
            advisor_email='',
            ta_applied=False,
            senior_grader_applied=False,
            grader_applied=False
        )

    @classmethod
    def cleanup_input_frame(cls, df: pd.DataFrame) -> pd.DataFrame:
        df.columns = df.columns.str.replace('\n', '')
        df[Student.DataFormat.GPA].fillna(
            Student.DataFormat.DEFAULT_GPA,
            inplace=True
        )

        return df
