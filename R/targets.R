#' Run targets pipeline for a project
#'
#' Executes `tar_make()` for a specific project within a workspace. Sets up the
#' working directory and environment variables so that `path()` and
#' `workspace_targets_store()` work correctly.
#'
#' @param project Character string naming the project (e.g., "A" for `projects/A`).
#' @param ... Additional arguments passed to [targets::tar_make()].
#'
#' @return Invisibly returns the result of `tar_make()`.
#'
#' @details
#' This function:
#' - Changes working directory to workspace root
#' - Sets `PROJECT_DIR` environment variable to `projects/{project}`
#' - Calls `targets::tar_make()`
#' - Restores the original working directory
#'
#' Use this instead of calling `tar_make()` directly so that all workspace
#' path resolution works correctly.
#'
#' @export
tar_make_project <- function(project, ...) {
    if (!requireNamespace("targets", quietly = TRUE)) {
        stop("The 'targets' package is required. Install with: install.packages('targets')")
    }
    if (!requireNamespace("withr", quietly = TRUE)) {
        stop("The 'withr' package is required. Install with: install.packages('withr')")
    }

    workspace_root <- find_workspace()
    

    withr::with_dir(workspace_root, {
        old_project_dir <- Sys.getenv("PROJECT_DIR", unset = "")
        Sys.setenv(PROJECT_DIR = project)
        on.exit(
            if (nzchar(old_project_dir)) {
                Sys.setenv(PROJECT_DIR = old_project_dir)
            } else {
                Sys.unsetenv("PROJECT_DIR")
            },
            add = TRUE
        )
        targets::tar_make(script = file.path(project, "_targets.R"), 
            store = file.path(project, "_targets"), ...)
    })
}

#' Get the targets store path for the current project
#'
#' Returns the path to the `_targets` directory for the project specified in
#' the `PROJECT_DIR` environment variable. Useful in `_targets.R` and report
#' files to configure the targets store without hardcoding paths.
#'
#' @return A character string with the targets store path, relative to the
#'   workspace root. Returns `./_targets` if no project is detected.
#'
#' @details
#' This function reads the `PROJECT_DIR` environment variable (typically set
#' by [tar_make_project()]) and returns the associated `_targets` path.
#'
#' Use in `_targets.R`:
#' ```r
#' tar_option_set(store = workspace_targets_store())
#' ```
workspace_targets_store <- function() {
    project_dir <- get_project_name()
    if (nzchar(project_dir)) {
        store_path <- file.path(project_dir, "_targets")
    } else {
        store_path <- "./_targets"
    }
    abs_path <- file.path(find_workspace(), store_path)
    to_relative_path(abs_path)
}


#' Read a target from the current project
#'
#' Convenience wrapper around [targets::tar_read()] that automatically specifies
#' the targets store location for the current project. The project is auto-detected
#' using [get_project_name()].
#'
#' @param name Name of the target to read (as a string or symbol).
#' @param ... Additional arguments passed to [targets::tar_read()].
#'
#' @return The target value.
#'
#' @details
#' Auto-detects the project and reads from its targets store. Equivalent to:
#' ```r
#' tar_read(name, store = workspace_targets_store_project(get_project_name()))
#' ```
#'
#' Use in reports:
#' ```r
#' data <- tar_read_project("data")
#' model <- tar_read_project("model")
#' plot <- tar_read_project("plot")
#' ```
#'
#' @export
tar_read_project <- function(name, ...) {
    targets::tar_read_raw(
        name,
        store = workspace_targets_store(),
        ...
    )
}
