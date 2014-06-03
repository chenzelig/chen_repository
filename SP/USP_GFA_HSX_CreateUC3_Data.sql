USE [U2D]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GFA_HSX_CreateUC3_Data]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[USP_GFA_HSX_CreateUC3_Data]
GO

/*******************************************************           
* Procedure:		[USP_GFA_HSX_CreateUC3_Data]  
*                                                              
* Description:		Creating data for import for HSX Geo Analysis   
* 
* Tables Accessed:	dbo.GFA_HSX_UC3_Data
* ----------------------------------------------------------     
*                                                                    
* Modification Log:                                            
* Date			Modified By			Modification:                         
* ----			-----------			--------------------         
* 2014-5-04		Gil Ben Shalom			Creating the SP 
*******************************************************/ 
CREATE PROCEDURE [dbo].[USP_GFA_HSX_CreateUC3_Data]

AS

------------------------------------------------------------------------------------------------------
--------------------------------------DECLARE Variables-----------------------------------------------
------------------------------------------------------------------------------------------------------

DECLARE @dFromDate date,@dMinDate date

------------------------------------------------------------------------------------------------------
--------------------------------------Temp tables-----------------------------------------------
------------------------------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#Units_GeoPerDate') IS NOT NULL
	DROP TABLE #Units_GeoPerDate
CREATE TABLE #Units_GeoPerDate(
	LoadDate DATE,
	Product VARCHAR(10),
	DieStructure VARCHAR(15),
	X INT,
	Y INT,
	GeoType VARCHAR(10),
	GeoValue VARCHAR(15)
)

IF OBJECT_ID('tempdb..#ParametersPerDate') IS NOT NULL
	DROP TABLE #ParametersPerDate

CREATE TABLE #ParametersPerDate(
	LoadDate DATE,
	DieStructure VARCHAR(15),
	Geo VARCHAR(30),
	Product VARCHAR(10),
	AggregatedUnitCount int,
	DailyUnitCount int,
	Parameter VARCHAR(50)
)

-----------------------------------------------------------------------------------------------------
-------------this part is for taking olny data that as 7 days for average----------------------------
-----------------------------------------------------------------------------------------------------
Select @dMinDate= MIN(LoadDate)
					FROM (SELECT DISTINCT LoadDate=Convert(DATE, LOTS_End_Date_Time) from GFA_HSX_RawData(nolock)) A

SET @dFromDate = DATEADD (day ,6,@dMinDate)

TRUNCATE TABLE GFA_HSX_UC3_Data

-----------------------------------------------------------------------------------------------------
---------------------------------Populate temp tables------------------------------------------------
-----------------------------------------------------------------------------------------------------
INSERT INTO #Units_GeoPerDate
SELECT DISTINCT LoadDate,B.Product,B.DieStructure,B.X,B.Y,B.GeoType,B.GeoValue
FROM (select distinct LoadDate=Convert(DATE, LOTS_End_Date_Time) 
      from GFA_HSX_RawData(nolock)
	  where Convert(DATE, LOTS_End_Date_Time)>@dFromDate 
	  ) D
CROSS JOIN (select * from [GFA_Geo_Mapping_All](nolock) where Product='HSX') B

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----Finds the yield for each Date,Product,Die Structue,Geo Value - 7 days back
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT Into GFA_HSX_UC3_Data([Date],DieStructure,Geo,Product,AggregatedUnitCount,DailyUnitCount,Param_name,Value)
SELECT
	DG.LoadDate,
	CASE WHEN DG.DieStructure = 'C' THEN 'HCC - 18 Core' WHEN DG.DieStructure = 'M' THEN 'MCC - 12 Core' WHEN DG.DieStructure = 'R' THEN 'LCC - 8 Core' END as DieStructure,
	CASE WHEN DG.GeoType = 'Clock- All' or DG.GeoType = 'All Wafer' then DG.GeoType ELSE DG.GeoType+'- '+DG.GeoValue END as Geo,
	S.Product,
	Count(1) as AggregatedUnitCount,
	SUM(CASE WHEN convert(Date,S.LOTS_End_Date_Time)=DG.LoadDate THEN 1 ELSE 0 END) as DailyUnitCount,
	S.SourceDomain+'_Yield_%' as Parameter,
	CONVERT(float, AVG(CASE WHEN PO.GB_Flag = 'G' then 100.0 else 0 END)) As Value
