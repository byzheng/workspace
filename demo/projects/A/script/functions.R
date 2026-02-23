# R/functions.R
get_data <- function(file) {
    read.csv(file)  |> 
        dplyr::mutate(date = as.Date(date))  |> 
        dplyr::filter(!is.na(x1), !is.na(y))
}

fit_model <- function(data) {
    lm(y ~ x1, data = data)  |> 
        coefficients()
}

plot_model <- function(model, data) {
    ggplot2::ggplot(data) +
        ggplot2::geom_point(ggplot2::aes(x = x1, y = y, color = group)) +
        ggplot2::geom_abline(intercept = model[1], slope = model[2], color = "blue")
}
