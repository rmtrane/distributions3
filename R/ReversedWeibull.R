#' Create a reversed Weibull distribution
#'
#' The reversed (or negated) Weibull distribution is a special case of the
#' `\link{GEV}` distribution, obtained when the GEV shape parameter \eqn{\xi}
#' is negative.  It may be referred to as a type III extreme value
#' distribution.
#'
#' @param location The location (maximum) parameter \eqn{m}.
#'   `location` can be any real number.  Defaults to `0`.
#' @param scale The scale parameter \eqn{s}.
#'   `scale` can be any positive number.  Defaults to `1`.
#' @param shape The scale parameter \eqn{\alpha}.
#'   `shape` can be any positive number.  Defaults to `1`.
#'
#' @return A `RevWeibull` object.
#' @export
#'
#' @family continuous distributions
#'
#' @details
#'
#'   We recommend reading this documentation on
#'   <https://alexpghayes.github.io/distributions3>, where the math
#'   will render with additional detail and much greater clarity.
#'
#'   In the following, let \eqn{X} be a reversed Weibull random variable with
#'   location parameter  `location` = \eqn{m}, scale parameter `scale` =
#'   \eqn{s}, and shape parameter `shape` = \eqn{\alpha}.
#'   An RevWeibull(\eqn{m, s, \alpha}) distribution is equivalent to a
#'   `\link{GEV}`(\eqn{m - s, s / \alpha, -1 / \alpha}) distribution.
#'
#'   If \eqn{X} has an RevWeibull(\eqn{m, \lambda, k}) distribution then
#'   \eqn{m - X} has a `\link{Weibull}`(\eqn{k, \lambda}) distribution,
#'   that is, a Weibull distribution with shape parameter \eqn{k} and scale
#'   parameter \eqn{\lambda}.
#'
#'   **Support**: \eqn{(-\infty, m)}.
#'
#'   **Mean**: \eqn{m + s\Gamma(1 + 1/\alpha)}.
#'
#'   **Median**: \eqn{m + s(\ln 2)^{1/\alpha}}{m + s(\ln 2)^(1/\alpha)}.
#'
#'   **Variance**:
#'   \eqn{s^2 [\Gamma(1 + 2 / \alpha) - \Gamma(1 + 1 / \alpha)^2]}.
#'
#'   **Probability density function (p.d.f)**:
#'
#'   \deqn{f(x) = \alpha s ^ {-1} [-(x - m) / s] ^ {\alpha - 1}%
#'         \exp\{-[-(x - m) / s] ^ {\alpha} \}}{%
#'        f(x) = (\alpha / s) [-(x - m) / s] ^ (\alpha - 1)%
#'         exp{-[-(x - m) / s] ^ \alpha}}
#'   for \eqn{x < m}.  The p.d.f. is 0 for \eqn{x \geq m}{x >= m}.
#'
#'   **Cumulative distribution function (c.d.f)**:
#'
#'   \deqn{F(x) = \exp\{-[-(x - m) / s] ^ {\alpha} \}}{%
#'        F(x) = exp{-[-(x - m) / s] ^ \alpha}}
#'   for \eqn{x < m}.  The c.d.f. is 1 for \eqn{x \geq m}{x >= m}.
#'
#' @examples
#'
#' set.seed(27)
#'
#' X <- RevWeibull(1, 2)
#' X
#'
#' random(X, 10)
#'
#' pdf(X, 0.7)
#' log_pdf(X, 0.7)
#'
#' cdf(X, 0.7)
#' quantile(X, 0.7)
#'
#' cdf(X, quantile(X, 0.7))
#' quantile(X, cdf(X, 0.7))
RevWeibull <- function(location = 0, scale = 1, shape = 1) {
  if (scale <= 0) {
    stop("scale must be positive")
  }
  if (shape <= 0) {
    stop("shape must be positive")
  }
  d <- list(location = location, scale = scale, shape = shape)
  class(d) <- c("RevWeibull", "distribution")
  d
}

#' @export
print.RevWeibull <- function(x, ...) {
  cat(glue("RevWeibull distribution (location = {x$location},
           scale = {x$scale}, shape = {x$shape})\n"))
}

#' Draw a random sample from an RevWeibull distribution
#'
#' @inherit RevWeibull examples
#'
#' @param d A `RevWeibull` object created by a call to [RevWeibull()].
#' @param n The number of samples to draw. Defaults to `1L`.
#' @param ... Unused. Unevaluated arguments will generate a warning to
#'   catch mispellings or other possible errors.
#'
#' @return A numeric vector of length `n`.
#' @export
#'
random.RevWeibull <- function(d, n = 1L, ...) {
  # Convert to the GEV parameterisation
  loc <- d$location - d$scale
  scale <- d$scale / d$shape
  shape <- -1 / d$shape
  revdbayes::rgev(n = n, loc = loc, scale = scale, shape = shape)
}

#' Evaluate the probability mass function of an RevWeibull distribution
#'
#' @inherit RevWeibull examples
#' @inheritParams random.RevWeibull
#'
#' @param x A vector of elements whose probabilities you would like to
#'   determine given the distribution `d`.
#' @param ... Unused. Unevaluated arguments will generate a warning to
#'   catch mispellings or other possible errors.
#'
#' @return A vector of probabilities, one for each element of `x`.
#' @export
#'
pdf.RevWeibull <- function(d, x, ...) {
  # Convert to the GEV parameterisation
  loc <- d$location - d$scale
  scale <- d$scale / d$shape
  shape <- -1 / d$shape
  revdbayes::dgev(x = x, loc = loc, scale = scale, shape = shape)
}

#' @rdname pdf.RevWeibull
#' @export
#'
log_pdf.RevWeibull <- function(d, x, ...) {
  # Convert to the GEV parameterisation
  loc <- d$location - d$scale
  scale <- d$scale / d$shape
  shape <- -1 / d$shape
  revdbayes::dgev(x = x, loc = loc, scale = scale, shape = shape, log = TRUE)
}

#' Evaluate the cumulative distribution function of an RevWeibull distribution
#'
#' @inherit RevWeibull examples
#' @inheritParams random.RevWeibull
#'
#' @param x A vector of elements whose cumulative probabilities you would
#'   like to determine given the distribution `d`.
#' @param ... Unused. Unevaluated arguments will generate a warning to
#'   catch mispellings or other possible errors.
#'
#' @return A vector of probabilities, one for each element of `x`.
#' @export
#'
cdf.RevWeibull <- function(d, x, ...) {
  # Convert to the GEV parameterisation
  loc <- d$location - d$scale
  scale <- d$scale / d$shape
  shape <- -1 / d$shape
  revdbayes::pgev(q = x, loc = loc, scale = scale, shape = shape)
}

#' Determine quantiles of a RevWeibull distribution
#'
#' `quantile()` is the inverse of `cdf()`.
#'
#' @inherit RevWeibull examples
#' @inheritParams random.RevWeibull
#'
#' @param p A vector of probabilities.
#' @param ... Unused. Unevaluated arguments will generate a warning to
#'   catch mispellings or other possible errors.
#'
#' @return A vector of quantiles, one for each element of `p`.
#' @export
#'
quantile.RevWeibull <- function(d, p, ...) {
  # Convert to the GEV parameterisation
  loc <- d$location - d$scale
  scale <- d$scale / d$shape
  shape <- -1 / d$shape
  revdbayes::qgev(p = p, loc = loc, scale = scale, shape = shape)
}