FROM #Units_GeoPerDate DG
JOIN GFA_HSX_RawData(nolock) S on DG.X = S.Sort_X and
		DG.Y = S.Sort_Y and
		DG.Product = S.Product and
		DG.DieStructure = S.DieStructure AND
		convert(Date,S.LOTS_End_Date_Time) <= DG.LoadDate and
		convert(Date,S.LOTS_End_Date_Time) > DATEADD (day , -7 , DG.LoadDate)
JOIN GFA_ProductOperation_GoodBad(nolock) PO on S.Product = PO.Product and
		S.Operation = PO.Operation
		and S.Interface_Bin between PO.Min_Interface_Bin and PO.Max_Interface_Bin
GROUP by DG.GeoType, DG.GeoValue,DG.LoadDate,S.SourceDomain,S.Product,DG.DieStructure

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----Finds the yield for each Date,Product,Die Structue,Geo Value,Package - 7 days back
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT Into GFA_HSX_UC3_Data([Date],DieStructure,Geo,Product,AggregatedUnitCount,DailyUnitCount,Param_name,Value)
	SELECT
	DG.LoadDate,
	CASE WHEN DG.DieStructure = 'C' THEN 'HCC - 18 Core' WHEN DG.DieStructure = 'M' THEN 'MCC - 12 Core' WHEN DG.DieStructure = 'R' THEN 'LCC - 8 Core' END as DieStructure,
	CASE WHEN DG.GeoType = 'Clock- All' or DG.GeoType = 'All Wafer' then DG.GeoType ELSE DG.GeoType+'- '+DG.GeoValue END as Geo,
	S.Product,
	Count(1) as AggregatedUnitCount,
	SUM(CASE WHEN convert(Date,S.LOTS_End_Date_Time)=DG.LoadDate THEN 1 ELSE 0 END) as DailyUnitCount,
	S.SourceDomain+'_'+Package+'_Yield_%' as Parameter,
	CONVERT(float, AVG(CASE WHEN PO.GB_Flag = 'G' then 100.0 else 0 END)) As Value
FROM #Units_GeoPerDate DG
JOIN GFA_HSX_RawData(nolock) S on DG.X = S.Sort_X and
		DG.Y = S.Sort_Y and
		DG.Product = S.Product and
		DG.DieStructure = S.DieStructure AND
		convert(Date,S.LOTS_End_Date_Time) <= DG.LoadDate and
		convert(Date,S.LOTS_End_Date_Time) > DATEADD (day , -7 , DG.LoadDate)
JOIN GFA_ProductOperation_GoodBad(nolock) PO on S.Product = PO.Product and
		S.Operation = PO.Operation
		and S.Interface_Bin between PO.Min_Interface_Bin and PO.Max_Interface_Bin
