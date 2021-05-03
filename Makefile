# Global variables and setup {{{1
# ================
VPATH = _lib
vpath %.yaml .:_spec
vpath %.csl .:_csl
vpath default.% .:_lib
vpath reference.% .:_lib

JEKYLL-VERSION := 4.2.0
PANDOC-VERSION := 2.12
JEKYLL/PANDOC := docker run --rm -v "`pwd`:/srv/jekyll" \
	-u "`id -u`:`id -g`" palazzo/jekyll-tufte:$(JEKYLL-VERSION)-$(PANDOC-VERSION)
PANDOC/CROSSREF := docker run --rm -v "`pwd`:/data" \
	-u "`id -u`:`id -g`" pandoc/crossref:$(PANDOC-VERSION)
DEFAULTS := defaults.yaml _biblio.bib

# Targets and recipes {{{1
# ===================
Palazzo_P.docx : paper.md $(DEFAULTS) reference.docx \
	| _csl/chicago-fullnote-bibliography-with-ibid.csl
	@$(PANDOC/CROSSREF) -d _spec/defaults.yaml -o $@ $<
	@echo "$< > $@."

%.docx : %.md $(DEFAULTS) reference.docx \
	| _csl/chicago-fullnote-bibliography-with-ibid.csl
	$(PANDOC/CROSSREF) -d _spec/defaults.yaml -o $@ $<
	@echo "$< > $@."

_csl/%.csl : _csl
	@cd _csl && git checkout master -- $(@F)
	@echo "Checked out $(@F)."

.PHONY: _site
_site : | _csl/chicago-fullnote-bibliography-with-ibid.csl
	@echo "Fetching gh-pages branch..."
	@cd $@ && git pull || \
		git clone -b gh-pages --depth=1 \
		git@github.com:dmcpatrimonio/tipo_ecletismo.git $@
	@$(JEKYLL/PANDOC) \
		/bin/bash -c "chmod 777 /srv/jekyll && jekyll build"

# Install and cleanup {{{1
# ===================
.PHONY : _csl
_csl :
	@echo "Fetching CSL styles..."
	@cd $@ && git pull || \
		git clone --depth=1 --filter=blob:none --no-checkout \
		https://github.com/citation-style-language/styles.git \
		$@

.PHONY : clean
clean :
	-rm -r _book/* _site _csl

# vim: set foldmethod=marker shiftwidth=2 tabstop=2 :
