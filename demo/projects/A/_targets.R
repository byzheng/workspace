# _targets.R file
library(targets)
library(tarchetypes)
library(workspace)
print(getwd())
print(path("script/functions.R"))
source(path("script/functions.R"))
list(
    tar_target(file, path("source/data.csv"), format = "file"),
    tar_target(data, get_data(file)),
    tar_target(model, fit_model(data)),
    tar_target(plot, plot_model(model, data)),
    tar_quarto(report, path("story/report.qmd"))
)
