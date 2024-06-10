* Encoding: UTF-8.
* corrDatasetLong
* by Jamie DeCoster

* This macro takes a set of variables, calculates the correlations among them, and then 
* outputs a data set with one case per pair of variables containing the correlation between
* those variables. The data set can optionally exclude self correlations and duplicate
* correlations.

**** Usage: corrDatasetLong(varList, corrDataset, reduced)
**** "varList" is a list of strings indicating the variables that should be included in the 
* correlation analysis. If this argument is omitted or set to "ALL", the correlation analysis 
* will include all variables in the data set.
**** "corrDataset" is the name of the SPSS dataset that you want to contain the correlations.
* This dataset should not exist prior to running this macro.
**** "reduced" is a boolean variable indicating whether you want to remove self correlations 
*    and duplicate correlations. By default, reduced = False.

**** Example: corrDatasetLong(varList = ["ES", "CO", "IS"],
* corrDataset = "Correlations", 
* reduced = True)
**** This would calculate all of the correlations among ES, CO, and IS. 
**** The correlations would be saved into the SPSS dataset "Correlations". This data set would
* have one case for each combination of ES, CO, and IS.
**** The correlation matrix would be reduced so that it would exclude self-correlations and redundant 
* correlations. It would therefore include 3 correlations: ES with CO, ES with IS, and CO with IS. 

set printback = off.
BEGIN PROGRAM PYTHON3.
import spss

def corrDatasetLong(varList = "ALL", corrDataset = "Correlations", reduced = False):
    if (varList == "ALL"):
        # Obtain a list of all variables in the data set
        varList = []
        for varnum in range(spss.GetVariableCount()):
            varList.append(spss.GetVariableName(varnum))

    # Create data set with initial correlation matrix.
    submitstring = """dataset declare {0}.
    CORRELATIONS
    /VARIABLES=""".format(corrDataset)
    for var in varList:
        submitstring += "\n"+var
    submitstring += "/MATRIX=OUT ({0}).".format(corrDataset)
    spss.Submit(submitstring)
    
    # Remove info lines and Ns
    spss.Submit("""dataset activate {0}.
FILTER OFF.
USE ALL.
SELECT IF (ROWTYPE_="CORR").
EXECUTE.""".format(corrDataset))

    # Restructure file
    submitstring = """rename variables (VARNAME_ = Var1).
compute Var1Num = $casenum.
execute.
VARSTOCASES
  /MAKE Corr FROM """
    for var in varList:
        submitstring += "\n" + var
    submitstring += """/INDEX=Var2(Corr)
  /KEEP=Var1 Var1Num
  /NULL=DROP."""
    spss.Submit(submitstring)  
  
    # Stop if not reducing data set.
    if (reduced == False):
        spss.Submit("delete variables Var1Num.")

    # Continue if reducing dataset.
    else:
        # Creating variable number for variable 2.
        submitstring = """compute x381287 = $casenum.
execute.
RANK VARIABLES=x381287 (A) BY Var1Num
  /RANK
  /PRINT=NO
  /TIES=MEAN.
compute Var2Num = Rx381287.
execute.

delete variables x381287 Rx381287.
alter type Var1Num Var2Num (f8)."""
        spss.Submit(submitstring)    

        # Removing self correlations (Var1Num = Var2Num) 
        # and upper diagonal correlations (Var1Num > Var2Num)
        submitstring = """FILTER OFF.
USE ALL.
SELECT IF (Var1Num < Var2Num).
EXECUTE.
delete variables Var1Num Var2Num."""
        spss.Submit(submitstring)
end program python.    
set printback = on.

**********
* Version History
**********
* 2022-05-24 Created
