active_file <- function() {
    if (requireNamespace("rstudioapi", quietly = TRUE) &&
        rstudioapi::isAvailable()) {
        ctx <- rstudioapi::getSourceEditorContext()
        if (!is.null(ctx$path) && ctx$path != "") {
            return(normalizePath(ctx$path))
        }
    }
    stop("Cannot determine current file location")
}


knitr_input <- function() {
    if (!requireNamespace("knitr", quietly = TRUE)) {
        return(NULL)
    }
    input <- tryCatch(knitr::current_input(), error = function(e) NULL)
    if (is.null(input) || length(input) == 0 || !nzchar(input)) {
        return(NULL)
    }
    input
}


#' Find the workspace root directory
#'
#' Locates the workspace root by looking for a `.workspace` file.
#'
#' @param path Starting path to search from. Defaults to current directory.
#'
#' @return The workspace root directory path.
#' @export
find_workspace <- function(path = ".") {
    rprojroot::find_root(rprojroot::has_file(".workspace"), path = path)
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
find_project <- function(path = ".") {
    project_root <- Sys.getenv("PROJECT_DIR", unset = "")
    if (nzchar(project_root)) {
        return(normalizePath(project_root, mustWork = FALSE))
    }
    
    tryCatch({
        root_path <- rprojroot::find_root(rprojroot::has_file(".project"), path = path)
        return(root_path)
    }, error = function(e) {
            message("No .project file found, using workspace root")
            return(find_workspace(path = path))
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
#' project <- get_project_name()
#' if (!is.null(project)) {
#'     data <- tar_read_project("data", project = project)
#' }
#' ```
#'
get_project_name <- function() {
    workspace_root <- tryCatch(
        find_workspace(path = path("")),
        error = function(e) NULL
    )
    
    if (is.null(workspace_root)) {
        return(NULL)
    }
    
    project_root <- path(".")
    
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

to_relative_path <- function(target, start = getwd()) {
    target_norm <- normalizePath(target, mustWork = FALSE, winslash = "/")
    start_norm <- normalizePath(start, mustWork = FALSE, winslash = "/")

    target_parts <- strsplit(target_norm, "/", fixed = TRUE)[[1]]
    start_parts <- strsplit(start_norm, "/", fixed = TRUE)[[1]]

    if (length(target_parts) > 0 && length(start_parts) > 0 &&
        !identical(tolower(target_parts[[1]]), tolower(start_parts[[1]]))) {
        return(target_norm)
    }

    common <- 0L
    max_common <- min(length(target_parts), length(start_parts))
    while (common < max_common &&
           identical(tolower(target_parts[[common + 1L]]), tolower(start_parts[[common + 1L]]))) {
        common <- common + 1L
    }

    up <- if (common < length(start_parts)) rep("..", length(start_parts) - common) else character(0)
    down <- if (common < length(target_parts)) target_parts[(common + 1L):length(target_parts)] else character(0)
    rel <- c(up, down)

    if (length(rel) == 0) {
        return(".")
    }
    do.call(file.path, as.list(rel))
}


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
path <- function(...) {
    root_dir <- getwd()
    input <- knitr_input()

    if (interactive()) {
        base_dir <- tryCatch(dirname(active_file()), error = function(e) getwd())
        root_dir <- find_project(base_dir)
    } else if (!is.null(input)) {
        root_dir <- find_project(dirname(normalizePath(input, mustWork = FALSE)))
    } else {
        project_dir <- Sys.getenv("PROJECT_DIR")
        if (nzchar(project_dir)) {
            workspace_root <- find_workspace()
            root_dir <- file.path(workspace_root, project_dir)
        } else {
            root_dir <- find_project(getwd())
        }
    }
    target_path <- normalizePath(file.path(root_dir, ...), mustWork = FALSE)
    return(to_relative_path(target_path, start = getwd()))
}
