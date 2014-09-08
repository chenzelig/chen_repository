USE [MFG_Solutions]
GO

DECLARE

@SolutionID int=20,@ModelGroupID int = 2011 ,@ModelID INT=NULL


DECLARE @ExecutionMode int --to be moved to procedure parameters
SET @ExecutionMode = 2 -- 0- modeling+indicators / 1- modeling / 2- indicators
----------------------------------------------------
---------------DECLARE VARIABLES--------------------
----------------------------------------------------

DECLARE @MGID int, @MID int, @SID int, @CMD varchar(max),@FailPoint int,@StartTime datetime = GETUTCDATE(),@EndTime datetime
,@ErrorMessage varchar(1000),@LogMessage varchar(1000),@ModelGroupLogMessage varchar (1000), @ModelGroupEndTime datetime
,@ModelGroupStartTime datetime,@ModelGroupName varchar(100),@SolutionName varchar(100),@Formula varchar(max)

------------------------------------------------------------------------------------------------------------
--Creating a table that holds the parameters configuration for each solution,model group, model and feature
------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#ATM_GM_ModelingParameters') IS NOT NULL
	DROP TABLE #ATM_GM_ModelingParameters

CREATE TABLE #ATM_GM_ModelingParameters (
	SolutionID int,
	ModelGroupID int,
	ModelID int,
	FeatureID int,
	ParameterID int,
	Value varchar(max)
	)

-- Populate the table
INSERT INTO #ATM_GM_ModelingParameters
EXEC USP_GM_ModelingParameters





-----------------------------------------------------------------------------------------------
-- Creating a table that holds all the solutions/model groups/models for the current execution
-----------------------------------------------------------------------------------------------
SET @FailPoint = 2

IF OBJECT_ID('tempdb..#ATM_GM_ModelGroups') IS NOT NULL
	DROP TABLE #ATM_GM_ModelGroups

CREATE TABLE #ATM_GM_ModelGroups (SolutionId int,ModelGroupID int,ModelID Int)

INSERT INTO #ATM_GM_ModelGroups
SELECT S.SolutionID,MG.ModelGroupID,M.ModelID 
FROM [dbo].[GM_D_Solutions] S 
INNER JOIN [dbo].[GM_D_ModelGroups] MG
ON S.SolutionID = MG.SolutionID
INNER JOIN [dbo].[GM_D_Models] M 
ON MG.ModelGroupID = M.ModelGroupID 
 AND MG.SolutionID = M.SolutionID
WHERE S.SolutionID <> -1 
 AND MG.ModelGroupID <> -1 
 AND M.ModelID <> -1
 AND S.SolutionID = isnull(@SolutionID,S.SolutionID)
 AND MG.ModelGroupID = isnull(@ModelGroupID,MG.ModelGroupID)
 AND M.ModelID = isnull(@ModelID,M.ModelID)
 AND coalesce(@SolutionID,@ModelGroupID,@ModelID) is not null

