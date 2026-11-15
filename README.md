# NanoDrop volume planner

One HTML file, no installation, no internet needed.

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

## History

See the commit log: the first commit is the page as originally written, every
change after it is a separate commit with its reason.
