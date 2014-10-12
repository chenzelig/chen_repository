
USE MPDExploration
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_VM2F_BDU_Class_GenerateXML]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_VM2F_BDU_Class_GenerateXML]

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------

CREATE PROCEDURE USP_VM2F_BDU_Class_GenerateXML
		 @Prefix VARCHAR(MAX)
		,@ProductIDs VARCHAR(MAX)
		,@Ratios VARCHAR(MAX)
		,@SelectedGroups VARCHAR(MAX)
		,@Description BIT=0
		,@IsDebugMode BIT=0

AS 

BEGIN TRY

IF @Description=1
BEGIN
	PRINT('
	Purpose:
	--------
	Create Vmin XML.
	
	Method:
	--------
	Calculate DFF:
		the SP calculates the "importance level" for each product and the final value
		for the DFF is determined according to the highest ranked product

		"importance level" is calculated based on the number of a apperance of a DFF
		in a group and unit. i.e. the number of times a DFF is influecing a formula calculation.
		the more a certain product''s DFF is influencial, the more likely it will determine
		the DFF XML final value.

	Create XML:

	Requirements:
	-------------
	@productIDs: a comma seperated string of the products'' IDs
	@Ratios: a comma seperated string of the size ratio between the projects. The sum should be 1.
	@SelectedGroups: the relevant groups from which to create the XML.
	')
	
	GOTO FINISH
END	

DECLARE @SQL VARCHAR(MAX)=NULL
	   ,@FailPoint VARCHAR(MAX)=NULL
	   ,@IsDebugModeString VARCHAR(MAX)=NULL
	   ,@DFF VARCHAR(MAX)=NULL
	   ,@DFFxml VARCHAR(MAX)=NULL
	   ,@ProductName VARCHAR(MAX)=NULL
	   ,@ProductID VARCHAR(MAX)=NULL
	   ,@BOMGROUP VARCHAR(MAX)=NULL
	   ,@XMLoutput VARCHAR(max)= NULL                                                        

-- variables which need to be updated in the future.
DECLARE @FileRevision VARCHAR(MAX)='BDU_Class_001'

IF @IsDebugMode=1
	SET @IsDebugModeString=''

PRINT ('----------------------------------- Create tables -----------------------------'+@IsDebugModeString)

SET @FailPoint='1'

IF OBJECT_ID('tempdb..#Config') IS NOT NULL 
	DROP TABLE #Config

IF OBJECT_ID('tempdb..#data') IS NOT NULL 
	DROP TABLE #data

IF OBJECT_ID('tempdb..#results') IS NOT NULL 
	DROP TABLE #results

IF OBJECT_ID('tempdb..#XML_Prep_1','U') IS NOT NULL 
	DROP TABLE #XML_Prep_1                                                     

IF OBJECT_ID('tempdb..#DFF_DefaultValues','U') IS NOT NULL 
	DROP TABLE #DFF_DefaultValues      

IF OBJECT_ID('tempdb..#XML_Prep_2','U') IS NOT NULL 
	DROP TABLE #XML_Prep_2

CREATE TABLE #Config(productID VARCHAR(MAX), ProductName VARCHAR(MAX), ratio VARCHAR(MAX),BOMGROUP VARCHAR(MAX))

CREATE TABLE #DFF_DefaultValues (ProductID INT,dff VARCHAR(MAX),avg_value FLOAT)

CREATE TABLE #data(ProductID VARCHAR(MAX), [DFF] VARCHAR(MAX), [UnitCount] INT, ResultsCount INT , 
				   DefaultValue FLOAT, Importance FLOAT, Ratio FLOAT, WeightedImportance FLOAT)

CREATE TABLE #results(ProductID INT, DFF VARCHAR(100), [DefaultValue] Float)

CREATE TABLE #XML_Prep_1 (ProductID INT, PredictionSchemaKey VARCHAR(MAX), Flow INT, Formula VARCHAR(MAX), FormulaVersion VARCHAR(MAX))         

CREATE TABLE #XML_Prep_2 (ProductID INT, PredictionSchemaKey VARCHAR(MAX), Flow INT, Formula VARCHAR(MAX), FormulaVersion VARCHAR(MAX),FirstInSchema BIT, LastInSchema BIT)

