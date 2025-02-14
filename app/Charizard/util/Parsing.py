from models.DataModel import DataModel
from typing import List
import pandas as pd


def is_df_column_set_valid(filepath: str, df: pd.DataFrame, expected_columns: List[str]) -> bool:
    missing_columns = []
    for column in expected_columns:
        if column not in df.columns:
            missing_columns.append(column)
    if len(missing_columns) > 0:
        print(f"File {filepath} is missing the following expected columns:")
        print(missing_columns)
        print("If this is intentional, you can modify the expected columns in the model's 'DataFormat' subclass...")
        return False

    return True


def parse_models_from_csv(filepath: str, model: DataModel) -> List[DataModel]:
    try:
        df = pd.read_csv(filepath)
        df = model.cleanup_input_frame(df)
        if not is_df_column_set_valid(filepath, df, model.__class__.DataFormat.COLUMNS):
            raise SystemExit()
        return model.parse_from_dataframe(df, model.get_empty_model, model.__class__.DataFormat.COLUMNS)
    except Exception as e:
        print(f"[red]Failed to parse csv at {filepath}")
        print(e)
        return []
