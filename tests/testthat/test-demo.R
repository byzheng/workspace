expect_command_success <- function(command, args = character(), wd = getwd()) {
    output <- withr::with_dir(
        wd,
        system2(command, args, stdout = TRUE, stderr = TRUE)
    )

    status <- attr(output, "status")
    status <- if (is.null(status)) 0L else as.integer(status)

    expect_equal(
        status,
        0L,
        info = paste(c(sprintf("Command failed: %s %s", command, paste(args, collapse = " ")), output), collapse = "\n")
    )
}

test_that("demo root quarto render works", {
    skip_on_cran()
    skip_if_not_installed("withr")
    skip_if(Sys.which("quarto") == "", "quarto is not available")

    pkg_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), mustWork = TRUE)
    demo_dir <- file.path(pkg_root, "demo")
    skip_if_not(dir.exists(demo_dir), "demo directory is not available")

    expect_command_success("quarto", c("render"), wd = demo_dir)
})

test_that("demo root tar_make_project works", {
    skip_on_cran()
    skip_if_not_installed("withr")
    skip_if_not_installed("targets")
    skip_if_not_installed("tarchetypes")
    skip_if(Sys.which("quarto") == "", "quarto is not available")

    pkg_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), mustWork = TRUE)
    demo_dir <- file.path(pkg_root, "demo")
    skip_if_not(dir.exists(demo_dir), "demo directory is not available")

    rscript <- file.path(
        R.home("bin"),
        if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
    )

    expect_command_success(
        rscript,
        c("-e", "workspace::tar_make_project('projects/A')"),
        wd = demo_dir
    )
})

test_that("demo project tar_make works from project directory", {
    skip_on_cran()
    skip_if_not_installed("withr")
    skip_if_not_installed("targets")
    skip_if_not_installed("tarchetypes")
    skip_if(Sys.which("quarto") == "", "quarto is not available")

    pkg_root <- normalizePath(file.path(testthat::test_path(), "..", ".."), mustWork = TRUE)
    project_dir <- file.path(pkg_root, "demo", "projects", "A")
    skip_if_not(dir.exists(project_dir), "demo project directory is not available")

    rscript <- file.path(
        R.home("bin"),
        if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript"
    )

    expect_command_success(rscript, c("-e", "targets::tar_make()"), wd = project_dir)
})
