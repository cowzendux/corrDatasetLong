# corrDatasetLong
This macro takes a set of variables, calculates the correlations among them, and then outputs a data set with one case per pair of variables containing the correlation between those variables.

## Usage:
**corrDatasetLong(varList = "ALL", corrDataset = "Correlations", reduced = False)**
* "varList" is a list of strings indicating the variables that should be included in the correlation analysis. If this argument is omitted or set to "ALL", the correlation analysis will include all variables in the data set.
* "corrDataset" is the name of the SPSS dataset that you want to contain the correlations. This dataset should not exist prior to running this macro.
* "reduced" is a boolean variable indicating whether you want to remove self correlations and duplicate correlations. By default, reduced = False.

## Example: 
**corrDatasetLong(varList = ["ES", "CO", "IS"], corrDataset = "Correlations", reduced = True)**
* This would calculate all of the correlations among ES, CO, and IS. 
* The correlations would be saved into the SPSS dataset "Correlations". This data set would have one case for each combination of ES, CO, and IS.
* The correlation matrix would be reduced so that it would exclude self-correlations and redundant correlations. It would therefore include 3 correlations: ES with CO, ES with IS, and CO with IS. 
