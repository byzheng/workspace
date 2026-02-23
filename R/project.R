

#' Build a path relative to the project root
#'
#' Resolves the root directory differently depending on execution context:
#' interactive sessions use the active editor file (falling back to
#' [base::getwd()]), knitr uses the current input document, and
#' non-interactive runs use `PROJECT_DIR` when available, otherwise the
#' current project (or workspace when no project is found).
#'
#' @param ... Path components passed to [base::file.path()].
#'
#' @return A path string relative to [base::getwd()] when possible.
#' @export
path_prj <- function(...) {
    root_dir <- getwd()
    input <- knitr_input()

    if (interactive()) {
        base_dir <- tryCatch(dirname(active_file()), error = function(e) getwd())
        root_dir <- find_prj(base_dir)
    } else if (!is.null(input)) {
        root_dir <- find_prj(dirname(normalizePath(input, mustWork = FALSE)))
    } else {
        project_dir <- Sys.getenv("PROJECT_DIR")
        if (nzchar(project_dir)) {
            workspace_root <- find_ws()
            root_dir <- file.path(workspace_root, project_dir)
        } else {
            root_dir <- find_prj(getwd())
        }
    }
    target_path <- normalizePath(file.path(root_dir, ...), mustWork = FALSE)
    return(to_relative_path(target_path, start = getwd()))
}





#' Find the project root directory
#'
#' Locates the project root by looking for a `.project` file, falling back to
#' workspace root if no project is found. Can be overridden by setting the
#' `PROJECT_ROOT` environment variable.
#'
#' @param path Starting path to search from. Defaults to current directory.
#'
#' @return The project root directory path (or workspace root if no project found).
#' @export
find_prj <- function(path = ".") {
    project_root <- Sys.getenv("PROJECT_DIR", unset = "")
    if (nzchar(project_root)) {
        return(normalizePath(project_root, mustWork = FALSE))
    }
    
    tryCatch({
        root_path <- rprojroot::find_root(rprojroot::has_file(".project"), path = path)
        return(root_path)
    }, error = function(e) {
            message("No .project file found, using workspace root")
            return(find_ws(path = path))
        }
    )
}

#' Get the current project name
#'
#' Infers the project name by calculating the relative path from workspace
#' root to project root. Useful for automatically determining which project
#' is being worked on.
#'
#' @return Character string with the project name (e.g., "A" for `projects/A`),
#'   or `NULL` if no project is found or project is at workspace root.
#'
#' @details
#' This function finds the workspace and project roots, then extracts the
#' project identifier from the relative path. For a standard layout with
#' `projects/A`, returns "A".
#'
#' Useful in reports and other contexts where you need to automatically
#' reference the current project:
#' ```r
#' project <- get_prj_name()
#' if (!is.null(project)) {
#'     data <- tar_read_prj("data", project = project)
#' }
#' ```
#'
get_prj_name <- function() {
    workspace_root <- tryCatch(
        find_ws(path = path_prj("")),
        error = function(e) NULL
    )
    
    if (is.null(workspace_root)) {
        return(NULL)
    }
    
    project_root <- path_prj(".")
    
    workspace_norm <- normalizePath(workspace_root, mustWork = FALSE, winslash = "/")
    project_norm <- normalizePath(project_root, mustWork = FALSE, winslash = "/")
    
    if (identical(workspace_norm, project_norm)) {
        return(NULL)
    }
    
    rel_path <- to_relative_path(project_norm, start = workspace_norm)
    
    if (identical(rel_path, ".")) {
        return(NULL)
    }
    
    return(rel_path)
}
