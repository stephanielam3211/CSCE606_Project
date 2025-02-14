class Buckets:
    TA_RANKED_COURSE_TOP_2 = 3
    TA_RANKED_COURSE_OTHER = 4

    GPA_ABOVE_3_5 = 2

    ENGL_LEVEL_1 = 4
    ENGL_LEVEL_2 = 5

    DEG_TYPE_PHD = 1

    PREV_TA_FOR_THIS_COURSE = 1

    HAS_TAKEN_COURSE = 2

    HAS_PROF_PREF = 1

    ALL_PREREQS_AT_TAMU = 2
    ALL_PREREQS_ANY = 3


class TaBuckets(Buckets):

    def __init__(self):
        # override bucket values from Weighting.Buckets as desired...
        pass    # pragma: no cover


class SeniorGraderBuckets(Buckets):

    def __init__(self):
        # override bucket values from Weighting.Buckets as desired...
        pass    # pragma: no cover


class GraderBuckets(Buckets):

    def __init__(self):
        # override bucket values from Weighting.Buckets as desired...
        pass    # pragma: no cover


class Weights:
    INFINITY = 100000
    NINFINITY = -INFINITY
    NO_EFFECT = 0

