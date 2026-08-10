DOCS_VENV ?= .venv
PYTHON ?= python3
SPHINXBUILD ?= $(DOCS_VENV)/bin/sphinx-build
SPHINXAUTOBUILD ?= $(DOCS_VENV)/bin/sphinx-autobuild
SOURCEDIR = docs
BUILDDIR = build/docs
JOBS ?= auto
LIVE_HOST ?= 127.0.0.1
LIVE_PORT ?= 2022

.PHONY: docs-venv html serve linkcheck clean

docs-venv: $(DOCS_VENV)/bin/sphinx-build

$(DOCS_VENV)/bin/sphinx-build: docs/requirements.txt docs/constraints.txt
	$(PYTHON) -m venv $(DOCS_VENV)
	$(DOCS_VENV)/bin/python -m pip install -r docs/requirements.txt -c docs/constraints.txt

html: docs-venv
	$(SPHINXBUILD) -M html $(SOURCEDIR) $(BUILDDIR) -j $(JOBS) -W --keep-going

serve: docs-venv
	$(SPHINXAUTOBUILD) $(SOURCEDIR) $(BUILDDIR)/html --host $(LIVE_HOST) --port $(LIVE_PORT) -W

linkcheck: docs-venv
	$(SPHINXBUILD) -M linkcheck $(SOURCEDIR) $(BUILDDIR) -W --keep-going

clean:
	rm -rf $(BUILDDIR)
