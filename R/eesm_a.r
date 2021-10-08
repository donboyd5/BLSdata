#' Employment-related data for states and metro areas, annual.
#'
#' A dataset containing BLS state and metropolitan area data, annual.
#'
#' @format A data frame with approximately 500k rows; and 14 variables:
#' \describe{
#'   \item{year}{calendar year}
#'   \item{season}{S for seasonally adjusted, U for unadjusted}
#'   \item{dtype}{data type}
#'   \item{dtypef}{data type factor}
#'   \item{ssector}{super sector}
#'   \item{ssectorf}{super sector factor}
#'   \item{ind}{industry code}
#'   \item{indf}{industry code factor}
#'   \item{stabbr}{state abbreviation}
#'   \item{stcode}{state fips code}
#'   \item{stname}{state name}
#'   \item{area}{area code}
#'   \item{areaf}{area code factor}
#'   \item{value}{annual average value}
#' }
#' @source \url{https://download.bls.gov/pub/time.series/compressed/tape.format/}
"eesm_a"
