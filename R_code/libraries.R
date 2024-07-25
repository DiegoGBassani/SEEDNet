# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Calculate indicator prevalence at the cluster level for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description:  This file download and loads all libraries used in the analyses
###################
# Attributions:

###################
#Notes:

###################


# Package names
packages <- c(
  "rdhs",
  "tidyverse",  # most variable creation here uses tidyverse 
  "tidyselect", # used to select variables in FP_EVENTS.R
  "haven",      # used for Haven labeled DHS variables
  "labelled",   # used for Haven labeled variable creation
  "expss",    # for creating tables with Haven labeled data
  "naniar",   # to use replace_with_na function
  "here",       # to get R project path
  "sjlabelled", # to set variables label
  "survey",  # to calculate weighted ratio for GAR
  "sjmisc",
  "stringi",
  "miceadds",
  "haven",
  "data.table",
  "dplyr",
  "tibble",
  "reshape",
  "ggplot2",
  "mltools",
  "DataCombine",
  "strex",
  "broom",
  "cowplot",
  "tidyverse",
  "DHS.rates",
  "progress")

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}

# Packages loading
invisible(lapply(packages, library, character.only = TRUE))
