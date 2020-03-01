# Global variables {{{1
# ================
# Where make should look for things
VPATH = lib
vpath %.yaml .:spec
vpath default.% lib/pandoc-templates
DEFAULTS = defaults.yaml bib/biblio.bib

# Branch-specific targets and recipes {{{1
# ===================================

all : _book/6eahn-20-1065-operative_history.pdf _book/6eahn-20-1065-operative_history.docx

_book/6eahn-20-1065-operative_history.pdf  : 1065-operative_history.md $(DEFAULTS)
	pandoc --defaults spec/defaults.yaml -o $@ 1065-operative_history.md

_book/6eahn-20-1065-operative_history.docx : 1065-operative_history.md $(DEFAULTS)
	pandoc --defaults spec/defaults.yaml -o $@ 1065-operative_history.md

# Install and cleanup {{{1
# ===================
# `make install` copies various config files and hooks to the .git
# directory and sets up standard empty directories.
.PHONY : install
install :
	-mkdir _share
	-mkdir fig
	rsync -aq .install/ .git/
	git submodule update --init

# `make clean` will clear out a few standard folders where only compiled
# files should be. Anything you might have placed manually in them will
# also be deleted!
.PHONY : clean
clean :
	-rm -r _book/* _site/*

# vim: set foldmethod=marker :
