setwd("demo")
workspace::tar_make_project("projects/A")

# library(workspace)

# project_paths <- function(projects_dir = "projects") {
#     dirs <- list.dirs(projects_dir, recursive = FALSE, full.names = FALSE)
#     dirs[vapply(dirs, function(name) {
#         file.exists(file.path(projects_dir, name, ".project")) &&
#             file.exists(file.path(projects_dir, name, "_targets.R"))
#     }, logical(1))]P
# }

# build_project <- function(project_name) {
#     message("Building project: ", project_name)
#     tar_make_project(project_name)
# }

# build_workspace <- function() {
#     projects <- project_paths()
#     if (length(projects) == 0) {
#         stop("No runnable projects found under demo/projects")
#     }
#     invisible(lapply(projects, build_project))
# }

# args <- commandArgs(trailingOnly = TRUE)

# if (length(args) == 0 || identical(args[[1]], "all")) {
#     build_workspace()
# } else {
#     build_project(args[[1]])
# }

