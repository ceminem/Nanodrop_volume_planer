# NanoDrop volume planner

One HTML file, no installation, no internet needed. Three tabs: **NanoDrop &
ibidi slides** (volumes for a fixed absolute amount), **96-well titration**
(dose series and pipetting mask) and **IC50** (dose–response fit of the plate
readout).

**On your PC:** get the folder (GitHub Desktop → *Clone repository*, or on
GitHub *Code → Download ZIP* and unzip), then double-click
**`Open NanoDrop planner.bat`** - or the `.html` file itself. It opens in your
browser. (Opening the file on github.com only shows its code.)
For a desktop icon: right-click the `.bat` → *Send to → Desktop*. Everything stays on your computer (the page
remembers your last data, settings, slides and saved masks in the browser).

## What it does

1. Paste a NanoDrop spectrum export (everything, header lines included).
2. For every sample it calculates the **mean absorbance over a wavelength
   range** and the **volume needed for a fixed absolute amount**:

   ```
   Volume (µL) = absolute amount (A·µL) ÷ mean A over the range (both ends included)
   ```

   The absolute amount depends on the **lipid** (panel *Absolute amount per
   lipid*; defaults DOPC 14, DOPC/DOTAP 12, vac lipid 12 A·µL). A sample gets the
   lipid whose keyword appears in its name - the **longest** match wins, so
   "DOPC/DOTAP 2" is DOPC/DOTAP, not DOPC - and can be changed per sample in the
   table's *Lipid* column. Which amount is used:
   **amount typed into a well  >  the sample's lipid  >  default amount.**

3. It lays the samples out on **ibidi µ-Slide 8 Well** slides, with well
   coordinates **A1–D2**: columns A–D left to right, rows 1 (top) and 2
   (bottom). A1 sits above A2, then B1 above B2, the same convention as the
   plate layouts in the cell-classification pipeline.

## Interactive parts

| where | what you can do |
|---|---|
| **Spectra** | drag the shaded range to move it, drag its edges to resize it, click elsewhere to set the single wavelength; point at a curve to see sample, wavelength and A |
| **Samples table** | drag a row onto a well; pointing at a row highlights its curve and wells |
| **Chips** ("Not on a slide yet") | click: next free well in the chosen fill order · drag: onto any well |
| **Wells** | drag a well by its coordinate onto another well to move it (a filled target swaps); × empties a well; Enter jumps to the next well |
| **Fill order** | *by column* A1, A2, B1, B2 … or *by row* A1, B1, C1, D1 … — used by "Fill slides", chips, Enter and the copied plan |
| **Lipids** | edit name, amount and keywords (comma-separated); *Add lipid*; × removes; the count shows how many samples each lipid got |
| **Masks** | save and reload slide layouts, also before measuring (names are matched case-insensitively) |

## Plan sheet: Copy plan and Print plan

Both produce the same sheet: a title (field *Title on print / copy*), the date,
the settings used (range, single wavelength, amount per lipid), and for every
ibidi slide

- a **plate map** of the 8 wells (A1–D2 as on the slide) showing, per well, the
  sample name, lipid and absolute amount, the **volume** (large; red with ⚠ if
  above the "Flag volumes above" limit), the **mean A** over the range and
  **A at the single wavelength**;
- a **table** in fill order: Well · Sample · Lipid · Amount · Mean A · A at the
  single wavelength · Volume, with the slide total.

**Copy plan** puts it on the clipboard formatted (paste into Word, OneNote or
Outlook and the plate map and tables keep their look; paste into Excel and the
table lands in cells) and as tab-separated text for plain editors.
**Print plan** (also Ctrl+P) prints only this sheet, not the page; one slide per
A4 page, "Save as PDF" in the print dialog gives a PDF for the lab notebook.
**Save as CSV** and **Print plan** appear when the file is opened locally.

## 96-well titration (tab 2)

Plan a dose series per sample on a 96-well plate and get the pipetting mask.

- **Layout:** doses go **down the rows** (lowest on top), replicates **across the
  columns**; each condition is a block of rows × columns, filled left to right,
  then the next block of rows. Presets:
  - **8 doses × 4 conditions**, triplicate: rows A–H; C1 = columns 1–3 … C4 = 10–12
  - **4 doses × 8 conditions**, triplicate: C1–C4 in rows A–D, C5–C8 in rows E–H

  Or set doses per condition (2–8) and replicates (1, 2, 3, 4, 6) freely;
  optionally the first dose is an untreated control (0).
- **Per condition:** short label, name, NanoDrop sample, dose range *from – to*.
  The doses in between are spaced logarithmically (same factor) or linearly;
  type your own list into *Doses* to override (`0, 0.1, 0.4, 1`).
