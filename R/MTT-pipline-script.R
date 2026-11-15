# ============================================================
# 96-Well Plate IC50 Analysis  (any number of conditions)
# ============================================================
# Every condition is a BLOCK of wells:
#   - rows    = the concentrations (lowest on top), one per row
#   - columns = the replicates
#
# Two ready-made layouts (choose in STEP 3):
#
#   "8x4"  8 concentrations x 4 conditions, triplicate
#          rows A-H = concentrations
#          C1 = columns 1-3, C2 = 4-6, C3 = 7-9, C4 = 10-12
#
#   "4x8"  4 concentrations x 8 conditions, triplicate
#          rows A-D: C1 = columns 1-3, C2 = 4-6, C3 = 7-9, C4 = 10-12
#          rows E-H: C5 = columns 1-3, C6 = 4-6, C7 = 7-9, C8 = 10-12
#
# Or define every condition yourself (any rows / columns / doses).
# The same layout is used by the NanoDrop planner's "96-well titration"
# and "IC50" tabs, and the fit is the same (drc LL.4), so both give the
# same IC50.
#
# Everything you might want to change is marked with  <<== ADJUST HERE
# ============================================================


# ---- 1. INSTALL / LOAD PACKAGES ----
if (!require("drc", quietly = TRUE)) install.packages("drc")
library(drc)


# ---- 2. PASTE YOUR PLATE DATA HERE ----                              # <<== ADJUST HERE
# Select the 8 x 12 block of results in Excel (rows A-H, columns 1-12),
# copy it (Ctrl+C) and paste it between the quotes, replacing the line
# "put your data here". Row letters / a 1..12 header line may be included.
# Decimal commas ("0,85") are recognised automatically.

plate_data_raw <- "

put your data here

"


# ---- 3. CHOOSE THE LAYOUT AND NAME THE CONDITIONS ----               # <<== ADJUST HERE
layout <- "4x8"          # "8x4", "4x8" or "custom"

# Names: as long as you like - plot titles are wrapped to fit, and
# 'short' is what the summary plot legend and the plate overview show.
condition_names <- c(
  "Condition +CTAP",
  "Condition -CTAP",
  "Condition 3",
  "Condition 4",
  "Condition 5",
  "Condition 6",
  "Condition 7",
  "Condition 8"
)
condition_short <- c("C1", "C2", "C3", "C4", "C5", "C6", "C7", "C8")


# ---- 4. CONCENTRATIONS ----                                          # <<== ADJUST HERE
# One value per row of a block, top to bottom (lowest first).
#  - "8x4": 8 values;  "4x8": 4 values
#  - if your conditions use DIFFERENT concentrations, give one vector per
#    condition in 'concentrations_per_condition' (same order as the names);
#    otherwise leave it as NULL and every condition uses 'concentrations'.
concentrations <- c(1, 2.41, 5.81, 14)          # e.g. c(0, 0.1, 0.2, 0.4, 1, 2, 4, 10) for "8x4"

concentrations_per_condition <- NULL
# concentrations_per_condition <- list(
#   c(1, 2.41, 5.81, 14),        # C1
#   c(0.5, 1.2, 2.9, 7),         # C2
#   ...
# )


# ---- 3b. CUSTOM LAYOUT (only if layout <- "custom") ----             # <<== ADJUST HERE
# rows: plate rows as numbers (A = 1 ... H = 8), cols: plate columns.
custom_conditions <- list(
  list(rows = 1:8, cols = 1:3),
  list(rows = 1:8, cols = 4:6)
)


# ---- 5. TITLES, AXES, COLOURS ----                                   # <<== ADJUST HERE
x_axis_label <- "Concentration ug/uL"
y_axis_label <- "AU"
colors  <- c("blue", "red", "darkgreen", "purple", "darkorange", "darkcyan", "grey35", "sienna")
symbols <- c(16, 17, 15, 18, 16, 17, 15, 18)
title_width <- 32        # characters per title line before wrapping (smaller = narrower panels)


# ---- 6. HOW DO YOU WANT TO SEE THE PLOTS? ----                       # <<== ADJUST HERE
# "individual" -> one window per condition
# "combined"   -> all conditions in one figure (up to 4 per row)
# "overlay"    -> all curves in one plot, plus the combined figure
plot_mode <- "combined"

# Save results in the working directory (IC50_summary.csv, IC50_plots.pdf, IC50_overlay.pdf)?
save_outputs <- TRUE


# ============================================================
# Nothing below needs changing
# ============================================================

