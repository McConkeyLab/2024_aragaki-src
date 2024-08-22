# This is a separate 'makefile' from make.R
# make.R only gets and wrangles data used in the plots
# make-figures.R is a superset, and performs stat tests and makes and saves
# plots as well
# If you are a developer, you might want make.R
# If you are a user, you probably want make-figures.R
library(fs)
dir_create("02_figures")
source("figure_scripts/01_figure/a.R")
source("figure_scripts/01_figure/b.R")
source("figure_scripts/01_figure/b-extra.R")
source("figure_scripts/01_figure/c.R")
source("figure_scripts/01_figure/d.R") # Just data, no figure output
source("figure_scripts/02_figure/a.R") # Just data, no figure output
source("figure_scripts/02_figure/b.R")
source("figure_scripts/02_figure/c.R")
source("figure_scripts/03_figure/a.R")
source("figure_scripts/03_figure/b.R")
source("figure_scripts/03_figure/c.R")
source("figure_scripts/03_figure/d.R")
source("figure_scripts/03_figure/e.R")
source("figure_scripts/04_figure/a.R")
source("figure_scripts/04_figure/b.R")
source("figure_scripts/04_figure/c.R")
source("figure_scripts/05_figure/a.R")
source("figure_scripts/05_figure/b.R")
source("figure_scripts/06_figure/a.R")
source("figure_scripts/06_figure/b.R")
source("figure_scripts/s01_figure/a.R")
source("figure_scripts/s03_figure/a.R")