PRINT ('------------------------------- Populate #Config table -----------------------------------------'+@IsDebugModeString)

SET @FailPoint='2'

-- this table holds the products details

INSERT INTO #Config
SELECT Res1.value,Res3.productAbbreviation,res2.value,Res4.BOMGROUP
FROM
	(SELECT ROW_NUMBER() OVER(ORDER BY place) as [row],value
	FROM UDF_GetStringTableFromList_New(@productIDs,',',null)) Res1
	INNER JOIN
	(SELECT ROW_NUMBER() OVER(ORDER BY place) as [row],value
	FROM UDF_GetStringTableFromList_New(@ratios,',',null)) Res2
	ON Res1.[row]=Res2.[row]
	INNER JOIN 
	(SELECT DISTINCT productID, productAbbreviation
	 FROM VM2F_Class_Dim_Product) Res3
	ON Res1.Value=Res3.productID
	INNER JOIN 
	(SELECT DISTINCT ProductID,BOMGROUP
	FROM VM2F_BDU_Class_Flows) Res4
	ON Res1.Value=Res4.productID


IF @IsDebugMode=1
	SELECT * FROM #Config

PRINT ('----------------------------- populate #DFF_DefaultValues table -------------------------------'+@IsDebugModeString)

SET @FailPoint='3'

-- this table holds the DFF average value for each DFF and product.

IF CURSOR_STATUS('global','I')>=-1
	BEGIN
		   close MyCursor
		   DEALLOCATE myCursor
	END

DECLARE I CURSOR FOR 
SELECT productname
from #Config

OPEN I

FETCH NEXT FROM I INTO @productname

WHILE @@FETCH_STATUS = 0
BEGIN
	
		SET @DFF=NULL

		SELECT @DFF=ISNULL(@DFF+',','')+'['+ CONVERT(VARCHAR(MAX),name)+']'
		FROM sys.columns
		WHERE 1=1
		AND object_id=(SELECT object_id from sys.tables where name=@Prefix+'_'+@productname+'_FLat_Table')
		AND name NOT LIKE 'productID'
		AND name not LIKE 'unitID'
		and name NOT LIKE 'max_%'
		and name not LIKE 'isTrainmax%'

		PRINT 'DFF LIST:'+CHAR(13)+@DFF+CHAR(13)+@IsDebugModeString
		
		SET @SQL='
		INSERT INTO #DFF_DefaultValues
		SELECT ProductID,dff,avg_value=AVG(value)
		FROM(
			SELECT ProductID,dff,value
			FROM '+@Prefix+'_'+@productname+'_FLat_Table
			unpivot
			(value
			FOR DFF IN ('+@DFF+') 
			) as unpvt
		) Res1
		GROUP BY Res1.ProductID,Res1.dff'

		PRINT @SQL+@IsDebugModeString
		EXEC(@SQL)

		FETCH NEXT FROM I INTO @productname
END

CLOSE I
DEALLOCATE I


IF @IsDebugMode=1
	SELECT * FROM #DFF_DefaultValues

PRINT ('----------------------------- populate #Data table -------------------------------'+@IsDebugModeString)

SET @FailPoint='4'

--  This table hols the DFF aggregated data for each product

SET @SQL=NULL
SELECT @SQL=ISNULL(@SQL,'')+'
INSERT INTO #data
SELECT   [ProductID]
		,[DFF]=testName
		,[UnitCount]=MAX([UnitCount]) 
		,[ResultsCount]=SUM(CNT) 
		,[DefaultValue]=MAX(avg_value) --Aggregation doesn''t influce the field
		,[Importance]=1.0*SUM(CNT)/MAX([UnitCount]) 
		,[Ratio]='+Ratio+'
		,[WeightedImportance]='+Ratio+'*(1.0*SUM(CNT)/MAX([UnitCount]))
