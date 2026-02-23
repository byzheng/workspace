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


find_workspace <- function() {
    rprojroot::find_root(rprojroot::has_file(".workspace"))
}

find_project <- function(path = ".") {
    tryCatch(
        rprojroot::find_root(rprojroot::has_file(".project"), path = path),
        error = function(e) {
            message("No .project file found, using workspace root")
            return(find_workspace())
        }
    )
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
#' @return A normalized path string.
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
    return(normalizePath(file.path(root_dir, ...), mustWork = FALSE))
}
