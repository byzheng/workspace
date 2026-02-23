test_that("path_prj uses PROJECT_DIR under workspace in non-interactive mode", {
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
        path_prj("source", "data.csv"),
        file.path("projects", "A", "source", "data.csv")
    )
})

test_that("path_prj falls back to workspace when PROJECT_DIR is empty", {
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
        path_prj("source", "data.csv"),
        file.path("source", "data.csv")
    )
})

test_that("find_prj falls back to workspace when .project is missing", {
    old <- getwd()
    on.exit(setwd(old), add = TRUE)

    root <- file.path(tempdir(), paste0("workspace-test-", as.integer(stats::runif(1, 1, 1e9))))
    dir.create(root, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(root, ".workspace"))

    nested <- file.path(root, "some", "nested", "dir")
    dir.create(nested, recursive = TRUE, showWarnings = FALSE)

    setwd(root)

    expect_equal(
        workspace:::find_prj(nested),
        normalizePath(root, mustWork = FALSE, winslash = "/")
    )
})

test_that("path_prj uses current project when PROJECT_DIR is empty", {
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
        path_prj("source", "data.csv"),
        file.path("source", "data.csv")
    )
})

test_that("find_prj uses PROJECT_DIR when set", {
    old <- getwd()
    on.exit(setwd(old), add = TRUE)

    root <- file.path(tempdir(), paste0("workspace-test-", as.integer(stats::runif(1, 1, 1e9))))
    dir.create(root, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(root, ".workspace"))

    setwd(root)
    old_project_dir <- Sys.getenv("PROJECT_DIR", unset = "")
    on.exit(Sys.setenv(PROJECT_DIR = old_project_dir), add = TRUE)
    Sys.setenv(PROJECT_DIR = "projects/A")

    expect_equal(
        normalizePath(find_prj(), mustWork = FALSE, winslash = "/"),
        normalizePath(file.path(root, "projects", "A"), mustWork = FALSE, winslash = "/")
    )
})

test_that("find_prj locates .project from nested directory", {
    old <- getwd()
    on.exit(setwd(old), add = TRUE)

    root <- file.path(tempdir(), paste0("workspace-test-", as.integer(stats::runif(1, 1, 1e9))))
    dir.create(root, recursive = TRUE, showWarnings = FALSE)

    project <- file.path(root, "projects", "A")
    dir.create(project, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(project, ".project"))

    nested <- file.path(project, "nested", "dir")
    dir.create(nested, recursive = TRUE, showWarnings = FALSE)

    setwd(nested)
    old_project_dir <- Sys.getenv("PROJECT_DIR", unset = "")
    on.exit(Sys.setenv(PROJECT_DIR = old_project_dir), add = TRUE)
    Sys.setenv(PROJECT_DIR = "")

    expect_equal(
        find_prj(),
        normalizePath(project, mustWork = FALSE, winslash = "/")
    )
})

test_that("get_prj_name returns NULL at workspace root", {
    old <- getwd()
    on.exit(setwd(old), add = TRUE)

    root <- file.path(tempdir(), paste0("workspace-test-", as.integer(stats::runif(1, 1, 1e9))))
    dir.create(root, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(root, ".workspace"))

    setwd(root)
    old_project_dir <- Sys.getenv("PROJECT_DIR", unset = "")
    on.exit(Sys.setenv(PROJECT_DIR = old_project_dir), add = TRUE)
    Sys.setenv(PROJECT_DIR = "")

    expect_null(workspace:::get_prj_name())
})

test_that("get_prj_name returns project path relative to workspace", {
    old <- getwd()
    on.exit(setwd(old), add = TRUE)

    root <- file.path(tempdir(), paste0("workspace-test-", as.integer(stats::runif(1, 1, 1e9))))
    dir.create(root, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(root, ".workspace"))

    project <- file.path(root, "projects", "A")
    dir.create(project, recursive = TRUE, showWarnings = FALSE)
    file.create(file.path(project, ".project"))

    setwd(project)
    old_project_dir <- Sys.getenv("PROJECT_DIR", unset = "")
    on.exit(Sys.setenv(PROJECT_DIR = old_project_dir), add = TRUE)
    Sys.setenv(PROJECT_DIR = "")

    expect_equal(
        workspace:::get_prj_name(),
        file.path("projects", "A")
    )
})
