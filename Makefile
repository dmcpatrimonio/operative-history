# Global variables and setup {{{1
# ================
VPATH = _lib
vpath %.yaml .:_spec
vpath default.% .:_lib

JEKYLL-VERSION := 4.2.0
PANDOC-VERSION := 2.12
JEKYLL/PANDOC := docker run --rm -v "`pwd`:/srv/jekyll" \
	-u "`id -u`:`id -g`" palazzo/jekyll-pandoc:$(JEKYLL-VERSION)-$(PANDOC-VERSION)
PANDOC/CROSSREF := docker run --rm -v "`pwd`:/data" \
	-u "`id -u`:`id -g`" pandoc/crossref:$(PANDOC-VERSION)
PANDOC/LATEX := docker run --rm -v "`pwd`:/data" \
	-u "`id -u`:`id -g`" palazzo/pandoc-ebgaramond:$(PANDOC-VERSION)

# Targets and recipes {{{1
# ===================
Palazzo_P.docx : paper.md $(DEFAULTS) \
	| chicago-fullnote-bibliography-with-ibid.csl

_book/6eahn-20-1065-operative_history.pdf  : 1065-operative_history.md $(DEFAULTS) \
	| chicago-fullnote-bibliography-with-ibid.csl
	$(PANDOC/LATEX) -d _spec/defaults.yaml -o $@ $<

%.docx : %.md $(DEFAULTS) \
	| chicago-fullnote-bibliography-with-ibid.csl
	$(PANDOC/CROSSREF) -d _spec/defaults.yaml -o $@ $<

_site :
	@test -e $@ && cd $@ && git pull || \
		git clone -b gh-pages --depth=1 \
		git@github.com:dmcpatrimonio/tipo_ecletismo.git $@
	@$(JEKYLL/PANDOC) jekyll build

_csl/%.csl : _csl
	@echo "Checking out $@..."
	@cd _csl && git checkout master -- $@
	@echo "Checked out $@."

# Install and cleanup {{{1
# ===================
_csl :
	@cd $@ && git pull || \
		git clone --depth=1 --filter=blob:none --no-checkout \
		https://github.com/citation-style-language/styles.git \
		$@

.PHONY : clean
clean :
	-rm -r _book/* _site _csl

# vim: set foldmethod=marker shiftwidth=2 tabstop=2 :