FROM(
	SELECT  [ProductID]='''+ProductID+''',TD.testName,CT.GroupID, CT.Equation,CTS.CNT,DF.avg_value
	FROM '+@Prefix+'_'+ProductName+'_ClassTestsSummary CTS  
	INNER JOIN (SELECT Max(groupid) as groupID, Max(Equation) as Equation
				FROM '+@Prefix+'_'+ProductName+'_ClassTests
				group by GroupID) CT
	ON CTS.GroupID=CT.GroupID
	AND CTS.GroupID IN('+@SelectedGroups+')
	INNER JOIN '+@Prefix+'_'+ProductName+'_DFF_TestData TD
	ON   (CT.Equation like ''%*''+TD.testName+''+%'') OR (CT.Equation like ''%*''+TD.testName)
	AND TD.testName LIKE ''DFF%''
	INNER JOIN #DFF_DefaultValues DF
	ON DF.productid='+ProductID+'
	AND DF.DFF=TD.testName	
	--ORDER BY CTS.GroupID
) Res1
CROSS JOIN ( SELECT count(DISTINCT UnitID) as [UnitCount] FROM '+@Prefix+'_'+productName+'_targetData) Res2
GROUP BY ProductID,testName'+CHAR(13)
FROM #Config

PRINT(@SQL+@IsDebugModeString)
EXEC(@SQL)

IF @IsDebugMode=1
	SELECT * FROM #data

PRINT ('----------------------------- populate #Results table -------------------------------'+@IsDebugModeString)

SET @FailPoint='5'

-- This table holds the final select value for each DFF according to the max_weightedImportance

INSERT INTO #results
SELECT Res1.ProductID, REPLACE([DFF],'DFF_SORT_','') AS DFF, [Res1].[DefaultValue]
FROM 
	(SELECT *, [Max_WeightedImportance]=MAX(WeightedImportance) over (PARTITION by DFF)
	 FROM #data
) Res1
WHERE [Max_WeightedImportance]=WeightedImportance
 ORDER BY DFF 

SELECT @DFFxml=ISNULL(@DFFxml+',','')+DFF+'='+CONVERT(VARCHAR(MAX),[DefaultValue])
FROM #results

PRINT 'DFF FOR XML:'+CHAR(13)+@DFFxml+CHAR(13)+@IsDebugModeString

IF @IsDebugMode=1
BEGIN
	SELECT * FROM #Results
END

PRINT ('----------------------------- populate #XML_Prep_1 -------------------------------'+@IsDebugModeString)

SET @FailPoint='6'

