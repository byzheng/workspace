# R/functions.R
get_data <- function(file) {
    read_csv(file, col_types = cols()) %>%
        mutate(date = as.Date(date)) %>%
        filter(!is.na(x1), !is.na(y))
}

fit_model <- function(data) {
    lm(y ~ x1, data = data) %>%
        coefficients()
}

plot_model <- function(model, data) {
    ggplot(data) +
        geom_point(aes(x = x1, y = y, color = group)) +
        geom_abline(intercept = model[1], slope = model[2], color = "blue")
}
