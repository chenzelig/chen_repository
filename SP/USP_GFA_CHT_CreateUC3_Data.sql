USE U2D
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GFA_CHT_CreateUC3_Data]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_GFA_CHT_CreateUC3_Data]

GO

/*******************************************************           
* Procedure:		[USP_GFA_CHT_CreateUC3_Data]  
*                                                              
* Description:		Creating data for import for HSX Geo Analysis   
* 
* Tables Accessed:	dbo.GFA_CHT_UC3_Data
* ----------------------------------------------------------     
*                                                                    
* Modification Log:                                            
* Date			Modified By			Modification:                         
* ----			-----------			--------------------         
* 2014-5-04		Gil Ben Shalom			Creating the SP 
*******************************************************/ 

CREATE PROCEDURE [dbo].[USP_GFA_CHT_CreateUC3_Data]

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
	X INT,
	Y INT,
	GeoType VARCHAR(10),
	GeoValue VARCHAR(15)
)

IF OBJECT_ID('tempdb..#ParametersPerDate') IS NOT NULL
	DROP TABLE #ParametersPerDate

CREATE TABLE #ParametersPerDate(
	LoadDate DATE,
	Segment VARCHAR(15),
	Geo VARCHAR(30),
	Product VARCHAR(10),
	AggregatedUnitCount int,
	DailyUnitCount int,
	Parameter VARCHAR(50)
)

ALTER TABLE #ATM_GM_PreparedData ADD
[Date] date,
Segment varchar(15),
Geo varchar(30),
AggregatedUnitCount int,
DailyUnitCount int,
Param_name varchhar(50),
Value float

ALTER TABLE #ATM_GM_PreparedData
drop Dummy