# ---- read the plate (8 x 12, tolerant of labels and decimal commas) ----
read_plate <- function(txt) {
  M <- matrix(NA_real_, 8, 12, dimnames = list(LETTERS[1:8], 1:12)); r <- 0
  for (line in strsplit(txt, "\r?\n")[[1]]) {
    if (r >= 8 || !nzchar(trimws(line))) next
    tok <- if (grepl("\t", line)) strsplit(line, "\t")[[1]] else
           if (grepl(";", line))  strsplit(line, ";")[[1]]  else strsplit(trimws(line), "\\s+")[[1]]
    tok <- trimws(tok)
    if (length(tok) && grepl("^[A-Ha-h]$", tok[1])) tok <- tok[-1] else
    if (length(tok) > 12 && tok[1] == "") tok <- tok[-1]
    filled <- tok[tok != ""]
    if (length(filled) >= 2 && all(filled == as.character(seq_along(filled)))) next   # 1..12 header
    v <- suppressWarnings(as.numeric(sub(",", ".", tok, fixed = TRUE)))
    if (!any(is.finite(v))) next
    r <- r + 1; n <- min(12, length(v)); M[r, seq_len(n)] <- v[seq_len(n)]
  }
  if (r == 0) stop("No numbers found in plate_data_raw - paste your plate data in STEP 2.")
  M
}
plate <- read_plate(plate_data_raw)
cat("Parsed plate data:\n"); print(plate)

# ---- build the condition blocks ----
blocks <- switch(layout,
  "8x4"   = lapply(0:3, function(k) list(rows = 1:8, cols = 3 * k + 1:3)),
  "4x8"   = lapply(0:7, function(k) list(rows = if (k < 4) 1:4 else 5:8, cols = 3 * (k %% 4) + 1:3)),
  "custom"= custom_conditions,
  stop('layout must be "8x4", "4x8" or "custom"'))

conditions <- lapply(seq_along(blocks), function(k) {
  b <- blocks[[k]]
  conc <- if (!is.null(concentrations_per_condition)) concentrations_per_condition[[k]] else concentrations
  if (length(conc) != length(b$rows))
    stop(sprintf("Condition %d has %d rows but %d concentrations - make them match (STEP 4).", k, length(b$rows), length(conc)))
  list(name  = if (k <= length(condition_names)) condition_names[k] else paste("Condition", k),
       short = if (k <= length(condition_short)) condition_short[k] else paste0("C", k),
       rows = b$rows, cols = b$cols, conc = conc,
       color = colors[(k - 1) %% length(colors) + 1], pch = symbols[(k - 1) %% length(symbols) + 1])
})

# skip conditions without data (e.g. only half the plate filled)
conditions <- Filter(function(cd) {
  ok <- any(is.finite(plate[cd$rows, cd$cols]))
  if (!ok) cat(sprintf("Note: skipping '%s' - no values in its wells.\n", cd$name))
  ok
}, conditions)
if (!length(conditions)) stop("None of the conditions has values in the pasted data.")

wrap_title <- function(s, width = title_width, max_lines = 2) {
  lines <- strwrap(s, width = width)
  if (length(lines) > max_lines) { lines <- lines[1:max_lines]; lines[max_lines] <- paste0(substr(lines[max_lines], 1, width - 3), "...") }
  paste(lines, collapse = "\n")
}


# ==============================================================
# FIT EACH CONDITION - on every replicate well (not the row means),
# 4-parameter log-logistic LL.4, IC50 with 95 % CI (delta method)
# ==============================================================
fit_condition <- function(cd) {
  d <- data.frame(Concentration = rep(cd$conc, times = length(cd$cols)),
                  Response      = as.numeric(plate[cd$rows, cd$cols]),
                  Well          = paste0(rep(LETTERS[cd$rows], times = length(cd$cols)), rep(cd$cols, each = length(cd$rows))))
  d <- d[is.finite(d$Response), ]
  cat("\n===== ", cd$short, " - ", cd$name, " =====\n", sep = "")
  print(aggregate(Response ~ Concentration, d, function(v) round(c(mean = mean(v), sd = sd(v), n = length(v)), 4)))

  fit <- tryCatch(drm(Response ~ Concentration, data = d, fct = LL.4(names = c("Slope", "Lower", "Upper", "IC50"))),
                  error = function(e) NULL)
  if (is.null(fit)) { cat("Fit failed.\n"); return(list(cd = cd, data = d, fit = NULL, IC50 = NA, lo = NA, hi = NA, note = "fit failed")) }
  print(summary(fit))
  IC50 <- coef(fit)[["IC50:(Intercept)"]]
  ci <- tryCatch(suppressMessages(ED(fit, 50, interval = "delta", display = FALSE))[1, c("Lower", "Upper")],
                 error = function(e) c(NA, NA))
  pos <- d$Concentration[d$Concentration > 0]
  note <- c()
  if (IC50 > max(pos)) note <- c(note, "above highest dose: extrapolated")
  if (IC50 < min(pos)) note <- c(note, "below lowest dose: extrapolated")
  if (nrow(d) <= 4)    note <- c(note, "no CI (4 points for 4 parameters)")
  cat(sprintf("\nIC50 %s: %.4g  (95%% CI %.4g - %.4g)%s\n", cd$short, IC50, ci[1], ci[2],
              if (length(note)) paste0("  NOTE: ", paste(note, collapse = "; ")) else ""))
  list(cd = cd, data = d, fit = fit, IC50 = IC50, lo = ci[1], hi = ci[2], note = paste(note, collapse = "; "))
}
fits <- lapply(conditions, fit_condition)


