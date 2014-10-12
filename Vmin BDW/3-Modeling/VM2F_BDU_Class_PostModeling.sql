
-- UPDATE equations NA values 
UPDATE VM2F_BDU_Class_UT_ModelingResults_653_693
SET Equation=REPLACE(Equation,'NA*','0*')
WHERE CHARINDEX('NA*',Equation)>0

-- update the classTest table with the Equation and Shift results from the modeling phase
update A
set A.Equation=B.Equation,
A.Shift=B.Shift
from VM2F_ClassTests A
inner join VM2F_BDU_Class_UT_ModelingResults B
on A.GroupID=B.GroupID
