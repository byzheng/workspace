# workspace

Project-aware paths and per-project `{targets}` pipelines for multi-project
workspaces marked by `.workspace` and `.project` files.

## Features

- Resolve file paths relative to the active project with `path()`.
- Detect workspace and project roots with `find_workspace()` and `find_project()`.
- Run and read `{targets}` pipelines per project using `tar_make_project()` and
	`tar_read_project()`.




## Installation

Currently on [Github](https://github.com/byzheng/workspace) only. Install with:

```r
remotes::install_github('byzheng/workspace')
```
