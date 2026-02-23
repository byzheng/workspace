
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

