SPHINXBUILD ?= sphinx-build
SOURCEDIR = docs
BUILDDIR = build/docs
JOBS ?= auto
LIVE_HOST ?= 127.0.0.1
LIVE_PORT ?= 2022

.PHONY: html serve linkcheck clean

html:
	$(SPHINXBUILD) -M html $(SOURCEDIR) $(BUILDDIR) -j $(JOBS) -W --keep-going

serve:
	sphinx-autobuild $(SOURCEDIR) $(BUILDDIR)/html --host $(LIVE_HOST) --port $(LIVE_PORT) -W

linkcheck:
	$(SPHINXBUILD) -M linkcheck $(SOURCEDIR) $(BUILDDIR) -W --keep-going

clean:
	rm -rf $(BUILDDIR)
