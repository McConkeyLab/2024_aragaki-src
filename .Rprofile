conflicted::conflict_prefer("select", "dplyr")
conflicted::conflict_prefer("filter", "dplyr")
conflicted::conflict_prefer("rename", "dplyr")
conflicted::conflict_prefer("path", "fs")

Sys.setenv(CLIMICROSOFT365_AADAPPID = "04b07795-8ddb-461a-bbee-02f9e1bf7b46")

options(languageserver.formatting_style = function(options) {
  style <- styler::tidyverse_style(indent_by = 2L)
  style$token$force_assignment_op <- NULL
  style
})
