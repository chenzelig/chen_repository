	
USE MPDExploration
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_Indicators_DataPreparation]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_Indicators_DataPreparation]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------

CREATE PROCEDURE USP_VM2F_BDU_Class_Indicators_DataPreparation  @ModelGroupID INT

AS 

BEGIN TRY 

	DECLARE @SQL VARCHAR(MAX)=NULL   
		   ,@ImportQuery VARCHAR(MAX)=NULL
		   ,@ParameterValue VARCHAR(MAX)=NULL

	SELECT 
		 Assembled_Unit_Seq_Key AS UnitID
		,Test_Name
		,Test_Name+'_'+place as testName1
		,Test_Result
		,Value
		,place
		,Result=CONVERT(FLOAT,CASE WHEN isnumeric(value)=1 THEN VALUE
								WHEN  value LIKE ''%:'' THEN NULL
								WHEN value LIKE ''%:%'' THEN substring(value,CHARINDEX('':'',value)+1,LEN(value)-CHARINDEX('':'',value))
								ELSE NULL END)
	INTO #temp
	FROM #RawData
	CROSS APPLY UDF_GetStringTableFromList_New(Test_Name,''|'',null)
	WHERE 1=1
	AND CASE WHEN Test_Name LIKE '%VMIN%' THEN Place IN (1,4,11) 
										  ELSE 1=1 END 
	ORDER BY Assembled_Unit_Seq_Key,TestName



END TRY
BEGIN CATCH  	
	PRINT ('Fail Point: '+ @FailPoint + ' - ' + ERROR_MESSAGE())
END CATCH 
GO
