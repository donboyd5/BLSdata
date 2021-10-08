#' Nonfarm employment, seasonally adjusted, monthly.
#'
#' A dataset containing BLS state and metropolitan area data, monthly.
#'
#' @format A data frame with approximately 350k rows; and 11 variables:
#' \describe{
#'   \item{date}{first day of month}
#'   \item{value}{monthly value}
#'   \item{series}{series code}
#'   \item{seriesf}{series name factor}
#'   \item{ssector}{super sector}
#'   \item{ssectorf}{super sector factor}
#'   \item{ind}{industry code}
#'   \item{indf}{industry code factor}
#'   \item{naics}{NAICS code}
#'   \item{level}{aggregation level}
#'   \item{sort}{BLS sort sequence}
#' }
#' @source \url{https://download.bls.gov/pub/time.series/ce/ce.data.01a.CurrentSeasAE/}
"eeasa"
