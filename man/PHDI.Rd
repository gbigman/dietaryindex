% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PHDI.R
\name{PHDI}
\alias{PHDI}
\title{PHD Calculation}
\usage{
PHDI(
  SERV_DATA,
  RESPONDENTID,
  GENDER,
  TOTALKCAL_PHDI,
  WGRAIN_SERV_PHDI,
  STARCHY_VEG_SERV_PHDI,
  VEG_SERV_PHDI,
  FRT_SERV_PHDI,
  DAIRY_SERV_PHDI,
  REDPROC_MEAT_SERV_PHDI,
  POULTRY_SERV_PHDI,
  EGG_SERV_PHDI,
  FISH_SERV_PHDI,
  NUTS_SERV_PHDI,
  LEGUMES_SERV_PHDI,
  SOY_SERV_PHDI,
  ADDED_FAT_UNSAT_SERV_PHDI,
  ADDED_FAT_SAT_TRANS_SERV_PHDI,
  ADDED_SUGAR_SERV_PHDI
)
}
\arguments{
\item{SERV_DATA}{The raw data file that includes all the serving sizes of foods and nutrients consumed per 1 day}

\item{RESPONDENTID}{The unique participant ID for each participant}

\item{GENDER}{The gender of the participant. 2 is female and 1 is male.}

\item{TOTALKCAL_PHDI}{The total kcal}

\item{WGRAIN_SERV_PHDI}{The serving size of whole grains, unit=grams/day}

\item{STARCHY_VEG_SERV_PHDI}{The serving size of starchy vegetables, such as potatos, cassava, unit=grams/day}

\item{VEG_SERV_PHDI}{The serving size of All vegetable except potatoes, starchy vegetables, and LEGUMES, unit=grams/day}

\item{FRT_SERV_PHDI}{The serving size of All whole fruits and no fruit juice, unit=grams/day}

\item{DAIRY_SERV_PHDI}{The serving size of All dairy products, unit=grams/day}

\item{REDPROC_MEAT_SERV_PHDI}{The serving size of red and processed meats, including Beef, pork, lamb, goat, veal, sausages, bacon, salami, ham, hot dog, deli meat, unit=grams/day}

\item{POULTRY_SERV_PHDI}{The serving size of Poultry, including Chicken, turkey, duck, goose, ostrich, unit=grams/day}

\item{EGG_SERV_PHDI}{The serving size of Eggs with shell, unit=grams/day}

\item{FISH_SERV_PHDI}{The serving size of Fish and shellfish, unit=grams/day}

\item{NUTS_SERV_PHDI}{The serving size of nuts and seeds, including peanuts, tree nuts- - walnuts, almond, hazelnuts, pecan, cashew, pistachio, unit=grams/day}

\item{LEGUMES_SERV_PHDI}{The serving size of Nonsoy LEGUMES, including Beans, peas, lentils, chickpeas, unit=grams/day}

\item{SOY_SERV_PHDI}{The serving size of Soy products, including Tofu, tempeh, soy milk, soy yogurt, soy cheese, unit=grams/day}

\item{ADDED_FAT_UNSAT_SERV_PHDI}{The serving size of Added unsaturated fat, e.g. olive soybean, rapeseed, sunflower, peanuts oil, excluding transfat, unit=% of total kcal/day}

\item{ADDED_FAT_SAT_TRANS_SERV_PHDI}{The serving size of Added saturated fats and trans fat, e.g. butter, lard, coconuts oil, palm oil, unit=% of total kcal/day}

\item{ADDED_SUGAR_SERV_PHDI}{The serving size of Added sugar, including the added sugar from all sweeteners and fruit juice, unit=% of total kcal/day}
}
\value{
The PHDI index/score, PHDI and its component scores
}
\description{
Calculate the PHDI, The Planetary Health Diet Index that quantifies adherence to the reference diet included in the EAT-Lancet report Willett et al (2019), using the serving sizes of foods and nutrients consumed per 1 day
}
\examples{
data("PHDI_VALIDATION")
PHDI(SERV_DATA = PHDI_VALIDATION, PHDI_VALIDATION$id, PHDI_VALIDATION$gender, PHDI_VALIDATION$TOTALKCAL_PHDI, PHDI_VALIDATION$WGRAIN_SERV_PHDI, PHDI_VALIDATION$STARCHY_VEG_SERV_PHDI, PHDI_VALIDATION$VEG_SERV_PHDI, PHDI_VALIDATION$FRT_SERV_PHDI, PHDI_VALIDATION$DAIRY_SERV_PHDI, PHDI_VALIDATION$REDPROC_MEAT_SERV_PHDI, PHDI_VALIDATION$POULTRY_SERV_PHDI, PHDI_VALIDATION$EGG_SERV_PHDI, PHDI_VALIDATION$FISH_SERV_PHDI, PHDI_VALIDATION$NUTS_SERV_PHDI, PHDI_VALIDATION$LEGUMES_SERV_PHDI, PHDI_VALIDATION$SOY_SERV_PHDI, PHDI_VALIDATION$ADDED_FAT_UNSAT_SERV_PHDI, PHDI_VALIDATION$ADDED_FAT_SAT_TRANS_SERV_PHDI, PHDI_VALIDATION$ADDED_SUGAR_SERV_PHDI)
}
