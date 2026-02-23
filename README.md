[![R-CMD-check](https://github.com/byzheng/workspace/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/byzheng/workspace/actions/workflows/R-CMD-check.yaml)



# workspace

Project-aware paths and per-project `{targets}` pipelines for multi-project
workspaces marked by `.workspace` and `.project` files.

## Features

- Resolve file paths relative to the active project with `path_prj()`.
- Detect workspace and project roots with `find_workspace()` and `find_project()`.
- Run and read `{targets}` pipelines per project using `tar_make_project()` and
	`tar_read_project()`.

## Assumptions and Motivation

This package assumes a multi-project repository with a single workspace root
that contains a `.workspace` marker, and one or more project folders each marked
by a `.project` file (for example, `projects/A`). The goal is to make scripts,
reports, and `{targets}` pipelines behave consistently no matter where you run
them from, without hardcoding paths. The helpers here resolve paths relative to
the active project, and the `tar_make_project()` wrapper sets the right project
context so pipelines run reliably across local development and CI.

Execution context matters:

- Interactive sessions favor the active editor file when resolving `path_prj()` so
	you get project-relative paths while developing in an IDE.
- Quarto or knitr documents use the current input file to infer the project
	context, keeping report renders stable when run from the command line.
- Non-interactive runs (like CI) use `PROJECT_DIR` when it is set; otherwise
	they fall back to the nearest project or the workspace root.

VS Code tip:

- Setting `options(vsc.rstudioapi = TRUE)` enables the VS Code R extension to
	provide `rstudioapi` editor context, so `path_prj()` can resolve the active file
	during interactive sessions.

For `{targets}`, `tar_make_project()` sets `PROJECT_DIR` and runs the pipeline
from the workspace root so `_targets.R`, data files, and Quarto reports resolve
paths consistently.




## Installation

Currently on [Github](https://github.com/byzheng/workspace) only. Install with:

```r
remotes::install_github('byzheng/workspace')
```