Where S.SourceDomain = 'CLASS'
GROUP by DG.GeoType,DG.GeoValue,DG.LoadDate,S.SourceDomain,S.Product,DG.DieStructure,S.Package

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Finds the % of each Bin for each Date, Product, Die Structure, Operation, Package, Geo Value
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT Into GFA_HSX_UC3_Data([Date],DieStructure,Geo,Product,AggregatedUnitCount,DailyUnitCount,Param_name,Value)
SELECT LoadDate,DieStructure,Geo,Product,sum(IB_Count)over(partition by LoadDate,DieStructure,Geo,Product,Package) as AggregatedUnitCount,sum(IB_DailyCount)over(partition by LoadDate,DieStructure,Geo,Product,Package) DailyUnitCount,Parameter,Value=100.0*IB_Count/sum(IB_Count)over(partition by LoadDate,DieStructure,Geo,Product,Package)
FROM (SELECT
              DG.LoadDate,
              CASE WHEN DG.DieStructure = 'C' THEN 'HCC - 18 Core' WHEN DG.DieStructure = 'M' THEN 'MCC - 12 Core' WHEN DG.DieStructure = 'R' THEN 'LCC - 8 Core' END as DieStructure,
              CASE WHEN DG.GeoType = 'Clock- All' or DG.GeoType = 'All Wafer' then DG.GeoType ELSE DG.GeoType+'- '+DG.GeoValue END as Geo,
              S.Product,
			  Count(1) as AggregatedUnitCount,
			  SUM(CASE WHEN convert(Date,S.LOTS_End_Date_Time)=DG.LoadDate THEN 1 ELSE 0 END) as DailyUnitCount,
			  S.Package,
              S.SourceDomain+'_'+Package+'_IB'+convert(varchar (5),S.Interface_Bin)+'_%' as Parameter,
              IB_Count = Convert(float,Count(1)),
			  IB_DailyCount = SUM(CASE WHEN convert(Date,S.LOTS_End_Date_Time)=DG.LoadDate THEN 1 ELSE 0 END)                                                                                                                                           
       FROM #Units_GeoPerDate DG
        JOIN GFA_HSX_RawData(nolock) S on DG.X = S.Sort_X and
                    DG.Y = S.Sort_Y and
                    DG.Product = S.Product and
                    DG.DieStructure = S.DieStructure AND
                    convert(Date,S.LOTS_End_Date_Time) <= DG.LoadDate and
                    convert(Date,S.LOTS_End_Date_Time) > DATEADD (day , -7 , DG.LoadDate)
       Where S.SourceDomain = 'CLASS'
	   and S.Interface_Bin is not null
       GROUP by DG.GeoType,DG.GeoValue,DG.LoadDate,S.SourceDomain,S.Product,DG.DieStructure,S.Package,S.Interface_Bin
)A


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Finds the % of each Bin for each Date, Product, Die Structure, Operation, Geo Value
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT Into GFA_HSX_UC3_Data([Date],DieStructure,Geo,Product,AggregatedUnitCount,DailyUnitCount,Param_name,Value)
SELECT LoadDate,DieStructure,Geo,Product,sum(IB_Count)over(partition by LoadDate,DieStructure,Geo,Product,SourceDomain) as AggregatedUnitCount,sum(IB_DailyCount)over(partition by LoadDate,DieStructure,Geo,Product,SourceDomain) DailyUnitCount,Parameter,Value=100.0*IB_Count/sum(IB_Count)over(partition by LoadDate,DieStructure,Geo,Product,SourceDomain)
FROM (SELECT
              DG.LoadDate,
              CASE WHEN DG.DieStructure = 'C' THEN 'HCC - 18 Core' WHEN DG.DieStructure = 'M' THEN 'MCC - 12 Core' WHEN DG.DieStructure = 'R' THEN 'LCC - 8 Core' END as DieStructure,
              CASE WHEN DG.GeoType = 'Clock- All' or DG.GeoType = 'All Wafer' then DG.GeoType ELSE DG.GeoType+'- '+DG.GeoValue END as Geo,
              S.Product,
			  Count(1) as AggregatedUnitCount,
			  SUM(CASE WHEN convert(Date,S.LOTS_End_Date_Time)=DG.LoadDate THEN 1 ELSE 0 END) as DailyUnitCount,
			  S.SourceDomain,
		  	  S.SourceDomain+'_IB'+convert(varchar (5),S.Interface_Bin)+'_%' as Parameter,
              IB_Count = Convert(float,Count(1)),
			  IB_DailyCount = SUM(CASE WHEN convert(Date,S.LOTS_End_Date_Time)=DG.LoadDate THEN 1 ELSE 0 END)                                                                                                                                         
       FROM #Units_GeoPerDate DG
        JOIN GFA_HSX_RawData(nolock) S on DG.X = S.Sort_X and
                    DG.Y = S.Sort_Y and
                    DG.Product = S.Product and
                    DG.DieStructure = S.DieStructure AND
                    convert(Date,S.LOTS_End_Date_Time) <= DG.LoadDate and
                    convert(Date,S.LOTS_End_Date_Time) > DATEADD (day , -7 , DG.LoadDate)
	   WHERE S.Interface_Bin is not null
       GROUP by DG.GeoType,DG.GeoValue,DG.LoadDate,S.SourceDomain,S.Product,DG.DieStructure,S.Interface_Bin
)A


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- add missing data for zero's
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO #ParametersPerDate(LoadDate,DieStructure,Geo,Product,Parameter)
SELECT [Date],DieStructure,Geo,Product,Param_name
FROM
(select distinct [Date] from GFA_HSX_UC3_Data(nolock)) D
CROSS JOIN 
(	
	select distinct Product
				   ,DieStructure
				   ,Param_name
	from GFA_HSX_UC3_Data(nolock)
	where Param_name not like '%Yield%'
) P 
CROSS JOIN
(select distinct Geo from GFA_HSX_UC3_Data(nolock))G


