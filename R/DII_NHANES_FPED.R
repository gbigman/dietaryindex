#' DII_NHANES_FPED
#'
#' Calculate the DII for the NHANES_FPED data (after 2005) within 1 step
#' @import dplyr
#' @import readr
#' @import haven
#' @param FPED_PATH The file path for the FPED data. The file name should be like: fpre_dr1tot_1718.sas7bdat
#' @param NUTRIENT_PATH The file path for the NUTRIENT data. The file name should be like: DR1TOT_J.XPT
#' @param DEMO_PATH The file path for the DEMOGRAPHIC data. The file name should be like: DEMO_J.XPT
#' @return The DII and its component scores
#' @examples
#' data("NHANES_20172018")
#' DII_NHANES_FPED(FPED_PATH = NHANES_20172018$FPED, NUTRIENT_PATH = NHANES_20172018$NUTRIENT, DEMO_PATH = NHANES_20172018$DEMO, FPED_PATH2 = NHANES_20172018$FPED2, NUTRIENT_PATH2 = NHANES_20172018$NUTRIENT2)
#' @export

DII_NHANES_FPED = function(FPED_PATH = NULL, NUTRIENT_PATH = NULL, DEMO_PATH, FPED_PATH2 = NULL, NUTRIENT_PATH2 = NULL) {
    # stop if the input data is not provided for any day
    if (is.null(FPED_PATH) & is.null(NUTRIENT_PATH) & is.null(FPED_PATH2) & is.null(NUTRIENT_PATH2)) {
        stop("Please provide the file path for the FPED and NUTRIENT data, day 1 or day 2 or day 1 and day 2.")
    }

    # Load the DII internal database for the calculation
    Variable = c(
        "ALCOHOL", "VITB12", "VITB6", "BCAROTENE", "CAFFEINE", "CARB", "CHOLES", "KCAL", "EUGENOL",
        "TOTALFAT", "FIBER", "FOLICACID", "GARLIC", "GINGER", "IRON", "MG", "MUFA", "NIACIN", "N3FAT", "N6FAT", "ONION", "PROTEIN", "PUFA",
        "RIBOFLAVIN", "SAFFRON", "SATFAT", "SE", "THIAMIN", "TRANSFAT", "TURMERIC", "VITA", "VITC", "VITD", "VITE", "ZN", "TEA",
        "FLA3OL", "FLAVONES", "FLAVONOLS", "FLAVONONES", "ANTHOC", "ISOFLAVONES", "PEPPER", "THYME", "ROSEMARY"
    )

    Overall_inflammatory_score = c(
        -0.278, 0.106, -0.365, -0.584, -0.11, 0.097, 0.11, 0.18, -0.14, 0.298, -0.663, -0.19, -0.412, -0.453, 0.032, -0.484, -0.009,
        -0.246, -0.436, -0.159, -0.301, 0.021, -0.337, -0.068, -0.14, 0.373, -0.191, -0.098, 0.229, -0.785, -0.401, -0.424, -0.446, -0.419, -0.313,
        -0.536, -0.415, -0.616, -0.467, -0.25, -0.131, -0.593, -0.131, -0.102, -0.013
    )

    Global_mean = c(
        13.98, 5.15, 1.47, 3718, 8.05, 272.2, 279.4, 2056, 0.01, 71.4, 18.8, 273, 4.35, 59, 13.35, 310.1, 27, 25.9, 1.06, 10.8, 35.9,
        79.4, 13.88, 1.7, 0.37, 28.6, 67, 1.7, 3.15, 533.6, 983.9, 118.2, 6.26, 8.73, 9.84,
        1.69, 95.8, 1.55, 17.7, 11.7, 18.05, 1.2, 10, 0.33, 1
    )

    SD = c(
        3.72, 2.7, 0.74, 1720, 6.67, 40, 51.2, 338, 0.08, 19.4, 4.9, 70.7, 2.9, 63.2, 3.71, 139.4, 6.1, 11.77, 1.06, 7.5, 18.4, 13.9, 3.76, 0.79, 1.78,
        8, 25.1, 0.66, 3.75, 754.3, 518.6, 43.46, 2.21, 1.49, 2.19,
        1.53, 85.9, 0.07, 6.79, 3.82, 21.14, 0.2, 7.07, 0.99, 15
    )

    DII_STD = data.frame(Variable, Overall_inflammatory_score, Global_mean, SD)

    # first day data calculation if the user provides the first day data for FPED_PATH and NUTRIENT_PATH
    if (!is.null(FPED_PATH) & !is.null(NUTRIENT_PATH)) {
        if (is.character(FPED_PATH) == TRUE) {
            FPED = read_sas(FPED_PATH)
        } else {
            FPED = FPED_PATH
        }

        if (is.character(NUTRIENT_PATH) == TRUE) {
            NUTRIENT = read_xpt(NUTRIENT_PATH)
        } else {
            NUTRIENT = NUTRIENT_PATH
        }

        if (is.character(DEMO_PATH) == TRUE) {
            DEMO = read_xpt(DEMO_PATH)
        } else {
            DEMO = DEMO_PATH
        }

        if ("DR1ILINE" %in% colnames(FPED) | "DR1ILINE" %in% colnames(NUTRIENT)) {
            stop("Please use the population-level first day data. The file name should be like: Totals.csv")
        }

        # Select only the high quality data
        NUTRIENT = NUTRIENT %>%
            filter(DR1DRSTZ == 1) %>%
            arrange(SEQN)

        DEMO = DEMO %>%
            filter(RIDAGEYR >= 2) %>%
            dplyr::select(SEQN, RIDAGEYR, RIAGENDR, SDDSRVYR, SDMVPSU, SDMVSTRA) %>%
            arrange(SEQN)

        FPED = FPED %>%
            arrange(SEQN)

        # Merge the demographic data with the nutrient and FPED data
        COHORT = NUTRIENT %>%
            inner_join(DEMO, by = c("SEQN" = "SEQN")) %>%
            left_join(FPED, by = c("SEQN" = "SEQN"))

        # Serving size calculation for DII
        COHORT = COHORT %>%
            filter(DR1TKCAL > 0) %>%
            dplyr::mutate(
                ALCOHOL = DR1TALCO,
                VITB12 = DR1TVB12,
                VITB6 = DR1TVB6,
                BCAROTENE = DR1TBCAR,
                CAFFEINE = DR1TCAFF / 1000,
                CARB = DR1TCARB,
                CHOLES = DR1TCHOL,
                KCAL = DR1TKCAL,
                TOTALFAT = DR1TTFAT,
                FIBER = DR1TFIBE,
                FOLICACID = DR1TFA,
                IRON = DR1TIRON,
                MG = DR1TMAGN,
                MUFA = DR1TMFAT,
                NIACIN = DR1TNIAC,
                N3FAT = DR1TP183 + DR1TP184 + DR1TP205 + DR1TP225 + DR1TP226,
                N6FAT = DR1TP183 + DR1TP204,
                PROTEIN = DR1TPROT,
                PUFA = DR1TPFAT,
                RIBOFLAVIN = DR1TVB2,
                SATFAT = DR1TSFAT,
                SE = DR1TSELE,
                THIAMIN = DR1TVB1,
                VITA = DR1TVARA,
                VITC = DR1TVC,
                VITD = tryCatch(DR1TVD * 0.025, error = function(e) return(NULL)),
                VITE = DR1TATOC,
                ZN = DR1TZINC
            ) %>%
            dplyr::select(
                SEQN, ALCOHOL, VITB12, VITB6, BCAROTENE, CAFFEINE, CARB, CHOLES, KCAL, TOTALFAT, FIBER, FOLICACID,
                IRON, MG, MUFA, NIACIN, N3FAT, N6FAT, PROTEIN, PUFA, RIBOFLAVIN, SATFAT, SE, THIAMIN,
                VITA, VITC, VITD, VITE, ZN
            )

        COHORT = COHORT %>%
            tidyr::pivot_longer(-SEQN, names_to = "Variable", values_to = "Value")

        # Score calculation for DII
        COHORT = COHORT %>%
            dplyr::inner_join(DII_STD, by = c("Variable")) %>%
            dplyr::mutate(
                Z_SCORE = (Value - Global_mean) / SD,
                PERCENTILE = pnorm(Z_SCORE) * 2 - 1,
                IND_DII_SCORE = PERCENTILE * Overall_inflammatory_score
            ) %>%
            tidyr::pivot_wider(names_from = Variable, values_from = IND_DII_SCORE) %>%
            dplyr::group_by(SEQN) %>%
            dplyr::summarize(
                DII_ALL = sum(ALCOHOL, VITB12, VITB6, BCAROTENE, CAFFEINE, CARB, CHOLES, KCAL, TOTALFAT, FIBER, FOLICACID,
                    IRON, MG, MUFA, NIACIN, N3FAT, N6FAT, PROTEIN, PUFA, RIBOFLAVIN, SATFAT, SE, THIAMIN,
                    VITA, VITC, VITD, VITE, ZN,
                    na.rm = TRUE
                ),
                DII_NOETOH = sum(VITB12, VITB6, BCAROTENE, CAFFEINE, CARB, CHOLES, KCAL, TOTALFAT, FIBER, FOLICACID,
                    IRON, MG, MUFA, NIACIN, N3FAT, N6FAT, PROTEIN, PUFA, RIBOFLAVIN, SATFAT, SE, THIAMIN,
                    VITA, VITC, VITD, VITE, ZN,
                    na.rm = TRUE
                ),
                ALCOHOL = sum(ALCOHOL, na.rm = TRUE),
                VITB12 = sum(VITB12, na.rm = TRUE),
                VITB6 = sum(VITB6, na.rm = TRUE),
                BCAROTENE = sum(BCAROTENE, na.rm = TRUE),
                CAFFEINE = sum(CAFFEINE, na.rm = TRUE),
                CARB = sum(CARB, na.rm = TRUE),
                CHOLES = sum(CHOLES, na.rm = TRUE),
                KCAL = sum(KCAL, na.rm = TRUE),
                TOTALFAT = sum(TOTALFAT, na.rm = TRUE),
                FIBER = sum(FIBER, na.rm = TRUE),
                FOLICACID = sum(FOLICACID, na.rm = TRUE),
                IRON = sum(IRON, na.rm = TRUE),
                MG = sum(MG, na.rm = TRUE),
                MUFA = sum(MUFA, na.rm = TRUE),
                NIACIN = sum(NIACIN, na.rm = TRUE),
                N3FAT = sum(N3FAT, na.rm = TRUE),
                N6FAT = sum(N6FAT, na.rm = TRUE),
                PROTEIN = sum(PROTEIN, na.rm = TRUE),
                PUFA = sum(PUFA, na.rm = TRUE),
                RIBOFLAVIN = sum(RIBOFLAVIN, na.rm = TRUE),
                SATFAT = sum(SATFAT, na.rm = TRUE),
                SE = sum(SE, na.rm = TRUE),
                THIAMIN = sum(THIAMIN, na.rm = TRUE),
                VITA = sum(VITA, na.rm = TRUE),
                VITC = sum(VITC, na.rm = TRUE),
                VITD = sum(VITD, na.rm = TRUE),
                VITE = sum(VITE, na.rm = TRUE),
                ZN = sum(ZN, na.rm = TRUE)
            )
    }

    # the second day data calculation if the user provides the second day data for FPED_PATH2 and NUTRIENT_PATH2
    if (!is.null(FPED_PATH2) & !is.null(NUTRIENT_PATH2)) {
        if (is.character(FPED_PATH2) == TRUE) {
            FPED2 = read_sas(FPED_PATH2)
        } else {
            FPED2 = FPED_PATH2
        }

        if (is.character(NUTRIENT_PATH2) == TRUE) {
            NUTRIENT2 = read_xpt(NUTRIENT_PATH2)
        } else {
            NUTRIENT2 = NUTRIENT_PATH2
        }

        if (is.character(DEMO_PATH) == TRUE) {
            DEMO = read_xpt(DEMO_PATH)
        } else {
            DEMO = DEMO_PATH
        }

        if ("DR2ILINE" %in% colnames(FPED2) | "DR2ILINE" %in% colnames(NUTRIENT2)) {
            stop("Please use the population-level second day data. The file name should be like: Totals.csv")
        }

        NUTRIENT2 = NUTRIENT2 %>%
            filter(DR2DRSTZ == 1) %>%
            arrange(SEQN)

        DEMO = DEMO %>%
            filter(RIDAGEYR >= 2) %>%
            dplyr::select(SEQN, RIDAGEYR, RIAGENDR, SDDSRVYR, SDMVPSU, SDMVSTRA) %>%
            arrange(SEQN)

        FPED2 = FPED2 %>%
            arrange(SEQN)

        COHORT2 = NUTRIENT2 %>%
            inner_join(DEMO, by = c("SEQN" = "SEQN")) %>%
            left_join(FPED2, by = c("SEQN" = "SEQN"))

        # Serving size calculation for DII
        COHORT2 = COHORT2 %>%
            filter(DR2TKCAL > 0) %>%
            dplyr::mutate(
                ALCOHOL = DR2TALCO,
                VITB12 = DR2TVB12,
                VITB6 = DR2TVB6,
                BCAROTENE = DR2TBCAR,
                CAFFEINE = DR2TCAFF / 1000,
                CARB = DR2TCARB,
                CHOLES = DR2TCHOL,
                KCAL = DR2TKCAL,
                TOTALFAT = DR2TTFAT,
                FIBER = DR2TFIBE,
                FOLICACID = DR2TFA,
                IRON = DR2TIRON,
                MG = DR2TMAGN,
                MUFA = DR2TMFAT,
                NIACIN = DR2TNIAC,
                N3FAT = DR2TP183 + DR2TP184 + DR2TP205 + DR2TP225 + DR2TP226,
                N6FAT = DR2TP183 + DR2TP204,
                PROTEIN = DR2TPROT,
                PUFA = DR2TPFAT,
                RIBOFLAVIN = DR2TVB2,
                SATFAT = DR2TSFAT,
                SE = DR2TSELE,
                THIAMIN = DR2TVB1,
                VITA = DR2TVARA,
                VITC = DR2TVC,
                VITD = tryCatch(DR2TVD * 0.025, error = function(e) return(NULL)),
                VITE = DR2TATOC,
                ZN = DR2TZINC
            ) %>%
            dplyr::select(
                SEQN, ALCOHOL, VITB12, VITB6, BCAROTENE, CAFFEINE, CARB, CHOLES, KCAL, TOTALFAT, FIBER, FOLICACID,
                IRON, MG, MUFA, NIACIN, N3FAT, N6FAT, PROTEIN, PUFA, RIBOFLAVIN, SATFAT, SE, THIAMIN,
                VITA, VITC, VITD, VITE, ZN
            )

        COHORT2 = COHORT2 %>%
            tidyr::pivot_longer(-SEQN, names_to = "Variable", values_to = "Value")


        # Score calculation for DII
        COHORT2 = COHORT2 %>%
            dplyr::inner_join(DII_STD, by = c("Variable")) %>%
            dplyr::mutate(
                Z_SCORE = (Value - Global_mean) / SD,
                PERCENTILE = pnorm(Z_SCORE) * 2 - 1,
                IND_DII_SCORE = PERCENTILE * Overall_inflammatory_score
            ) %>%
            tidyr::pivot_wider(names_from = Variable, values_from = IND_DII_SCORE) %>%
            dplyr::group_by(SEQN) %>%
            dplyr::summarize(
                DII_ALL = sum(ALCOHOL, VITB12, VITB6, BCAROTENE, CAFFEINE, CARB, CHOLES, KCAL, TOTALFAT, FIBER, FOLICACID,
                    IRON, MG, MUFA, NIACIN, N3FAT, N6FAT, PROTEIN, PUFA, RIBOFLAVIN, SATFAT, SE, THIAMIN,
                    VITA, VITC, VITD, VITE, ZN,
                    na.rm = TRUE
                ),
                DII_NOETOH = sum(VITB12, VITB6, BCAROTENE, CAFFEINE, CARB, CHOLES, KCAL, TOTALFAT, FIBER, FOLICACID,
                    IRON, MG, MUFA, NIACIN, N3FAT, N6FAT, PROTEIN, PUFA, RIBOFLAVIN, SATFAT, SE, THIAMIN,
                    VITA, VITC, VITD, VITE, ZN,
                    na.rm = TRUE
                ),
                ALCOHOL = sum(ALCOHOL, na.rm = TRUE),
                VITB12 = sum(VITB12, na.rm = TRUE),
                VITB6 = sum(VITB6, na.rm = TRUE),
                BCAROTENE = sum(BCAROTENE, na.rm = TRUE),
                CAFFEINE = sum(CAFFEINE, na.rm = TRUE),
                CARB = sum(CARB, na.rm = TRUE),
                CHOLES = sum(CHOLES, na.rm = TRUE),
                KCAL = sum(KCAL, na.rm = TRUE),
                TOTALFAT = sum(TOTALFAT, na.rm = TRUE),
                FIBER = sum(FIBER, na.rm = TRUE),
                FOLICACID = sum(FOLICACID, na.rm = TRUE),
                IRON = sum(IRON, na.rm = TRUE),
                MG = sum(MG, na.rm = TRUE),
                MUFA = sum(MUFA, na.rm = TRUE),
                NIACIN = sum(NIACIN, na.rm = TRUE),
                N3FAT = sum(N3FAT, na.rm = TRUE),
                N6FAT = sum(N6FAT, na.rm = TRUE),
                PROTEIN = sum(PROTEIN, na.rm = TRUE),
                PUFA = sum(PUFA, na.rm = TRUE),
                RIBOFLAVIN = sum(RIBOFLAVIN, na.rm = TRUE),
                SATFAT = sum(SATFAT, na.rm = TRUE),
                SE = sum(SE, na.rm = TRUE),
                THIAMIN = sum(THIAMIN, na.rm = TRUE),
                VITA = sum(VITA, na.rm = TRUE),
                VITC = sum(VITC, na.rm = TRUE),
                VITD = sum(VITD, na.rm = TRUE),
                VITE = sum(VITE, na.rm = TRUE),
                ZN = sum(ZN, na.rm = TRUE)
            )
    }

    if (!is.null(FPED_PATH) & !is.null(NUTRIENT_PATH) & is.null(FPED_PATH2) & is.null(NUTRIENT_PATH2)) {
        # print a reminder that this function does not use all the original DII variables
        print("Reminder: This function does not use all the original DII variables. Eugenol, garlic, ginger, onion, trans fat, turmeric, Green/black tea, Flavan-3-ol, Flavones, Flavonols, Flavonones, Anthocyanidins, Isoflavones, Pepper, Thyme/oregano, Rosemary are not included because they are not available in NHANES.")
        return(COHORT)
    }

    if (is.null(FPED_PATH) & is.null(NUTRIENT_PATH) & !is.null(FPED_PATH2) & !is.null(NUTRIENT_PATH2)) {
        # print a reminder that this function does not use all the original DII variables
        print("Reminder: This function does not use all the original DII variables. Eugenol, garlic, ginger, onion, trans fat, turmeric, Green/black tea, Flavan-3-ol, Flavones, Flavonols, Flavonones, Anthocyanidins, Isoflavones, Pepper, Thyme/oregano, Rosemary are not included because they are not available in NHANES.")
        return(COHORT2)
    }

    # merge two days data if they both exist
    if (!is.null(FPED_PATH) & !is.null(NUTRIENT_PATH) & !is.null(FPED_PATH2) & !is.null(NUTRIENT_PATH2)) {
        COHORT12 <- inner_join(COHORT, COHORT2, by = "SEQN") %>%
            mutate(
                DII_ALL = (DII_ALL.x + DII_ALL.y) / 2,
                DII_NOETOH = (DII_NOETOH.x + DII_NOETOH.y) / 2,
                ALCOHOL = (ALCOHOL.x + ALCOHOL.y) / 2,
                VITB12 = (VITB12.x + VITB12.y) / 2,
                VITB6 = (VITB6.x + VITB6.y) / 2,
                BCAROTENE = (BCAROTENE.x + BCAROTENE.y) / 2,
                CAFFEINE = (CAFFEINE.x + CAFFEINE.y) / 2,
                CARB = (CARB.x + CARB.y) / 2,
                CHOLES = (CHOLES.x + CHOLES.y) / 2,
                KCAL = (KCAL.x + KCAL.y) / 2,
                TOTALFAT = (TOTALFAT.x + TOTALFAT.y) / 2,
                FIBER = (FIBER.x + FIBER.y) / 2,
                FOLICACID = (FOLICACID.x + FOLICACID.y) / 2,
                IRON = (IRON.x + IRON.y) / 2,
                MG = (MG.x + MG.y) / 2,
                MUFA = (MUFA.x + MUFA.y) / 2,
                NIACIN = (NIACIN.x + NIACIN.y) / 2,
                N3FAT = (N3FAT.x + N3FAT.y) / 2,
                N6FAT = (N6FAT.x + N6FAT.y) / 2,
                PROTEIN = (PROTEIN.x + PROTEIN.y) / 2,
                PUFA = (PUFA.x + PUFA.y) / 2,
                RIBOFLAVIN = (RIBOFLAVIN.x + RIBOFLAVIN.y) / 2,
                SATFAT = (SATFAT.x + SATFAT.y) / 2,
                SE = (SE.x + SE.y) / 2,
                THIAMIN = (THIAMIN.x + THIAMIN.y) / 2,
                VITA = (VITA.x + VITA.y) / 2,
                VITC = (VITC.x + VITC.y) / 2,
                VITD = (VITD.x + VITD.y) / 2,
                VITE = (VITE.x + VITE.y) / 2,
                ZN = (ZN.x + ZN.y) / 2
            ) %>%
            dplyr::select(
                SEQN, DII_ALL, DII_NOETOH, ALCOHOL, VITB12, VITB6, BCAROTENE, CAFFEINE, CARB, CHOLES, KCAL, TOTALFAT, FIBER, FOLICACID,
                IRON, MG, MUFA, NIACIN, N3FAT, N6FAT, PROTEIN, PUFA, RIBOFLAVIN, SATFAT, SE, THIAMIN,
                VITA, VITC, VITD, VITE, ZN
            )
        # print a reminder that this function does not use all the original DII variables
        print("Reminder: This function does not use all the original DII variables. Eugenol, garlic, ginger, onion, trans fat, turmeric, Green/black tea, Flavan-3-ol, Flavones, Flavonols, Flavonones, Anthocyanidins, Isoflavones, Pepper, Thyme/oregano, Rosemary are not included because they are not available in NHANES.")
        return(COHORT12)
    }
}
