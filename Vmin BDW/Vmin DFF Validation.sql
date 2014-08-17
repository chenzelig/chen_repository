
-- identify the corresponding columns to the relevant DFF
SELECT * 
FROM [dbo].[VM2F_BDU_Class_UT_DFF_Filtered_TestData]
WHERE testName LIKE '%SICC3%'

-- select the data from the results_float table
SELECT 
col15
,col16
,col17
,col18
,col19
,col20
,col21
,col22
,col23
,col24
,col25
,col26
 FROM [dbo].[VM2F_BDU_Class_UT_DFF_Filtered_Results_Float] DFF
where DFF.Assembled_Unit_Seq_Key=4964679152
and partitionkey=0

-- compare the data to the following values from sort (Crystal ball)
--D4142383,676,0,21,
--0.050733|0.050733|-999|0.071778|0.071778|-999|0.069022|0.0084|0.037556|0.0085778|0.0054222|0.0784,Default

