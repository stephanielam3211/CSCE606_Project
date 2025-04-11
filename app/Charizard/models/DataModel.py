from __future__ import annotations

import abc
import numbers
from typing import Callable, List

import numpy
import pandas as pd


class DataModel(abc.ABC):

    @classmethod
    def parse_from_dataframe(
            cls, df: pd.DataFrame, get_empty_model: Callable[[], DataModel], columns: List[str]
    ) -> List[DataModel]:
        """
        Parse Instances of this class from rows of a DataFrame
        :param columns: list of columns expected in the dataframe
        :param get_empty_model: Callable implementation of DataModel.get_empty_model()
        :param df: the dataframe to parse
        :return list[DataModel]: List of objects parsed from the dataframe
        """
        num_rows, _ = df.shape
        models = [get_empty_model() for _ in range(num_rows)]
        
        for column in columns:
            for row_index in range(num_rows):
                value = df[column].iloc[row_index]
                if (isinstance(value, numbers.Number) and numpy.isnan(value)) or \
                        (isinstance(value, str) and len(value.strip()) == 0) or \
                        value is None:
                    continue 
                
                # Handle conversions based on column name
                if column == 'Course_Name': 
                    value = str(value).strip()

                elif column == 'Course_Number':  
                    value = str(value).strip() 
                elif column == 'Section': 
                    value = str(value).strip() 

                elif column == 'Instructor':  
                    value = str(value).strip()

                elif column == 'Faculty_Email': 
                    value = str(value).strip()

                elif column in ['TA', 'Senior_Grader', 'Grader']: 
                    try:
                        value = int(float(value))  
                    except ValueError:
                        raise SystemExit(f"Error parsing row {row_index + 2} at column='{column}'. "
                                          f"Invalid integer value: {repr(value)}")

                elif column in ['Professor Pre-Reqs']:
                    value = str(value).strip()

                try:
                    models[row_index].set_by_column(column, value)
                except Exception as e:
                    row_index_offset = 2  
                    raise SystemExit(f"Error parsing row {row_index + row_index_offset} at column='{column}'. "
                                      f"Fix input formatting and re-run the program. "
                                      f"Value: {repr(value)}. Error: {str(e)}")

        return models

    @classmethod
    def cleanup_input_frame(cls, df: pd.DataFrame) -> pd.DataFrame:
        """
        Cleanup the dataframe to allow for consistent parsing
        (for example, remove newline characters in the column names)
        :param df: the dataframe to clean
        :return: cleaned dataframe
        """
        df.columns = df.columns.str.replace('\n', '')
        return df

    @classmethod
    def get_empty_model(cls) -> DataModel:  # pragma: no cover
        """
        Function to construct an empty instance of this class.
        :return: an object constructed with the default values for each field
        """
        pass

    def set_by_column(self, field_title: str, value):   # pragma: no cover
        """
        Given a value and a column name from the set of columns expected in the dataframe for this Model,
        set the corresponding value in the model object.
        :param field_title: The column name associated with the given value in the dataframe
        :param value: The value to set.
        :return: None
        """
        pass
