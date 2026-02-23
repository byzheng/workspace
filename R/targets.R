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
