## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

library(dplyr)
library(ggplot2)
library(magrittr)
library(tealeaves)


## ----eval = FALSE, echo = TRUE------------------------------------------------
# 
# # install tidyverse packages if necessary
# # install.packages("tidyverse")
# 
# library(dplyr)
# library(ggplot2)
# library(magrittr)
# library(tealeaves)
# 
# # Parameter sets ----
# 
# cs <- tealeaves::make_constants()
# lp <- tealeaves::make_leafpar(
#   replace = list(
#     # Hypo- and amphistomatous leaves
#     logit_sr = set_units(c(-Inf, 0))
#   )
# )
# ep <- tealeaves::make_enviropar(
#   replace = list(
#     # Low and high light
#     S_sw = set_units(c(220, 660), "W/m^2"),
#     # Air temperature gradient
#     T_air = set_units(seq(278.15, 313.15, length.out = 25), "K")
#     )
# )
# 
# # Run tleaves ----
# tl_example1 <- tleaves(lp, ep, cs)
# 
# usethis::use_data(tl_example1)
# 

## ----plot temperature, echo = FALSE, eval = TRUE, fig.width=7-----------------

tl_example1 %<>%
  
  # Drop units for plotting
  mutate_if(function(x) inherits(x, what = "units"), drop_units) %>%
  
  # Calculate leaf temperature differential
  mutate(dT = T_leaf - T_air) %>%
  
  # Factorize stomatal ratio 
  mutate("Stomatal Ratio" = case_when(
    logit_sr == -Inf ~ "hypostomatous",
    logit_sr == 0 ~ "amphistomatous"
  )) %>%
  
  # Factorize light environment 
  mutate(Light = case_when(
    round(S_sw, 0) == 220 ~ "Shade",
    round(S_sw, 0) == 660 ~ "Sun"
  ))

ggplot(tl_example1, aes(T_air, dT, color = `Stomatal Ratio`)) +
  facet_grid(Light ~ .) + 
  geom_hline(yintercept = 0) +
  geom_line() +
  labs(x = "Air Temperature [K]", 
       y = "Leaf-to-Air Temperature Difference",
       color = "Stomatal Ratio") + 
  theme_minimal() + 
  theme(panel.grid.minor = element_blank()) +
  NULL


## ----plot transpiration, echo = FALSE, eval = TRUE, fig.width=7---------------

ggplot(tl_example1, aes(T_air, 1000 * E, color = `Stomatal Ratio`)) +
  facet_grid(Light ~ .) + 
  geom_line() +
  labs(x = "Air Temperature [K]", 
       y = expression(paste("Evaporation [mmol ", m^{-2}~s^{-1}, "]")),
       color = "Stomatal Ratio") + 
  theme_minimal() + 
  theme(panel.grid.minor = element_blank()) +
  NULL


