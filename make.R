# This is a separate 'makefile' from make-figures.R
# make.R only gets and wrangles data used in the plots
# make-figures.R is a superset, and performs stat tests and makes and saves
# plots as well
# If you are a developer, you might want make.R
# If you are a user, you probably want make-figures.R
library(targets)

Sys.setenv(TAR_PROJECT = "lund")
tar_make()
Sys.setenv(TAR_PROJECT = "tcga")
tar_make()
Sys.setenv(TAR_PROJECT = "uromol")
tar_make()
Sys.setenv(TAR_PROJECT = "cell_rna")
tar_make()
Sys.setenv(TAR_PROJECT = "tw")
tar_make()
