import pandas as pd

pd.set_option("display.max_rows", 200)
pd.set_option("display.show_dimensions", False)
pd.set_option("display.float_format", lambda x: f"{x:.2f}")
pd.set_option("display.precision", 6)
pd.set_option("mode.dtype_backend", "pyarrow")
