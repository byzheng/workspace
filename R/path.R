
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