DELETE P
FROM #ParametersPerDate P
LEFT JOIN (
	SELECT distinct [Date],
					DieStructure,
					Geo,
					Product,
					SUBSTRING(Param_name,PATINDEX('%[_]%',Param_name)+1,2) as Package,
					LEFT(Param_name,PATINDEX('%[_]%',Param_name)-1) as SourceDomain
	FROM GFA_HSX_UC3_Data(nolock)
	where Param_name not like '%Yield%'
	and PATINDEX('%[_]%',SUBSTRING(Param_name,PATINDEX('%[_]%',Param_name)+1,LEN(Param_name)-2-PATINDEX('%[_]%',Param_name)))>0
) D
ON P.LoadDate=D.[Date]
AND P.DieStructure=D.DieStructure
AND P.Geo=D.Geo
AND P.Product=D.Product
AND SUBSTRING(P.Parameter,PATINDEX('%[_]%',P.Parameter)+1,2)=D.Package
AND LEFT(P.Parameter,PATINDEX('%[_]%',P.Parameter)-1)=D.SourceDomain
WHERE PATINDEX('%[_]%',SUBSTRING(P.Parameter,PATINDEX('%[_]%',P.Parameter)+1,LEN(P.Parameter)-2-PATINDEX('%[_]%',P.Parameter)))>0
AND D.[Date] IS NULL

DELETE P
FROM #ParametersPerDate P
LEFT JOIN (
	SELECT distinct [Date],DieStructure,Geo,Product,LEFT(Param_name,PATINDEX('%[_]%',Param_name)-1) as SourceDomain
	FROM GFA_HSX_UC3_Data(nolock)
) D
ON P.LoadDate=D.[Date]
AND P.DieStructure=D.DieStructure
AND P.Geo=D.Geo
AND P.Product=D.Product
AND LEFT(P.Parameter,PATINDEX('%[_]%',P.Parameter)-1)=D.SourceDomain
WHERE D.[Date] IS NULL


UPDATE P
SET P.AggregatedUnitCount = D.AggregatedUnitCount,
P.DailyUnitCount = D.DailyUnitCount 
FROM #ParametersPerDate P join 
(SELECT DISTINCT Geo,[Date], Product, DieStructure, AggregatedUnitCount, DailyUnitCount,LEFT(Param_name,PATINDEX('%[_]%',Param_name)-1) as SourceDomain FROM GFA_HSX_UC3_Data) D
on P.Geo = D.Geo and P.LoadDate = D.[Date] and P.Product = D.Product and P.DieStructure = D.DieStructure AND LEFT(P.Parameter,PATINDEX('%[_]%',P.Parameter)-1)=D.SourceDomain

UPDATE P
SET P.AggregatedUnitCount = D.AggregatedUnitCount,
P.DailyUnitCount = D.DailyUnitCount 
FROM #ParametersPerDate P join 
(SELECT DISTINCT Geo,[Date], Product, DieStructure, AggregatedUnitCount, DailyUnitCount,SUBSTRING(Param_name,PATINDEX('%[_]%',Param_name)+1,2) as Package,
					LEFT(Param_name,PATINDEX('%[_]%',Param_name)-1) as SourceDomain FROM GFA_HSX_UC3_Data) D
on P.Geo = D.Geo and P.LoadDate = D.[Date] and P.Product = D.Product and P.DieStructure = D.DieStructure AND SUBSTRING(P.Parameter,PATINDEX('%[_]%',P.Parameter)+1,2)=D.Package
AND LEFT(P.Parameter,PATINDEX('%[_]%',P.Parameter)-1)=D.SourceDomain
WHERE PATINDEX('%[_]%',SUBSTRING(P.Parameter,PATINDEX('%[_]%',P.Parameter)+1,LEN(P.Parameter)-2-PATINDEX('%[_]%',P.Parameter)))>0



INSERT INTO GFA_HSX_UC3_Data([Date],DieStructure,Geo,Product,AggregatedUnitCount,DailyUnitCount,Param_name,Value)
SELECT P.LoadDate,P.DieStructure,P.Geo,P.Product,P.AggregatedUnitCount,P.DailyUnitCount,P.Parameter,Value=0
FROM #ParametersPerDate P
LEFT JOIN GFA_HSX_UC3_Data(nolock) D
ON P.LoadDate=D.[Date]
AND P.DieStructure=D.DieStructure
AND P.Geo=D.Geo
AND P.Product=D.Product
AND P.Parameter=D.Param_name
WHERE D.[Date] IS NULL

