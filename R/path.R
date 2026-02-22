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



#' Build a path relative to the project root
#'
#' Resolves the root directory differently depending on execution context:
#' interactive sessions use the active editor file, knitr uses the current
#' input document, and non-interactive runs use the workspace root with an
#' optional `PROJECT_DIR` environment variable.
#'
#' @param ... Path components passed to [base::file.path()].
#'
#' @return A normalized path string.
#' @export
path <- function(...) {
    
    args <- commandArgs(FALSE)
    print(paste("Command line arguments: ", paste(args, collapse = ", ")))
    root_dir <- getwd()
    if (interactive()) {
        message("Running interactively, using active_file() to find root dir")
        print("Current file: ")
        f <- active_file()
        print(f)
        dir <- dirname(f)
        root_dir <- find_project(dir)
    } else if (!is.null(knitr::current_input())) {
        message("Running in knitr, using current_input() to find root dir")
        root_dir <- normalizePath(knitr::current_input())
        print(paste("Current input: ", root_dir))
        root_dir <- find_project(dirname(root_dir))

        print(paste("Root dir: ", root_dir))
    } else {
        message("Running non-interactively, using find_workspace() to find root dir")
        workspace_root <- find_workspace()
        message(paste("Workspace root: ", workspace_root))
        project_dir <- Sys.getenv("PROJECT_DIR")
        message(paste("Project dir from env: ", project_dir))
        if (project_dir != "") {
            root_dir <- file.path(workspace_root, project_dir)
        }
    }    
    return(normalizePath(file.path(root_dir, ...), mustWork = FALSE))
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
