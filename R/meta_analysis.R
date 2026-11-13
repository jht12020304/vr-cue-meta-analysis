# VR drug-cue craving meta-analysis: three-level REML model, CR2 robust inference.
# Usage (from repo root): Rscript R/meta_analysis.R [data/analysis_input_55.csv] [results/]
# Consolidates rerun_template.R + export_template_precision.R (2026-10-24); same models, same numbers.
suppressMessages({ library(metafor); library(clubSandwich) })

args    <- commandArgs(trailingOnly = TRUE)
infile  <- if (length(args) >= 1) args[1] else "data/analysis_input_55.csv"
outdir  <- if (length(args) >= 2) args[2] else "results"
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

d <- read.csv(infile, check.names = FALSE, fileEncoding = "UTF-8")
need <- c("cohort", "g_aligned", "vi", "design", "substance_ms")
miss <- setdiff(need, names(d)); if (length(miss)) stop("Missing columns: ", paste(miss, collapse = ", "))
d$yi <- d$g_aligned
d$es <- seq_len(nrow(d))
stopifnot(nrow(d) == 55, length(unique(d$cohort)) == 30)

# Risk of bias: consensus rating (偏誤評估表_共識_20261023.xlsx)
serious <- c("Acker 2013", "Benvegnu 2025", "Benvegnù 2025", "Choi 2011", "Ghiță 2025", "Ghita 2025",
             "Murray 2026", "Quoilin 2021 (AUD)", "Quoilin 2021 (heavy drinkers)", "Ryan 2010", "Thompson-Lake 2015")
low     <- c("Eidenmueller 2025", "Modak 2025")
d$rob <- ifelse(d$cohort %in% serious, "Serious", ifelse(d$cohort %in% low, "Low", "Moderate"))
stopifnot(length(unique(d$cohort[d$rob == "Serious"])) == 9)
# Choi 2011 substance correction (review comment C90)
d$substance <- ifelse(d$cohort == "Choi 2011", "Nicotine", d$substance_ms)

RHO <- 0.6  # assumed within-cohort sampling correlation
fit <- function(x, mods = ~1, label) {
  V  <- vcalc(vi, cluster = cohort, obs = es, rho = RHO, data = x)
  m  <- rma.mv(yi, V, mods = mods, random = ~ 1 | cohort/es, data = x, method = "REML", sparse = TRUE)
  ct <- coef_test(m, vcov = "CR2"); ci <- conf_int(m, vcov = "CR2")
  pr <- if (identical(mods, ~1)) predict(m) else NULL  # model-based PI, not CR2-calibrated
  data.frame(analysis = label, term = rownames(ct), k = length(unique(x$cohort)), m = nrow(x),
             est = ct$beta, ci_lb = ci$CI_L, ci_ub = ci$CI_U, df = ct$df_Satt, p = ct$p_Satt,
             pi_lb = if (is.null(pr)) NA else pr$pi.lb, pi_ub = if (is.null(pr)) NA else pr$pi.ub,
             tau = sqrt(m$sigma2[1]), omega = sqrt(m$sigma2[2]))
}

res <- rbind(
  fit(d,                                label = "baseline"),
  fit(subset(d, rob != "Serious"),      label = "exclude_serious"),
  fit(d, ~ I(rob == "Serious"),         label = "serious_vs_other"),
  fit(d, ~ relevel(factor(rob), "Moderate"), label = "rob_3level_reference_only"),  # Low has 2 cohorts
  fit(subset(d, substance == "Nicotine"), label = "nicotine"),
  fit(subset(d, substance == "Alcohol"),  label = "alcohol")
)
write.csv(res, file.path(outdir, "results.csv"), row.names = FALSE, fileEncoding = "UTF-8")
writeLines(capture.output(sessionInfo()), file.path(outdir, "sessionInfo.txt"))
print(res[, c("analysis", "term", "k", "m", "est", "ci_lb", "ci_ub", "p")], digits = 3, row.names = FALSE)
