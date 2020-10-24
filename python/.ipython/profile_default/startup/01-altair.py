import json
import os

import altair as alt

dir = os.path.dirname(__file__)
rel_path = "../../../../vega_lite/vl_theme_spren9er.json"
file_path = os.path.join(dir, rel_path)

with open(file_path, "r") as json_file:
    vl_theme = json.load(json_file)
    alt.themes.register(
        "spren9er",
        lambda: {"config": vl_theme, "width": 500, "height": 350},
    )

alt.themes.enable("spren9er")
alt.data_transformers.disable_max_rows()
alt.renderers.set_embed_options(actions=False, scaleFactor=2)
