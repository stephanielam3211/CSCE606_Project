from __future__ import annotations

import random
import unittest
from typing import List

import pandas as pd

from models.DataModel import DataModel


class TestCleanDataFrame(unittest.TestCase):

    def testColumnHasNewline(self):
        test_columns = ['col 1', 'col 2\n', 'col3']
        expected_columns = [col.replace('\n', '') for col in test_columns]
        test_df = pd.DataFrame(columns=test_columns)

        result = DataModel.cleanup_input_frame(test_df)

        self.assertListEqual(
            list(result.columns.array),
            expected_columns
        )


class TestParseFromDataFrame(unittest.TestCase):

    class TestDataModel(DataModel):
        class DataFormat:

            TEST_COL_STR = "Test Column String"
            TEST_COL_INT = "TestColumnInt"
            TEST_COL_FLOAT = "TestColumn Float"

            COLUMNS = [
                TEST_COL_STR,
                TEST_COL_INT,
                TEST_COL_FLOAT,
            ]

        def __init__(self, test_value_str, test_value_int, test_value_float):
            self.test_value_str: str = test_value_str
            self.test_value_int: int = test_value_int
            self.test_value_float: float = test_value_float

        @classmethod
        def get_empty_model(cls) -> TestParseFromDataFrame.TestDataModel:
            return TestParseFromDataFrame.TestDataModel(
                test_value_str='',
                test_value_int=0,
                test_value_float=9.0,
            )

        def set_by_column(self, field_title: str, value):
            if field_title == self.DataFormat.TEST_COL_STR:
                self.test_value_str = value
            elif field_title == self.DataFormat.TEST_COL_INT:
                self.test_value_int = int(value)
            elif field_title == self.DataFormat.TEST_COL_FLOAT:
                self.test_value_float = float(value)

    def setUp(self) -> None:
        self.TestString = "Test String"
        self.TestInt = 256
        self.TestFloat = 0.5

        self.testTestDataModel = self.TestDataModel(
            test_value_str=self.TestString,
            test_value_int=self.TestInt,
            test_value_float=self.TestFloat
        )

    def testCorrectNumObjectsReturned(self):
        expected_num_rows = random.Random().randint(1, 10)

        df_dict = {
            self.TestDataModel.DataFormat.TEST_COL_STR: [self.TestString for _ in range(expected_num_rows)],
            self.TestDataModel.DataFormat.TEST_COL_INT: [self.TestInt for _ in range(expected_num_rows)],
            self.TestDataModel.DataFormat.TEST_COL_FLOAT: [self.TestFloat for _ in range(expected_num_rows)],
        }

        test_data_frame = pd.DataFrame(df_dict)

        result: List[TestParseFromDataFrame.TestDataModel] = self.testTestDataModel.parse_from_dataframe(
            df=test_data_frame,
            get_empty_model=self.TestDataModel.get_empty_model,
            columns=self.TestDataModel.DataFormat.COLUMNS
        )

        self.assertEqual(
            len(result),
            expected_num_rows
        )

    def testNanValuesSkipped(self):

        df_dict = {
            self.TestDataModel.DataFormat.TEST_COL_STR: [self.TestString],
            self.TestDataModel.DataFormat.TEST_COL_INT: [self.TestInt],
            self.TestDataModel.DataFormat.TEST_COL_FLOAT: [float('nan')],
        }

        test_df = pd.DataFrame(df_dict)

        result: List[TestParseFromDataFrame.TestDataModel] = self.testTestDataModel.parse_from_dataframe(
            df=test_df,
            get_empty_model=self.TestDataModel.get_empty_model,
            columns=self.TestDataModel.DataFormat.COLUMNS
        )
        empty_model = self.TestDataModel.get_empty_model()

        self.assertEqual(
            result[0].test_value_float,
            empty_model.test_value_float
        )

    def testExceptionExits(self):

        with self.assertRaises(SystemExit):
            df_dict = {
                self.TestDataModel.DataFormat.TEST_COL_STR: [self.TestString],
                self.TestDataModel.DataFormat.TEST_COL_INT: ["Not An Integer"],
                self.TestDataModel.DataFormat.TEST_COL_FLOAT: [self.TestFloat],
            }

            test_df = pd.DataFrame(df_dict)

            self.testTestDataModel.parse_from_dataframe(
                df=test_df,
                get_empty_model=self.TestDataModel.get_empty_model,
                columns=self.TestDataModel.DataFormat.COLUMNS
            )
