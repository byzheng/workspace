# _targets.R file
library(targets)
library(tarchetypes)
print(getwd())
source("../../../R/path.R")
source(path("script/functions.R"))
tar_option_set(packages = c("readr", "dplyr", "ggplot2"))
list(
    tar_target(file, path("source/data.csv"), format = "file"),
    tar_target(data, get_data(file)),
    tar_target(model, fit_model(data)),
    tar_target(plot, plot_model(model, data))
)