SELECT @SQL=ISNULL(@SQL,'')+CHAR(13)+
'INSERT INTO #XML_Prep_1                                                      
SELECT DISTINCT                                                           
            '+ProductID+' as ProductID,
            CT.Domain+CT.Corner PredictionSchemaKey,                                       
            F.Flow,                                     
            REPLACE(MR.Equation,''DFF_SORT_'','''') +''-''+ CAST(MR.Shift as VARCHAR(10)) Formula,                                      
            P.ProductName+''_''+CT.Domain+''_''+CT.Corner+''_''+CT.Flow+''_''+''001'' FormulaVersion --????????????                                    
FROM [dbo].['+@prefix+'_'+ProductName+'_ModelingResults] MR                                               
JOIN [dbo].['+@prefix+'_'+ProductName+'_ClassTests] CT                                                         
            ON CT.GroupID=MR.groupID                                       
JOIN dbo.VM2F_HSW_Class_Dim_Product P                                                     
            ON P.ProductID=CT.ProductID                                      
JOIN ['+@prefix+'_Flows] F                                                            
            ON F.ProductID=CT.ProductID                                      
            AND F.Bin=CT.Flow                                           
            AND F.BOMGROUP in (                                     
                        SELECT MAX(BOMGROUP)                                
                        FROM ['+@prefix+'_Flows]                                    
                        WHERE ProductID='+productID+'                      
            )                                               
WHERE 1=1                                                       
AND MR.GroupID in ('+@SelectedGroups+') '
FROM #config

PRINT(@SQL+@IsDebugModeString)
EXEC(@SQL)

IF @IsDebugMode=1
	SELECT * FROM #XML_Prep_1

PRINT ('----------------------------- populate #XML_Prep_2 -------------------------------'+@IsDebugModeString)

SET @FailPoint='7'

INSERT INTO #XML_Prep_2                                                      
SELECT DISTINCT                                                           
                        A.*,                              
                        CASE WHEN B.PredictionSchemaKey IS NULL THEN 1 ELSE 0 END FirstInSchema,                         
                        CASE WHEN C.PredictionSchemaKey IS NULL THEN 1 ELSE 0 END LastInSchema     
FROM #XML_Prep_1 A                                                 
Left JOIN #XML_Prep_1 B                                                         
			ON A.ProductID=B.ProductID
			AND A.PredictionSchemaKey=B.PredictionSchemaKey 			                                       
            AND A.Flow>B.Flow                                          
Left JOIN #XML_Prep_1 C                                                         
            ON  A.ProductID=C.ProductID
			AND A.PredictionSchemaKey=C.PredictionSchemaKey                                        
            AND A.Flow<C.Flow    
Left JOIN #XML_Prep_1 D
			 ON A.ProductID=D.ProductID
			 AND A.PredictionSchemaKey>D.PredictionSchemaKey                                        
             AND A.Flow>D.Flow          	                                      
ORDER BY A.ProductID, A.PredictionSchemaKey, A.Flow 

IF @IsDebugMode=1
	SELECT * FROM #XML_Prep_2
	   
PRINT ('----------------------------- Print XMLoutput -------------------------------'+@IsDebugModeString)

SET @FailPoint='8'

PRINT CHAR(13)+'XML output:'+CHAR(13)+'-------------'+CHAR(13)+CHAR(13)

PRINT 
'<?xml version="1.0" encoding="UTF-8"?>'+CHAR(13)+
'<Setup>'+CHAR(13)
+CHAR(9)+'<FileRevision>'+@FileRevision+'</FileRevision>'+CHAR(13)
+CHAR(9)+'<AllDefaultValues>'+@DFFxml+'</AllDefaultValues>'+CHAR(13)
+CHAR(9)+'<BOMGroupTable>'
--------

IF CURSOR_STATUS('global','I')>=-1
	BEGIN
		   close MyCursor
		   DEALLOCATE myCursor
	END

DECLARE I CURSOR FOR 
SELECT BOMGROUP,productID
from #Config

OPEN I

FETCH NEXT FROM I INTO @BOMGROUP,@ProductID

WHILE @@FETCH_STATUS = 0
BEGIN
		PRINT CHAR(9)+CHAR(9)+'<BOMGROUP>'+CHAR(13)+
		CHAR(9)+CHAR(9)+CHAR(9)+'<Name>'+@BOMGROUP+'</Name>'

		SET @XMLoutput=NULL
  		SELECT @XMLoutput= ISNULL(@XMLoutput,'')+                                                           
		CASE WHEN A.FirstInSchema=1 THEN                                                    +
			CHAR(13)+CHAR(9)+CHAR(9)+CHAR(9)+'<PredictionSchema>'+CHAR(13)+                                   
			CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+'<Key>'+PredictionSchemaKey+'</Key>'+CHAR(13)+       
			CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+'<VminPredictionTestPoints>'+CHAR(13)             
		ELSE '' END +                                        
			CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+'<VminPredictionTestPoint>'+CHAR(13)+            
			CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+'<Flow>'+convert(varchar(max),flow)+'</Flow>'+CHAR(13)+
			CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+'<Formula>'+formula+'</Formula>'+CHAR(13)+
			CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+'<FormulaVersion>'+FormulaVersion+'</FormulaVersion>'+CHAR(13)+
			CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+'</VminPredictionTestPoint>'+CHAR(13)+
		CASE WHEN A.LastInSchema=1 THEN                                                  
			CHAR(9)+CHAR(9)+CHAR(9)+CHAR(9)+'</VminPredictionTestPoints>'+CHAR(13)+                      
			CHAR(9)+CHAR(9)+CHAR(9)+'</PredictionSchema>'+CHAR(13)                                  
		ELSE '' END                                           
		FROM #XML_Prep_2 A
		WHERE A.ProductID=@ProductID                                                  

		--SELECT @XMLoutput= ISNULL(@XMLoutput,'')+CHAR(9)+CHAR(9)+'</BOMGROUP>'                                                          
		PRINT @XMLoutput		
		PRINT CHAR(9)+CHAR(9)+'</BOMGROUP>' 

		FETCH NEXT FROM I INTO @BOMGROUP,@ProductID
END

CLOSE I
DEALLOCATE I

---------
PRINT
CHAR(9)+'</BOMGroupTable>'+CHAR(13)
+'</Setup>'
                                                   
FINISH:

END TRY
BEGIN CATCH  	
	PRINT ('Fail Point: '+ @FailPoint + ' - ' + ERROR_MESSAGE())
END CATCH 
GO