- **Dose** is an absolute amount (A·µL; sample volume = dose ÷ mean A of the
  chosen sample, from the NanoDrop tab) or directly a sample volume (µL).
- **Outputs:** plate mask (each well: short label, dose, sample volume; darker =
  higher dose), and a pipetting table per condition: sample and medium per well
  (with a final volume set), a **mix for replicates + 1 wells**, the total sample
  needed (+10 %). Volumes below the smallest pipetting volume get a pre-dilution
  hint (e.g. "use 2.5 µL of a 1:10 dilution").
- **Copy mask / Print mask:** the mask (A4 landscape) with legend, then the
  pipetting table.

### Imported plate mask

Instead of designing blocks, choose **Import plate mask** and paste the layout
from Excel (or *Load file…* a CSV / TXT). The conditions and doses of every
well are then used for the volumes, the pipetting table and the IC50 fit.

- **One grid** (8 × 12): each well `condition dose`, e.g. `DOPC 0.5`,
  `DOPC/DOTAP 1:1 0.5` (the last number is the dose) or `DOPC | 0.5`.
- **Two grids**, one after the other: first the conditions, then the doses.
- **A list**, one well per line: `Well; Condition; Dose` (`A1; DOPC; 0,5`) -
  the format of *Download layout (CSV)*.
- Row letters and the 1–12 line may be included; decimal commas are fine;
  empty wells are unused.
- `ctrl` / `untreated` / `Kontrolle` / `0` = **untreated control** for every
  condition (dose 0, the 100 % for "% of untreated control");
  `DOPC ctrl` or `DOPC 0` = control only for DOPC.
- `blank` / `medium` / `Leerwert` = **background**: the mean of these wells is
  subtracted (unless a blank value is typed in on the IC50 tab).
- Wells with the same condition and dose are replicates wherever they are, and
  the number of replicates may differ between doses. The mix per dose is for
  its wells + 1.
- The NanoDrop sample of a condition is picked automatically when it has the
  same name; otherwise choose it in the conditions table.
- *Start from the block layout* turns the current blocks into a mask to edit;
  *Download layout (CSV)* saves either layout for the next plate.

**Long names:** every condition has a short label (C1, CTAP, …) that the mask,
the legend and the plots use; the full name is in the legend, tables and
tooltips, and plot titles wrap to two lines.

## IC50 (tab 3)

Paste the 8 × 12 readout block (from Excel or the plate reader; row letters,
the 1–12 line and decimal commas are fine). The wells are matched to the layout
and doses of the titration tab - blocks designed there or an **imported plate
mask** (*Import plate mask…*); set that up first, also for plates not planned
in the tool. Shared untreated-control wells are used as dose 0 for every
condition; blank wells are averaged and subtracted. *Load example* fills in a
mask (3 lipid coatings, 8 doses, shared control column, 4 blanks) and a
simulated MTT readout; *Restore my plate* brings your own plate back.

- **Fit:** 4-parameter log-logistic, the same model as `drc::LL.4` in R:
  `y = bottom + (top − bottom) / (1 + exp(slope · (ln dose − ln IC50)))`,
  least squares on **every replicate well**. IC50 = the dose halfway between
  fitted top and bottom; **95 % CI** by the delta method (as `drc::ED(…,
  interval = "delta")`). Checked against drc 4.0.3 on test data: IC50, slope,
  top, bottom and CI agree to < 0.1 %.
- **Options:** blank subtraction; response as measured or as **% of the
  untreated control** (needs dose 0); axis labels.
- **Outliers:** click a well in the readout to leave it out of the fit.
- **Warnings in the table:** IC50 outside the tested doses (extrapolated), no CI
  with only 4 points (4 doses × 1 replicate), wide CI, poor fit, rising curve.
  With 4 doses use replicates: the fit then has 12 points for 4 parameters.
- **Plots:** one per condition (points, curve, dashed IC50 line, IC50 and CI) or
  all conditions in one plot. **Copy results** (table for Excel/Word) and
  **Print report** (table + plots).

## R script (`R/`)

`R/MTT-pipline-script.R` is the same analysis in R (RStudio project
`R/MTT-assay.Rproj`): choose `layout <- "8x4"`, `"4x8"` or `"custom"`, name
the conditions, give the concentrations (one series for all, or one per
condition), paste the plate. It fits every replicate well with `drc` LL.4,
prints IC50 with 95 % CI and warnings, wraps long titles, draws up to 4 plots
per row and saves `IC50_summary.csv`, `IC50_plots.pdf`, `IC50_overlay.pdf`.

## History

See the commit log: the first commit is the page as originally written, every
change after it is a separate commit with its reason.
