from datetime import date

project = "Drone Sim"
author = "Teapot Laboratories"
copyright = f"{date.today().year}, {author}"

extensions = [
    "myst_parser",
    "sphinx.ext.intersphinx",
    "sphinx.ext.todo",
    "sphinx_copybutton",
]
source_suffix = {".rst": "restructuredtext", ".md": "markdown"}
master_doc = "index"
exclude_patterns = ["history/**", "worklog/**", "worklog/html/**", "*.html"]
myst_enable_extensions = ["colon_fence", "deflist", "fieldlist", "linkify", "substitution"]
myst_heading_anchors = 3
html_theme = "sphinx_rtd_theme"
html_static_path = []
html_title = "Drone Sim"
html_theme_options = {"collapse_navigation": False, "navigation_depth": 4}
intersphinx_mapping = {"python": ("https://docs.python.org/3", None)}
# Existing Markdown preserves historical links outside this initial Sphinx navigation tree.
suppress_warnings = ["myst.xref_missing", "toc.not_included", "toc.excluded", "misc.highlighting_failure"]