# ==============================================================
# PLOTTING  (long names are wrapped, titles shrink to fit)
# ==============================================================
plot_one <- function(f) {
  cd <- f$cd
  ttl <- wrap_title(paste0(cd$short, ": ", cd$name))
  nl  <- length(strsplit(ttl, "\n")[[1]])
  if (is.null(f$fit)) {
    plot(f$data$Concentration + 1e-9, f$data$Response, log = "x", col = cd$color, pch = cd$pch,
         xlab = x_axis_label, ylab = y_axis_label, main = "")
  } else {
    plot(f$fit, type = "all", col = cd$color, lwd = 2, pch = cd$pch,
         xlab = x_axis_label, ylab = y_axis_label, main = "")
    abline(v = f$IC50, col = cd$color, lty = 2)
    legend("topright", bty = "n", cex = 0.85,
           legend = c(sprintf("IC50 = %.3g", f$IC50), if (is.finite(f$lo)) sprintf("95%% CI %.3g - %.3g", f$lo, f$hi)))
  }
  title(main = ttl, cex.main = if (nl > 1) 0.85 else 1, line = if (nl > 1) 0.6 else 1.5)
}

draw_combined <- function() {
  n <- length(fits); n_col <- min(4, n); n_row <- ceiling(n / n_col)
  old <- par(mfrow = c(n_row, n_col), mar = c(4.2, 4.2, 3.4, 1), mgp = c(2.4, 0.8, 0))
  for (f in fits) plot_one(f)
  par(old)
}
draw_overlay <- function() {
  ok <- Filter(function(f) !is.null(f$fit), fits); if (!length(ok)) return(invisible())
  old <- par(mfrow = c(1, 1), mar = c(4.5, 4.5, 2, 1))
  for (i in seq_along(ok)) plot(ok[[i]]$fit, type = "all", col = ok[[i]]$cd$color, pch = ok[[i]]$cd$pch, lwd = 2,
                                add = i > 1, xlab = x_axis_label, ylab = y_axis_label)
  # decreasing curves leave the lower left empty
  legend("bottomleft", bty = "n", cex = 0.8,
         legend = sapply(ok, function(f) sprintf("%s  IC50 %.3g", f$cd$short, f$IC50)),
         col = sapply(ok, function(f) f$cd$color), pch = sapply(ok, function(f) f$cd$pch), lwd = 2)
  par(old)
}

if (plot_mode == "individual") {
  for (f in fits) { dev.new(); plot_one(f) }
} else if (plot_mode == "combined") {
  draw_combined()
} else if (plot_mode == "overlay") {
  draw_combined(); dev.new(); draw_overlay()
} else stop('plot_mode must be "individual", "combined" or "overlay"')


# ==============================================================
# SUMMARY TABLE
# ==============================================================
summary_table <- data.frame(
  Short     = sapply(fits, function(f) f$cd$short),
  Condition = sapply(fits, function(f) f$cd$name),
  IC50      = signif(sapply(fits, function(f) f$IC50), 4),
  CI_low    = signif(sapply(fits, function(f) f$lo), 4),
  CI_high   = signif(sapply(fits, function(f) f$hi), 4),
  Note      = sapply(fits, function(f) f$note)
)
cat("\n===== Summary =====\n")
print(summary_table, row.names = FALSE, right = FALSE)

if (save_outputs) {
  write.csv(summary_table, "IC50_summary.csv", row.names = FALSE)
  n <- length(fits); n_col <- min(4, n); n_row <- ceiling(n / n_col)
  pdf("IC50_plots.pdf", width = 3.6 * n_col, height = 3.4 * n_row + 0.3)
  draw_combined()
  dev.off()
  pdf("IC50_overlay.pdf", width = 7, height = 5)
  draw_overlay()
  dev.off()
  cat("\nSaved IC50_summary.csv, IC50_plots.pdf and IC50_overlay.pdf in", getwd(), "\n")
}
