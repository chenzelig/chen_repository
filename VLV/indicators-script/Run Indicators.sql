USE [MPDExploration];
GO


SELECT	ROW_NUMBER() OVER (ORDER BY [Assembled_Unit_Seq_Key]) AS [UnitID]
		, TS.[Program_Or_BI_Recipe_Name]
		, L_Sort.[LOT] AS [Sort_Lot]
		, L_Class.[LOT] AS [Class_Lot]
		, D.*
INTO	#Temp1
FROM	[dbo].[VMIN_VLV_CLASS_INDICATORS_Import_Results_Float] D
		INNER JOIN [dbo].[VMIN_VLV_CLASS_INDICATORS_Import_TestSessions] TS
			ON D.[LATO_Start_WW] = TS.[LATO_Start_WW]
			AND D.[LotID] = TS.[LotID]
			AND D.[LOTS_Seq_Key] = TS.[LOTS_Seq_Key]
		LEFT JOIN [dbo].[MPD_MIDAS_Lot] L_Sort
			ON D.[Sort_LotId] = L_Sort.[lotID]
		LEFT JOIN [dbo].[MPD_MIDAS_Lot] L_Class
			ON D.[lotID] = L_Class.[lotID]
WHERE	D.[Substructure_Interface_Bin] IS NOT NULL 
		AND D.[Substructure_Functional_Bin] IS NOT NULL 
		AND D.[Substructure_Data_Bin] IS NOT NULL;

ALTER TABLE #Temp1 ALTER COLUMN [UnitID] BIGINT NOT NULL;
ALTER TABLE #Temp1 ADD PRIMARY KEY CLUSTERED ([UnitID]);

CREATE TABLE #Temp2 (
	[UnitID] BIGINT PRIMARY KEY CLUSTERED,
	[Actual_Value]		FLOAT NOT NULL,
	[Predicted_Value]	FLOAT NOT NULL
)

CREATE TABLE #Tests ( 
	[ID] INT IDENTITY(1,1),
	[TP_Regex] VARCHAR(256),
	[Search_Test_Name] VARCHAR(256),
	[LowSearchValue] FLOAT, 
	[HighSearchValue] FLOAT, 
	[Resolution] FLOAT, 
	[ActualValueColumn] VARCHAR(256),
	[PredictedValueColumn] VARCHAR(256),
	PRIMARY KEY([TP_Regex], [Search_Test_Name])
);
INSERT INTO #Tests
SELECT	[TP_Regex], [Search_Test_Name], [LowSearchValue], [HighSearchValue], [Resolution], 
		T1.[PartitionColumn] AS [ActualValueColumn], 
		T2.[PartitionColumn] AS [PredictedValueColumn]
FROM	[dbo].[VMIN_VLV_INDICATORS_TestDefinitions]	A
		INNER JOIN [dbo].[VMIN_VLV_CLASS_INDICATORS_Import_TestData] T1
			ON T1.[TestName] = A.[Search_Test_Name]
		INNER JOIN [dbo].[VMIN_VLV_CLASS_INDICATORS_Import_TestData] T2
			ON T2.[TestName] = A.[Search_Test_Name]+'_VMINPRED';
		


IF EXISTS (SELECT * FROM #Temp1 WHERE [PartitionKey] <> 0) BEGIN
	THROW 50001, 'PartitionKey <> 0', 1;
END

IF EXISTS (SELECT A.[Program_Or_BI_Recipe_Name]
			FROM #Temp1 A LEFT JOIN #Tests B
				ON A.[Program_Or_BI_Recipe_Name] LIKE B.[TP_Regex]
			GROUP BY A.[Program_Or_BI_Recipe_Name]
			HAVING COUNT(DISTINCT B.[TP_Regex]) <> 1) BEGIN
	THROW 50001, 'Unit matched more than one TP', 1;
END

IF OBJECT_ID('[dbo].[Temp_VMIN_VLV_Indicators_Data]') IS NOT NULL
	DROP TABLE [dbo].[Temp_VMIN_VLV_Indicators_Data];

CREATE TABLE [dbo].[Temp_VMIN_VLV_Indicators_Data] (
	[TP]	VARCHAR(256) NOT NULL,
	[WW]	INT NOT NULL,
	[Class_Lot]	VARCHAR(250) NOT NULL,
	[SortLotID]	VARCHAR(250) NOT NULL,
	[SortWaferID]	INT NOT NULL,
	[Sort_X_Location]	INT NOT NULL,
	[Sort_Y_Location]	INT NOT NULL,
	[Search_Test_Name]	VARCHAR(256) NOT NULL,
	[Actual_Value]		FLOAT NOT NULL,
	[Predicted_Value]	FLOAT NOT NULL,
	[Steps_NP]			INT,
	[Steps_WP]			INT
);

WHILE EXISTS (SELECT * FROM #Tests) BEGIN
	DECLARE @TestID INT = (SELECT TOP 1 [ID] FROM #Tests);

	DECLARE @SQL VARCHAR(MAX) = (SELECT '
		INSERT INTO #Temp2
		SELECT [UnitID], ['+[ActualValueColumn]+'], ['+[PredictedValueColumn]+']
		FROM #Temp1
		WHERE	[Program_Or_BI_Recipe_Name] LIKE '''+[TP_Regex]+'''
				AND ['+[ActualValueColumn]+'] > 0 
				AND ['+[PredictedValueColumn]+'] IS NOT NULL'
	FROM #Tests
	WHERE [ID] = @TestID);

	TRUNCATE TABLE #Temp2;
	EXEC(@SQL);

	INSERT INTO [dbo].[Temp_VMIN_VLV_Indicators_Data]
			([TP]                      , [WW]           , [Class_Lot], [SortLotID], [SortWaferID]  , [Sort_X_Location], [Sort_Y_Location], [Search_Test_Name], [Actual_Value], [Predicted_Value], [Steps_NP], [Steps_WP])
	SELECT	[Program_Or_BI_Recipe_Name], [LATO_Start_WW], [Class_Lot], [Sort_Lot] , [Sort_Wafer_ID], [Sort_X_Location], [Sort_Y_Location], [Search_Test_Name], [Actual_Value], [Predicted_Value], 
			[dbo].[UDF_VMIN_VLV_Calc_Steps_NP]
				([Actual_Value], [LowSearchValue], [HighSearchValue], [Resolution]),
			[dbo].[UDF_VMIN_VLV_Calc_Steps_WP]
				([Actual_Value], [Predicted_Value], [LowSearchValue], [HighSearchValue], [Resolution])
	FROM	#Temp1 A INNER JOIN #Temp2 B
				ON A.[UnitID] = B.[UnitID]
			CROSS JOIN #Tests T
	WHERE	T.[ID] = @TestID;

	DELETE FROM #Tests WHERE [ID] = @TestID;
END

SELECT *
FROM [dbo].[Temp_VMIN_VLV_Indicators_Data]

DROP TABLE #Temp1;
DROP TABLE #Temp2;
DROP TABLE #Tests;