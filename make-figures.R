# This is a separate 'makefile' from make.R
# make.R only gets and wrangles data used in the plots
# make-figures.R is a superset, and performs stat tests and makes and saves
# plots as well
# If you are a developer, you might want make.R
# If you are a user, you probably want make-figures.R
library(fs)
library(targets)
dir_create("02_figures")
sapply(dir_ls("figure_scripts/"), source)
