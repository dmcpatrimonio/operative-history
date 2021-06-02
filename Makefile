# Global variables and setup {{{1
# ================
VPATH = _lib
vpath %.bib _bibliography
vpath %.csl .:_csl
vpath %.yaml .:_spec
vpath default.% .:_lib
vpath reference.% .:_lib

JEKYLL-VERSION := 4.2.0
PANDOC-VERSION := 2.14
JEKYLL/PANDOC := docker run --rm -v "`pwd`:/srv/jekyll" \
	-p "4000:4000" -h "0.0.0.0:127.0.0.1" \
	palazzo/jekyll-tufte:$(JEKYLL-VERSION)-$(PANDOC-VERSION)
PANDOC/CROSSREF := docker run --rm -v "`pwd`:/data" \
	-u "`id -u`:`id -g`" pandoc/crossref:$(PANDOC-VERSION)
DEFAULTS := defaults.yaml references.bib

deploy : _site _site/summary/index.html

# Targets and recipes {{{1
# ===================
Palazzo_P.docx : index.md $(DEFAULTS) reference.docx \
	| _csl/chicago-fullnote-bibliography-with-ibid.csl
	@$(PANDOC/CROSSREF) -d _spec/defaults.yaml -o $@ $<
	@echo "$< > $@."

%.docx : %.md $(DEFAULTS) reference.docx \
	| _csl/chicago-fullnote-bibliography-with-ibid.csl
	$(PANDOC/CROSSREF) -d _spec/defaults.yaml -o $@ $<
	@echo "$< > $@."

_site/%/index.html : %.md revealjs.yaml revealjs-crossref.yaml \
	| _csl/chicago-author-date.csl
	@mkdir -p $(@D)
	@$(PANDOC/CROSSREF) -d _spec/revealjs.yaml -o $@ $<
	@echo "$< > slides."

_csl/%.csl : _csl
	@cd _csl && git checkout master -- $(@F)
	@echo "Checked out $(@F)."

.PHONY: _site
_site : | _csl/chicago-fullnote-bibliography-with-ibid.csl
	@$(JEKYLL/PANDOC) \
		/bin/bash -c "chmod 777 /srv/jekyll && jekyll build && chmod 777 /srv/jekyll/_site"

.PHONY: serve
serve : | _csl/chicago-fullnote-bibliography-with-ibid.csl
	@$(JEKYLL/PANDOC) jekyll serve

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
