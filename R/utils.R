#' Is an object a distribution?
#'
#' `is_distribution` tests if `x` inherits from `"distribution"`.
#'
#' @param x An object to test.
#'
#' @export
#'
#' @examples
#'
#' Z <- Normal()
#'
#' is_distribution(Z)
#' is_distribution(1L)
is_distribution <- function(x) {
  inherits(x, "distribution")
}

#' Plot the CDF of a distribution
#'
#' A function to easily plot the CDF of a distribution using `ggplot2`. Requires `ggplot2` to be loaded.
#'
#' @param d A `distribution` object
#' @param limits either `NULL` (default) or a vector of length 2 that specifies the range of the x-axis
#' @param p If `limits` is `NULL`, the range of the x-axis will be the support of `d` if this is a bounded
#'   interval, or `quantile(d, p)` and `quantile(d, 1 - p)` if lower and/or upper limits of the support is
#'   `-Inf`/`Inf`.  Defaults to 0.001.
#' @param plot_theme specify theme of resulting plot using `ggplot2`. Default is `theme_minimal`
#'
#' @export
plot_cdf <- function(d, limits = NULL, p = 0.001,
                     plot_theme = ggplot2::theme_minimal){

  if(!"ggplot2" %in% loadedNamespaces())
    stop("You must load ggplot2 for this function to work.")

  if(is.null(limits))
    limits <- support(d)

  if(limits[1] == -Inf){
    limits[1] <- quantile(d, p = p)
  }

  if(limits[2] == Inf){
    limits[2] <- quantile(d, p = 1-p)
  }

  if(class(d)[1] %in% c('Bernoulli', 'Binomial', 'Geometric', 'HyperGeometric',
                        'NegativeBinomial', 'Poisson')){
    plot_df <- data.frame(x = seq(limits[1], limits[2], by = 1))
    plot_df$y <- cdf(d, plot_df$x)

    out_plot <- ggplot2::ggplot(data = plot_df,
           aes(x = x, y = y)) +
      ggplot2::geom_bar(stat = 'identity', width = 1,
                        aes(color = I("black"),
                            fill = I("grey50"))) +
      plot_theme()
  }

  if(class(d)[1] %in% c('Beta', 'Cauchy', 'ChiSquare', 'Exponential',
                        'FisherF', 'Gamma', 'Logistic', 'LogNormal',
                        'Normal', 'StudentsT', 'Tukey', 'Uniform', 'Weibull')){
    plot_df <- data.frame(x = seq(limits[1], limits[2], length.out = 5000))
    plot_df$y <- cdf(d, plot_df$x)

    out_plot <- ggplot2::ggplot(data = plot_df,
                    aes(x = x, y = y)) +
      ggplot2::geom_line() +
      plot_theme()
  }

  return(out_plot)

}


#' Plot the PDF of a distribution
#'
#' A function to easily plot the PDF of a distribution using `ggplot2`. Requires `ggplot2` to be loaded.
#'
#' @param d A `distribution` object
#' @param limits either `NULL` (default) or a vector of length 2 that specifies the range of the x-axis
#' @param p If `limits` is `NULL`, the range of the x-axis will be the support of `d` if this is a bounded
#'   interval, or `quantile(d, p)` and `quantile(d, 1 - p)` if lower and/or upper limits of the support is
#'   `-Inf`/`Inf`.  Defaults to 0.001.
#' @param plot_theme specify theme of resulting plot using `ggplot2`. Default is `theme_minimal`
#'
#' @export
plot_pdf <- function(d, limits = NULL, p = 0.001,
                     plot_theme = ggplot2::theme_bw){

  if(!"ggplot2" %in% loadedNamespaces())
    stop("You must load ggplot2 for this function to work.")


  if(is.null(limits))
    limits <- support(d)

  if(limits[1] == -Inf){
    limits[1] <- quantile(d, p = p)
  }

  if(limits[2] == Inf){
    limits[2] <- quantile(d, p = 1-p)
  }

  if(class(d)[1] %in% c('Bernoulli', 'Binomial', 'Geometric', 'HyperGeometric',
                        'NegativeBinomial', 'Poisson')){
    plot_df <- data.frame(x = seq(limits[1], limits[2], by = 1))
    plot_df$y <- pdf(d, plot_df$x)

    out_plot <- ggplot(data = plot_df,
                       aes(x = x, y = y)) +
      geom_bar(stat = 'identity', width = 1,
               aes(color = I("black"),
                   fill = I("grey50"))) +
      #xlab("x") +
      plot_theme()
  }

  if(class(d)[1] %in% c('Beta', 'Cauchy', 'ChiSquare', 'Exponential',
                        'FisherF', 'Gamma', 'Logistic', 'LogNormal',
                        'Normal', 'StudentsT', 'Tukey', 'Uniform', 'Weibull')){
    plot_df <- data.frame(x = seq(limits[1], limits[2], length.out = 5000))
    plot_df$y <- pdf(d, plot_df$x)

    out_plot <- ggplot(data = plot_df,
                    aes(x = x, y = y)) +
      geom_line() +
      plot_theme()
  }

  out_plot$mapping$d <- class(d)[1]

  for(i in seq_along(d))
    out_plot$mapping[[paste0("param", i)]] <- d[[i]]

  return(out_plot)
}

#' Stat for Area Under Curve
#'
#' @export
StatAUC <- ggplot2::ggproto(
  "StatAUC", ggplot2::Stat,
  compute_group = function(data, scales, from = from, to = to) {
    data[data$x < from | data$x > to, 'y'] <- 0

    return(data)
  }
)


#' Fill out area under the curve
#'
#' @param from Left end-point of interval
#' @param to right end-point of interval
#' @inheritParams ggplot2::layer
#' @inheritParams ggplot2::geom_area
#'
#' @export
#'
#' @examples
#'
#' X <- Normal()
#'
#' plot_pdf(X) + geom_auc(to = -0.645)
#' plot_pdf(X) + geom_auc(from = -0.645, to = 0.1)
geom_auc <- function(mapping = NULL, data = NULL,
                     position = "identity", na.rm = FALSE, show.legend = NA,
                     inherit.aes = TRUE, from = -Inf, to = Inf,
                     ...){
  ggplot2::layer(
    stat = StatAUC, geom = GeomArea, data = data, mapping = mapping,
    position = position, show.legend = show.legend, inherit.aes = inherit.aes,
    params = list(na.rm = na.rm, from = from, to = to, ...)
  )
}



#' Use stats::quantile if passing non-distribution object
#'
#' This function allows us to use the stats::quantile function along side
#' distributions3::quantile. It accepts both the distributions3 style arguments
#' (d, p) and stats style arguments (x, probs) as well as any combination of
#' the two.
#'
#' @export
quantile.default <- function(d, p, names = FALSE, ...){
  args <- list(...)

  if(!is.null(args[["x"]])){
    d <- args[["x"]]
    args[["x"]] <- NULL
  }

  if(!is.null(args[["probs"]])){
    p <- args[["probs"]]
    args[["probs"]] <- NULL
  }

  do.call(stats:::quantile.default,
          args = c(list(x = d, probs = p, names = names), args))
}
