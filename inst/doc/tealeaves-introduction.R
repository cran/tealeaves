## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE,
  message = FALSE,
  eval = TRUE
)

## ---- mwe---------------------------------------------------------------------

library(magrittr)
library(tealeaves)

# Leaving the make_* functions empty will automatically default to defaults
# parameters.
leaf_par   <- make_leafpar()   # leaf parameters
enviro_par <- make_enviropar() # environmental parameters
constants  <- make_constants() # physical constants

T_leaf <- tleaf(leaf_par, enviro_par, constants, quiet = TRUE)

T_leaf %>% knitr::kable()


## ---- replace-defaults--------------------------------------------------------

# Use the `replace` argument to replace defaults. This must be a named list, and
# each named element must have the proper units specified. See `?make_parameters`
# for all parameter names and proper units.

# First, we'll change stomatal conductance to 4 umol / (m^2 s Pa)
leaf_par <- make_leafpar(
  replace = list(
    g_sw = set_units(4, "umol/m^2/s/Pa")
    )
  )

# Next, we'll change the air temperature to 25 degree C (= 298.15 K)
enviro_par <- make_enviropar(
  replace = list(
    T_air = set_units(298.15, "K")
    )
  )

# Physical constants probably do not need to be replaced in most cases,
# that's why we call them 'constants'!
constants  <- make_constants()

T_leaf <- tleaf(leaf_par, enviro_par, constants, quiet = TRUE)

T_leaf %>% knitr::kable()


## ---- environmental-gradients-------------------------------------------------

# As before, use the `replace` argument to replace defaults, but this time we
# enter multiple values

# First, we'll change stomatal conductance to to 2 and 4 umol / (m^2 s Pa)
leaf_par  <- make_leafpar(
  replace = list(
    g_sw = set_units(c(2, 4), "umol/m^2/s/Pa")
    )
  )

# Next, we'll change the air temperature to 20 and 25 degree C (= 293.15 and 298.15 K)
enviro_par <- make_enviropar(
  replace = list(
    T_air = set_units(c(293.15, 298.15), "K")
    )
  )

constants  <- make_constants()

# Now there should be 4 combinations (high and low g_sw crossed with high and low T_air)
T_leaves <- tleaves(leaf_par, enviro_par, constants, progress = FALSE, 
                    quiet = TRUE, set_units = FALSE)

T_leaves %>% 
  dplyr::select(T_air, g_sw, T_leaf) %>%
  knitr::kable()


## ---- parallel-example--------------------------------------------------------

# We'll use the `replace` argument to enter multiple air temperatures and two light levels

leaf_par  <- make_leafpar()

enviro_par <- make_enviropar(
  replace = list(
    S_sw = set_units(c(300, 1000), "W/m^2"),
    T_air = set_units(seq(273.15, 313.15, length.out = 10), "K")
    )
  )

constants  <- make_constants()

tl <- tleaves(leaf_par, enviro_par, constants, progress = FALSE, quiet = TRUE,
              parallel = TRUE)
tl$T_air %<>% drop_units() # for plotting
tl$T_leaf %<>% drop_units() # for plotting
tl %<>% dplyr::mutate(Light = dplyr::case_when(
 round(drop_units(S_sw), 0) == 300 ~ "Shade",
 round(drop_units(S_sw), 0) == 1000 ~ "Sun"
))

# Plot T_air versus T_leaf - T_air at different light levels
library(ggplot2)
ggplot(tl, aes(T_air, T_leaf - T_air, color = Light)) +
  geom_line() +
  xlab("Air Temperature [K]") +
  ylab("Leaf - Air Temperature [K]") +
  theme_minimal() +
  NULL


