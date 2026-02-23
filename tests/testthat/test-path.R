test_that("path uses PROJECT_DIR under workspace in non-interactive mode", {
    old <- getwd()
    on.exit(setwd(old), add = TRUE)

    root <- file.path(tempdir(), paste0("workspace-test-", as.integer(stats::runif(1, 1, 1e9))))
    dir.create(root, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(root, ".workspace"))

    project <- file.path(root, "projects", "A")
    dir.create(file.path(project, "source"), recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(project, ".project"))
    file.create(file.path(project, "source", "data.csv"))

    setwd(root)
    old_project_dir <- Sys.getenv("PROJECT_DIR", unset = "")
    on.exit(Sys.setenv(PROJECT_DIR = old_project_dir), add = TRUE)
    Sys.setenv(PROJECT_DIR = "projects/A")

    expect_equal(
        normalizePath(path("source", "data.csv"), mustWork = FALSE),
        normalizePath(file.path(project, "source", "data.csv"), mustWork = FALSE)
    )
})

test_that("path falls back to workspace when PROJECT_DIR is empty", {
    old <- getwd()
    on.exit(setwd(old), add = TRUE)

    root <- file.path(tempdir(), paste0("workspace-test-", as.integer(stats::runif(1, 1, 1e9))))
    dir.create(root, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(root, ".workspace"))
    dir.create(file.path(root, "source"), recursive = TRUE, showWarnings = FALSE)

    setwd(root)
    old_project_dir <- Sys.getenv("PROJECT_DIR", unset = "")
    on.exit(Sys.setenv(PROJECT_DIR = old_project_dir), add = TRUE)
    Sys.setenv(PROJECT_DIR = "")

    expect_equal(
        normalizePath(path("source", "data.csv"), mustWork = FALSE),
        normalizePath(file.path(root, "source", "data.csv"), mustWork = FALSE)
    )
})

test_that("find_project falls back to workspace when .project is missing", {
    old <- getwd()
    on.exit(setwd(old), add = TRUE)

    root <- file.path(tempdir(), paste0("workspace-test-", as.integer(stats::runif(1, 1, 1e9))))
    dir.create(root, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(root, ".workspace"))

    nested <- file.path(root, "some", "nested", "dir")
    dir.create(nested, recursive = TRUE, showWarnings = FALSE)

    setwd(root)

    expect_equal(
        workspace:::find_project(nested),
        normalizePath(root, mustWork = FALSE, winslash = "/")
    )
})

test_that("path uses current project when PROJECT_DIR is empty", {
    old <- getwd()
    on.exit(setwd(old), add = TRUE)

    root <- file.path(tempdir(), paste0("workspace-test-", as.integer(stats::runif(1, 1, 1e9))))
    dir.create(root, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(root, ".workspace"))

    project <- file.path(root, "projects", "A")
    dir.create(file.path(project, "source"), recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(project, ".project"))

    setwd(project)
    old_project_dir <- Sys.getenv("PROJECT_DIR", unset = "")
    on.exit(Sys.setenv(PROJECT_DIR = old_project_dir), add = TRUE)
    Sys.setenv(PROJECT_DIR = "")

    expect_equal(
        normalizePath(path("source", "data.csv"), mustWork = FALSE),
        normalizePath(file.path("source", "data.csv"), mustWork = FALSE)
    )
})
