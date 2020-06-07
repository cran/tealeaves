## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------

library(tealeaves)

leaf_par   <- make_leafpar()   # leaf parameters
enviro_par <- make_enviropar() # environmental parameters
constants  <- make_constants() # physical constants

enviro_par$T_sky


## -----------------------------------------------------------------------------

enviro_par <- make_enviropar(
  replace = list(T_sky = function(pars) {pars$T_air})
)
enviro_par$T_sky

T_leaf <- tleaf(leaf_par, enviro_par, constants, quiet = TRUE)

knitr::kable(T_leaf)


