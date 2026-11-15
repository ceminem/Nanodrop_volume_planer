# NanoDrop volume planner

One HTML file, no installation: **double-click `nanodrop-volume-planner.html`**
and it opens in your browser. Everything stays on your computer (the page
remembers your last data, settings, slides and saved masks in the browser).

## What it does

1. Paste a NanoDrop spectrum export (everything, header lines included).
2. For every sample it calculates the **mean absorbance over a wavelength
   range** and the **volume needed for a fixed absolute amount**:

   ```
   Volume (µL) = target amount (A·µL) ÷ mean A over the range (both ends included)
   ```

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
| **Masks** | save and reload slide layouts, also before measuring (names are matched case-insensitively) |

**Copy plan** gives one line per well (`A1  sample  amount  volume`), in fill
order. **Save as CSV** and **Print layout** appear when the file is opened
locally.

## History

See the commit log: the first commit is the page as originally written, every
change after it is a separate commit with its reason.