---------------------------------------------------------------------------------------
--Executing the data extraction for each model group in the framework for current solution
---------------------------------------------------------------------------------------
SET @FailPoint = 3

	--WHILE EXISTS(SELECT 1 FROM #ATM_GM_ModelGroups)
	--BEGIN
		SET @FailPoint = 4

		-- Get the first model group to execute
		SELECT @MGID= MIN(ModelGroupID)
		FROM #ATM_GM_ModelGroups

		--------------------------------------------------------------------
		----Generic Table for holding modeling raw data for each model group
		--------------------------------------------------------------------
		--	IF OBJECT_ID('tempdb..#ATM_GM_RawData') IS NOT NULL
		--		DROP TABLE #ATM_GM_RawData

		--	CREATE TABLE #ATM_GM_RawData (Dummy int) --Table created with dummy column that will be altered and dropped inside the data extraction module	

		--	SET @FailPoint = 5

		--	EXEC USP_GM_DataExtraction @ModelGroupID= @MGID, @ExecutionMode=1

			
		--END
		------------------------------------------------------------------
		--Generic Table for holding indicators raw data for each model group
		------------------------------------------------------------------

			EXEC [USP_VM2F_BDU_Class_Indicators_PreDataExtraction] @SolutionID=@SolutionID, @ModelgroupID=@ModelgroupID

			IF OBJECT_ID('tempdb..#ATM_GM_Indicators_RawData') IS NOT NULL
				DROP TABLE #ATM_GM_Indicators_RawData

			CREATE TABLE #ATM_GM_Indicators_RawData (Dummy int) --Table created with dummy column that will be altered and dropped inside the data extraction module	


			EXEC USP_GM_DataExtraction @ModelGroupID= @MGID, @ExecutionMode=2

			
	--	---------------------------------------------------------------------------------------
	--	--Creating a table that holds all the model id's in the framework for current solution and model group
	--	---------------------------------------------------------------------------------------
	--	SET @FailPoint = 7

		IF OBJECT_ID('tempdb..#ATM_GM_Models') IS NOT NULL
			DROP TABLE #ATM_GM_Models

		CREATE TABLE #ATM_GM_Models (ModelID int)

		INSERT INTO #ATM_GM_Models
		SELECT DISTINCT ModelID
		FROM #ATM_GM_ModelGroups
		WHERE ModelGroupId = @MGID

	--	WHILE EXISTS(SELECT 1 FROM #ATM_GM_Models)
	--	BEGIN
			
			SELECT @MID= MIN(ModelID)
			FROM #ATM_GM_Models

	--		-------------
	--		-- Modeling
	--		-------------
	--		IF @ExecutionMode IN(0,1)
	--		BEGIN
	--			------------------------------------------------------------------
	--			--Generic Table for holding prepared data for each model
	--			------------------------------------------------------------------

				--IF OBJECT_ID('tempdb..#ATM_GM_PreparedData') IS NOT NULL
				--	DROP TABLE #ATM_GM_PreparedData

				--CREATE TABLE #ATM_GM_PreparedData (Dummy int)--Table created with dummy column that will be altered and dropped in the next query

				--SELECT @CMD = 'ALTER TABLE #ATM_GM_PreparedData ADD '+Value
				--FROM #ATM_GM_ModelingParameters
				--WHERE ModelID = @MID
				-- AND ParameterId=4 -- Parameter 4 is the modeling PreparedData table schema

				--PRINT(@CMD)
				--EXEC(@CMD)

				----Removing the dummy column
				--ALTER TABLE #ATM_GM_PreparedData
				--DROP COLUMN Dummy

	--			------------------------------------------------------------------
	--			--Population Filter
	--			------------------------------------------------------------------

	--			SET @FailPoint = 10 -- Population Filter

	--			IF EXISTS(SELECT 1 FROM #ATM_GM_ModelingParameters WHERE ModelGroupID = @MGID AND ParameterID =19 and Value<>'' ) --if there is population filter configured for this model group
	--			BEGIN
	--				--keeping #ATM_GM_RawData data for next runs in this loop
	--				IF OBJECT_ID('tempdb..#ATM_GM_RawDataCopy') IS NULL --if table does not exist
	--				BEGIN
	--					SELECT 'CopyingData to RawDataCopy'
	--					SELECT * INTO #ATM_GM_RawDataCopy
	--					FROM #ATM_GM_RawData
					
	--				END
								
	--				ELSE --#ATM_GM_RawDataCopy was already populated
	--				BEGIN
	--					Print 'CopyingData from RawDataCopy to RawData'
	--					TRUNCATE Table #ATM_GM_RawData
	--					INSERT INTO #ATM_GM_RawData
	--					SELECT * FROM #ATM_GM_RawDataCopy
	--				END

	--				IF EXISTS(SELECT 1 FROM #ATM_GM_ModelingParameters WHERE ModelID = @MID AND ParameterID =19 and Value<>'' )
	--				BEGIN
					
	--					SELECT @CMD = 'DELETE FROM #ATM_GM_RawData WHERE '+REPLACE(Value,'','''')
	--					FROM #ATM_GM_ModelingParameters
	--					WHERE ModelID = @MID
	--					AND ParameterId=19 -- Parameter 19 is the PopulationFilter
	--					--SELECT @CMD as DeleteStatement
	--					--PRINT(@CMD)
	--					EXEC(@CMD)
	--				END
	--			END

	--			------------------------------------------------------------------
	--			--Populating Data Preperation table
	----			------------------------------------------------------------------

	--			SELECT @CMD = Value
	--			FROM #ATM_GM_ModelingParameters
	--			WHERE ModelID = @MID
	--			 AND ParameterId=3 -- Parameter 3 is the data preparation SP

	--			PRINT(@CMD)
	--			EXEC(@CMD)

	--			--SELECT * FROM  #ATM_GM_PreparedData -- For Testing
			
	--			------------------------------------------------------------------
	--			--Executing the model using the prepared data table
	--			------------------------------------------------------------------
	
	--			SET @FailPoint = 12 -- executing the model

	--			INSERT INTO @ModelGroupInfoLog(Step,StartTime)
	--			SELECT 'Modeling-Model '+convert(varchar(5),@MID),GETUTCDATE()

	--			SELECT @CMD = Value
	--			FROM #ATM_GM_ModelingParameters
	--			WHERE ModelID = @MID
	--			 AND ParameterId=5 -- Parameter 5 is the Model Execution

	--			--PRINT(@CMD)
	--			EXEC(@CMD)

	--			UPDATE @ModelGroupInfoLog
	--			SET EndTime = GETUTCDATE()
	--			WHERE Step = 'Modeling-Model '+convert(varchar(5),@MID)

	--			IF ((select count(*) from [dbo].[GM_F_ModelEvaluation] where ModelID = @MID) > 0) BEGIN
					
	--				SET @FailPoint = 13 -- Executing the data preperation SP

	--				INSERT INTO @ModelGroupInfoLog(Step,StartTime)
	--				SELECT 'Evaluating-Model '+convert(varchar(5),@MID),GETUTCDATE()

					
	--				--insert modeling formula as a checkfunction			
	--				select @Formula = [dbo].[UDF_GM_GetFormulaString](@MID,@SolutionID)
	--				print(@Formula)
	--				--Adding a formula column to #PreparedData 
	--				SELECT @CMD = 'ALTER TABLE #ATM_GM_PreparedData ADD [PREDICTION] as ' +@Formula + ' '
	--				EXEC(@CMD)
	--				EXEC [dbo].[USP_GM_EvaluationProcedure] @ModelID=@MID

	--				UPDATE @ModelGroupInfoLog
	--				SET EndTime = GETUTCDATE()
	--				WHERE Step = 'Evaluating-Model '+convert(varchar(5),@MID)
			
	--			END


				
	--		END
	--		--------------
	--		-- Indicators
	--		--------------
	--		IF @ExecutionMode IN(0,2) AND EXISTS (select top 1 1 from #ATM_GM_ModelingParameters where ModelID = @MID and ParameterId=22)
	--		BEGIN
	--			------------------------------------------------------------------
	--			--Generic Table for holding prepared data for each model
	--			------------------------------------------------------------------
				IF OBJECT_ID('tempdb..#ATM_GM_Indicators_PreparedData') IS NOT NULL
					DROP TABLE #ATM_GM_Indicators_PreparedData

				CREATE TABLE #ATM_GM_Indicators_PreparedData (Dummy int)--Table created with dummy column that will be altered and dropped in the next query

				SET @FailPoint = 14 -- Creating the PreparedData table

				SELECT @CMD = 'ALTER TABLE #ATM_GM_Indicators_PreparedData ADD '+Value
				FROM #ATM_GM_ModelingParameters
				WHERE ModelID = @MID
				 AND ParameterId=22 -- Parameter 22 is the indicators PreparedData table schema

				PRINT(@CMD)
				EXEC(@CMD)

				--Removing the dummy column
				ALTER TABLE #ATM_GM_Indicators_PreparedData
				DROP COLUMN Dummy
				
	--			------------------------------------------------------------------
	--			--Populating Indicators prepared data table
	--			------------------------------------------------------------------

				SELECT @CMD = Value
				FROM #ATM_GM_ModelingParameters
				WHERE ModelID = @MID
				 AND ParameterId=23 -- Parameter 23 is the indicators data preparation SP

				PRINT(@CMD)
				EXEC(@CMD)

				SELECT * FROM #ATM_GM_Indicators_PreparedData

			
				
			--END

	--		--INDICATORS!!!!
	--		exec [dbo].[USP_GM_IndicatorProcedure] @ModelID =@MID
	--		--INDICATORS!!!!
			

	--		DELETE FROM #ATM_GM_Models
	--		WHERE ModelID = @MID

	--		SET @MID = NULL
	--	END -- End of model loop

	--	SET @FailPoint = 16

	--	IF OBJECT_ID('tempdb..#ATM_GM_RawDataCopy') IS NOT NULL-- if we used this table for the population filter
	--	DROP TABLE #ATM_GM_RawDataCopy

	--	SELECT  @ModelGroupLogMessage = (SELECT Step,Secs FROM @ModelGroupInfoLog [L] ORDER BY 2 DESC FOR XML AUTO )	
	--	SET @ModelGroupEndTime = GETUTCDATE()

	--	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_MainProcedure', 
	--						@EngineName = 'MFG_Solutions', @ModuleName = 'MainProcedure', @SectionName = @SolutionName, 
	--						@SubSectionName = @ModelGroupName, @LogEventMessage = @ModelGroupLogMessage, 
	--						@StartDate = @ModelGroupStartTime, @EndDate = @ModelGroupEndTime, @LogEventType = 'I'	 

	--	DELETE FROM @ModelGroupInfoLog


	--	DELETE FROM #ATM_GM_ModelGroups
	--	WHERE ModelGroupID = @MGID
	--END -- End of model group loop


	--SET @EndTime = GETUTCDATE()
	--SET @LogMessage = 'Fininshed SolutionID = '+ISNULL(convert(varchar(5),@SolutionID),'NULL')+', ModelGroupID = '+ISNULL(convert(varchar(5),@ModelGroupID),'NULL')+', ModelID = '+ISNULL(convert(varchar(5),@ModelID),'NULL')
	--EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_MainProcedure', 
	--						@EngineName = 'MFG_Solutions', @ModuleName = 'MainProcedure', @LogEventMessage = @LogMessage, 
	--						@StartDate = @StartTime, @EndDate = @EndTime, @LogEventType = 'I'	


	