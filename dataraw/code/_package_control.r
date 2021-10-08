
# navigation notes ----
# alt-o, shift-alt-o
# alt-l, shift-alt-l

# alt-r

# package building ---
# http://r-pkgs.had.co.nz/  # IMPORTANT

# Install Package: 'Ctrl + Shift + B'
# Check Package: 'Ctrl + Shift + E'
# Test Package: 'Ctrl + Shift + T'


# edit the DESCRIPTION file using these commands
# library(usethis)
# This block will update the DESCRIPTION file when devtools::document() is run (or via shift-ctrl-d) ####
usethis::use_package("dplyr")
usethis::use_package("lubridate")
usethis::use_package("magrittr")
usethis::use_package("precis")
usethis::use_package("scales")
usethis::use_package("stats")
usethis::use_package("tibble")
usethis::use_package("zoo")

# check best compression
# https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Data-in-packages
# applied to a source package without any ‘LazyDataCompression’ field
CheckLazyDataCompression <- function(pkg)
{
  pkg_name <- sub("_.*", "", pkg)
  lib <- tempfile(); dir.create(lib)
  zs <- c("gzip", "bzip2", "xz")
  res <- integer(3); names(res) <- zs
  for (z in zs) {
    opts <- c(paste0("--data-compress=", z),
              "--no-libs", "--no-help", "--no-demo", "--no-exec", "--no-test-load")
    install.packages(pkg, lib, INSTALL_opts = opts, repos = NULL, quiet = TRUE)
    res[z] <- file.size(file.path(lib, pkg_name, "data", "Rdata.rdb"))
  }
  ceiling(res/1024)
}
# CheckLazyDataCompression("BLSdata")  # did not get this to work


# This block (if uncommented) will update the NAMESPACE file when devtools::document() is run (or via shift-ctrl-d) ####

#' #' Pipe operator
#' #'
#' #' See \code{magrittr::\link[magrittr]{\%>\%}} for details.
#' #'
#' #' @name %>%
#' #' @rdname pipe
#' #' @keywords internal
#' #' @export
#' #' @importFrom magrittr %>%
#' #' @usage lhs \%>\% rhs
#' NULL