-----------------------------------------------------------------------------------------------------
-------------this part is for taking olny data that as 7 days for average----------------------------
-----------------------------------------------------------------------------------------------------
Select @dMinDate= MIN(LoadDate)
					FROM (SELECT DISTINCT LoadDate=Convert(DATE, LOTS_End_Date_Time) from #ATM_GM_RawData(nolock)) A

SET @dFromDate = DATEADD (day ,6,@dMinDate)

-----------------------------------------------------------------------------------------------------
---------------------------------Populate temp tables------------------------------------------------
-----------------------------------------------------------------------------------------------------
INSERT INTO #Units_GeoPerDate
SELECT DISTINCT LoadDate,B.Product,B.X,B.Y,B.GeoType,B.GeoValue
FROM (select distinct LoadDate=Convert(DATE, LOTS_End_Date_Time) 
      from #ATM_GM_RawData(nolock)
	  where Convert(DATE, LOTS_End_Date_Time)>@dFromDate 
	  ) D
CROSS JOIN (select Product,X,Y,GeoType,GeoValue from [GFA_Geo_Mapping_All] where Product='CHT') B

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----Finds the yield for each Date,Product,Geo Value - 7 days back
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT Into #ATM_GM_PreparedData([Date],Segment,Geo,Product,AggregatedUnitCount,DailyUnitCount,Param_name,Value)
	SELECT
		DG.LoadDate,
		SourceDomain+IsNull('-'+S.Segment,'') as Operation,
		CASE WHEN DG.GeoType = 'Clock- All' or DG.GeoType = 'All Wafer' then DG.GeoType ELSE DG.GeoType+'- '+DG.GeoValue END as Geo,
		S.Product,
		Count(1) as AggregatedUnitCount,
		SUM(CASE WHEN convert(Date,S.LOTS_End_Date_Time)=DG.LoadDate THEN 1 ELSE 0 END) as DailyUnitCount,
		'Yield_%' as Param_name,
		CONVERT(float, AVG(CASE WHEN PO.GB_Flag = 'G' then 100.0 else 0 END)) As Value
	FROM #Units_GeoPerDate DG
	JOIN #ATM_GM_RawData(nolock) S on DG.X = S.Sort_X and
			DG.Y = S.Sort_Y and
			LEFT(DG.Product,2) = LEFT(S.Product,2) and							
			convert(Date,S.LOTS_End_Date_Time) <= DG.LoadDate and
			convert(Date,S.LOTS_End_Date_Time) > DATEADD (day , -7 , DG.LoadDate)
	JOIN GFA_ProductOperation_GoodBad(nolock) PO on LEFT(S.Product,2) = LEFT(PO.Product,2) and
			S.Operation = PO.Operation
			and S.Interface_Bin between PO.Min_Interface_Bin and PO.Max_Interface_Bin
	GROUP by DG.GeoType, DG.GeoValue,DG.LoadDate,IsNull('-'+S.Segment,''),S.SourceDomain,S.Product

				
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- Finds the % of each Bin for each Date, Product, Die Structure, Operation, Geo Value
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------


INSERT Into #ATM_GM_PreparedData([Date],Segment,Geo,Product,AggregatedUnitCount,DailyUnitCount,Param_name,Value)
	SELECT LoadDate,Operation,Geo,Product,sum(IB_Count)over(partition by LoadDate,Geo,Operation) as AggregatedUnitCount,sum(IB_DailyCount)over(partition by LoadDate,Geo,Operation) DailyUnitCount,Parameter,Value=100.0*IB_Count/sum(IB_Count)over(partition by LoadDate,Geo,Operation)
	FROM (SELECT
				  DG.LoadDate,
				  SourceDomain+IsNull('-'+S.Segment,'') as Operation,
				  CASE WHEN DG.GeoType = 'Clock- All' or DG.GeoType = 'All Wafer' then DG.GeoType ELSE DG.GeoType+'- '+DG.GeoValue END as Geo,
				  S.Product,
				  Count(1) as AggregatedUnitCount,
				  SUM(CASE WHEN convert(Date,S.LOTS_End_Date_Time)=DG.LoadDate THEN 1 ELSE 0 END) as DailyUnitCount,
				  S.SourceDomain,
		  		  'IB_'+convert(varchar (5),S.Interface_Bin)+'_%' as Parameter,
				  IB_Count = Convert(float,Count(1)),
				  IB_DailyCount = SUM(CASE WHEN convert(Date,S.LOTS_End_Date_Time)=DG.LoadDate THEN 1 ELSE 0 END)                                                                                                                          
		   FROM #Units_GeoPerDate DG
			JOIN #ATM_GM_RawData(nolock) S on DG.X = S.Sort_X and
						DG.Y = S.Sort_Y and
						LEFT(DG.Product,2) = LEFT(S.Product,2) and
						convert(Date,S.LOTS_End_Date_Time) <= DG.LoadDate and
						convert(Date,S.LOTS_End_Date_Time) > DATEADD (day , -7 , DG.LoadDate)
		   GROUP by DG.GeoType,DG.GeoValue,DG.LoadDate,IsNull('-'+S.Segment,''),S.SourceDomain,S.Product,S.Interface_Bin
		   )A

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- add missing data for zero's
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO  #ParametersPerDate(LoadDate,Segment,Geo,Product,Parameter)
SELECT [Date],Segment,Geo,Product,Param_name
FROM
(select distinct [Date] from GFA_CHT_UC3_Data(nolock)) D
CROSS JOIN 
(	
	select distinct Product
				   ,Segment
				   ,Param_name
	from GFA_CHT_UC3_Data(nolock)
	where Param_name not like '%Yield%'
) P 
CROSS JOIN
(select distinct Geo from GFA_CHT_UC3_Data)G


DELETE P
FROM #ParametersPerDate P
LEFT JOIN (
	SELECT distinct [Date],Segment,Geo,Product
	FROM GFA_CHT_UC3_Data(nolock)
) D
ON P.LoadDate=D.[Date]
AND P.Segment=D.Segment
AND P.Geo=D.Geo
AND P.Product=D.Product
WHERE D.[Date] IS NULL

UPDATE P
SET P.AggregatedUnitCount = D.AggregatedUnitCount,
P.DailyUnitCount = D.DailyUnitCount 
FROM #ParametersPerDate P join (SELECT DISTINCT Geo,[Date], Product, Segment, AggregatedUnitCount, DailyUnitCount FROM GFA_CHT_UC3_Data) D
on P.Geo = D.Geo and P.LoadDate = D.[Date] and P.Product = D.Product and P.Segment = D.Segment 

INSERT INTO #ATM_GM_PreparedData([Date],Segment,Geo,Product,AggregatedUnitCount,DailyUnitCount,Param_name,Value)
SELECT P.LoadDate,P.Segment,P.Geo,P.Product,P.AggregatedUnitCount,P.DailyUnitCount,P.Parameter,Value=0
FROM #ParametersPerDate P
LEFT JOIN GFA_CHT_UC3_Data(nolock) D
ON P.LoadDate=D.[Date]
AND P.Segment=D.Segment
AND P.Geo=D.Geo
AND P.Product=D.Product
AND P.Parameter=D.Param_name
WHERE D.[Date] IS NULL