USE [MFG_Solutions]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GM_MainProcedure]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_GM_MainProcedure]
GO

/****** Object:  StoredProcedure [dbo].[USP_GM_MainProcedure]    Script Date: 8/5/2014 12:42:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************           
* Procedure:		[USP_GM_MainProcedure]  
*                                                              
* Description:		Main procedure of the generic framework. Runs data extractions, modeling, evaluation etc.   
* 
* ----------------------------------------------------------     
*                                                                    
* Modification Log:                                            
* Date			Modified By			Modification:                         
* ----			-----------			--------------------         
* 2014-6-09		Gil Ben Shalom		Creating the SP 
* 2014-08-07    Neiman, Jacob		Adding Evaluation part 
*******************************************************/ 

CREATE PROCEDURE [dbo].[USP_GM_MainProcedure]

@SolutionID int=NULL,@ModelGroupID int = NULL, @ModelID int =NULL

AS

BEGIN TRY


----------------------------------------------------
---------------DECLARE VARIABLES--------------------
----------------------------------------------------

DECLARE @MGID int, @MID int, @SID int, @CMD varchar(max),@FailPoint int,@StartTime datetime = GETUTCDATE(),@EndTime datetime
,@ErrorMessage varchar(1000),@LogMessage varchar(1000),@ModelGroupLogMessage varchar (1000), @ModelGroupEndTime datetime
,@ModelGroupStartTime datetime,@ModelGroupName varchar(100),@SolutionName varchar(100),@Formula varchar(max)

DECLARE @ModelGroupInfoLog TABLE (
	Step VARCHAR(100),
	StartTime DATETIME,
	EndTime DATETIME, 
	Secs AS DATEDIFF(SS,StartTime,EndTime)
)

SET @LogMessage = 'Starting SolutionID = '+ISNULL(convert(varchar(5),@SolutionID),'NULL')+', ModelGroupID = '+ISNULL(convert(varchar(5),@ModelGroupID),'NULL')+', ModelID = '+ISNULL(convert(varchar(5),@ModelID),'NULL')
EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_MainProcedure', 
						@EngineName = 'MFG_Solutions', @ModuleName = 'MainProcedure', @LogEventMessage = @LogMessage, 
						@StartDate = @StartTime, @EndDate = @EndTime, @LogEventType = 'I'	


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

IF OBJECT_ID('tempdb..#ATM_GM_ModelGroups') IS NOT NULL
	DROP TABLE #ATM_GM_ModelGroups

CREATE TABLE #ATM_GM_ModelGroups (SolutionId int,ModelGroupID int,ModelID Int,IsIndicators int)

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

 --select * from #ATM_GM_ModelGroups
---------------------------------------------------------------------------------------
--Executing the data extraction for each model group in the framework for current solution
---------------------------------------------------------------------------------------

	WHILE EXISTS(SELECT 1 FROM #ATM_GM_ModelGroups)
	BEGIN
		-- Get the first model group to execute
		SELECT @MGID= MIN(ModelGroupID)
		FROM #ATM_GM_ModelGroups

		-- Taking names for logging		
		SELECT @ModelGroupName=ModelGroupDescription,
			   @SolutionName=SolutionDescription
		FROM(
			SELECT TOP 1 ModelGroupDescription,SolutionDescription
			FROM [dbo].[GM_D_Solutions] S 
			INNER JOIN [GM_D_ModelGroups] MG 
			ON S.SolutionID = MG.SolutionID
			 AND MG.ModelGroupID=@MGID
		)A

		SET @ModelGroupStartTime = GETUTCDATE()

	------------------------------------------------------------------
	--Generic Table for holding raw data for each model group
	------------------------------------------------------------------

		IF OBJECT_ID('tempdb..#ATM_GM_RawData') IS NOT NULL
			DROP TABLE #ATM_GM_RawData

		CREATE TABLE #ATM_GM_RawData (Dummy int) --Table created with dummy column that will be altered and dropped inside the data extraction module	

		SET @FailPoint = 1 -- Data extraction

		INSERT INTO @ModelGroupInfoLog(Step,StartTime)
		SELECT 'DataExtraction-Model Group '+convert(varchar(5),@MGID),GETUTCDATE()

		EXEC USP_GM_DataExtraction @ModelGroupID= @MGID

		UPDATE @ModelGroupInfoLog
		SET EndTime = GETUTCDATE()
		where Step='DataExtraction'

		---------------------------------------------------------------------------------------
		--Creating a table that holds all the model id's in the framework for current solution and model group
		---------------------------------------------------------------------------------------

		IF OBJECT_ID('tempdb..#ATM_GM_Models') IS NOT NULL
			DROP TABLE #ATM_GM_Models

		CREATE TABLE #ATM_GM_Models (ModelID int)

		INSERT INTO #ATM_GM_Models
		SELECT DISTINCT ModelID
		FROM #ATM_GM_ModelGroups
		WHERE ModelGroupId = @MGID

		WHILE EXISTS(SELECT 1 FROM #ATM_GM_Models)
		BEGIN

			------------------------------------------------------------------
			--Generic Table for holding prepared data for each model
			------------------------------------------------------------------

			IF OBJECT_ID('tempdb..#ATM_GM_PreparedData') IS NOT NULL
				DROP TABLE #ATM_GM_PreparedData

			SELECT @MID= MIN(ModelID)
			FROM #ATM_GM_Models

			CREATE TABLE #ATM_GM_PreparedData (Dummy int)--Table created with dummy column that will be altered and dropped in the next query

			SET @FailPoint = 2 -- Creating the PreparedData table

			SELECT @CMD = 'ALTER TABLE #ATM_GM_PreparedData ADD '+Value
			FROM #ATM_GM_ModelingParameters
			WHERE ModelID = @MID
			 AND ParameterId=4 -- Parameter 4 is the PreparedData table schema

			--PRINT(@CMD)
			EXEC(@CMD)

			--Removing the dummy column
			ALTER TABLE #ATM_GM_PreparedData
			DROP COLUMN Dummy

			------------------------------------------------------------------
			--Population Filter
			------------------------------------------------------------------

			SET @FailPoint = 5 -- Population Filter

			IF EXISTS(SELECT 1 FROM #ATM_GM_ModelingParameters WHERE ModelGroupID = @MGID AND ParameterID =19 and Value<>'' ) --if there is population filter configured for this model group
			BEGIN
				--keeping #ATM_GM_RawData data for next runs in this loop
				IF OBJECT_ID('tempdb..#ATM_GM_RawDataCopy') IS NULL --if table does not exist
				BEGIN
					SELECT 'CopyingData to RawDataCopy'
					SELECT * INTO #ATM_GM_RawDataCopy
					FROM #ATM_GM_RawData
					
				END
								
				ELSE --#ATM_GM_RawDataCopy was already populated
				BEGIN
					Print 'CopyingData from RawDataCopy to RawData'
					TRUNCATE Table #ATM_GM_RawData
					INSERT INTO #ATM_GM_RawData
					SELECT * FROM #ATM_GM_RawDataCopy
				END

				IF EXISTS(SELECT 1 FROM #ATM_GM_ModelingParameters WHERE ModelID = @MID AND ParameterID =19 and Value<>'' )
				BEGIN
					
					SELECT @CMD = 'DELETE FROM #ATM_GM_RawData WHERE '+REPLACE(Value,'','''')
					FROM #ATM_GM_ModelingParameters
					WHERE ModelID = @MID
					AND ParameterId=19 -- Parameter 19 is the PopulationFilter
					--SELECT @CMD as DeleteStatement
					PRINT(@CMD)
					EXEC(@CMD)
				END
			END

			------------------------------------------------------------------
			--Populating Data Preperation table
			------------------------------------------------------------------

			SET @FailPoint = 3 -- Executing the data preperation SP

			INSERT INTO @ModelGroupInfoLog(Step,StartTime)
			SELECT 'DataPreperation-Model '+convert(varchar(5),@MID),GETUTCDATE()

			SELECT @CMD = Value
			FROM #ATM_GM_ModelingParameters
			WHERE ModelID = @MID
			 AND ParameterId=3 -- Parameter 3 is the data preparation SP

			PRINT(@CMD)
			EXEC(@CMD)

			UPDATE @ModelGroupInfoLog
			SET EndTime = GETUTCDATE()
			where Step = 'DataPreperation-Model '+convert(varchar(5),@MID)

			--SELECT * FROM  #ATM_GM_PreparedData -- For Testing

			------------------------------------------------------------------
			--Executing the model using the prepared data table
			------------------------------------------------------------------

			SET @FailPoint = 4 -- executing the model

			INSERT INTO @ModelGroupInfoLog(Step,StartTime)
			SELECT 'Modeling-Model '+convert(varchar(5),@MID),GETUTCDATE()

			SELECT @CMD = Value
			FROM #ATM_GM_ModelingParameters
			WHERE ModelID = @MID
			 AND ParameterId=5 -- Parameter 5 is the Model Execution

			PRINT(@CMD)
			EXEC(@CMD)

			UPDATE @ModelGroupInfoLog
			SET EndTime = GETUTCDATE()
			WHERE Step = 'Modeling-Model '+convert(varchar(5),@MID)
			
			--Evaluate only if Evaluation params were configured
			IF ((select count(*) from [dbo].[GM_F_ModelEvaluation] where ModelID = @MID) > 0) BEGIN
				--Adding a formula column to #PreparedData 
				--insert modeling formula as a checkfunction			
				select @Formula = [dbo].[UDF_GM_GetFormulaString](@MID,@SolutionID)
				print(@Formula)

				SELECT @CMD = 'ALTER TABLE #ATM_GM_PreparedData ADD [PREDICTION] as ' +@Formula + ' '

				--PRINT(@CMD)
				EXEC(@CMD)

				--select * from #ATM_GM_PreparedData --for Debug
			
				EXEC [dbo].[USP_GM_EvaluationProcedure] @ModelID=@MID
			
			END


			--INDICATORS!!!!
			exec [dbo].[USP_GM_IndicatorProcedure] @ModelID =100
			--INDICATORS!!!!

			DELETE FROM #ATM_GM_Models
			WHERE ModelID = @MID

			SET @MID = NULL
		
		END -- End of model loop

		IF OBJECT_ID('tempdb..#ATM_GM_RowDataCopy') IS NOT NULL-- if we used this table for the population filter
		DROP TABLE #ATM_GM_RowDataCopy

		SELECT  @ModelGroupLogMessage = (SELECT Step,Secs FROM @ModelGroupInfoLog [L] ORDER BY 2 DESC FOR XML AUTO )	
		SET @ModelGroupEndTime = GETUTCDATE()

		EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_MainProcedure', 
							@EngineName = 'MFG_Solutions', @ModuleName = 'MainProcedure', @SectionName = @SolutionName, 
							@SubSectionName = @ModelGroupName, @LogEventMessage = @ModelGroupLogMessage, 
							@StartDate = @ModelGroupStartTime, @EndDate = @ModelGroupEndTime, @LogEventType = 'I'	 

		DELETE FROM @ModelGroupInfoLog


		DELETE FROM #ATM_GM_ModelGroups
		WHERE ModelGroupID = @MGID
	END -- End of model group loop


	SET @EndTime = GETUTCDATE()
	SET @LogMessage = 'Fininshed SolutionID = '+ISNULL(convert(varchar(5),@SolutionID),'NULL')+', ModelGroupID = '+ISNULL(convert(varchar(5),@ModelGroupID),'NULL')+', ModelID = '+ISNULL(convert(varchar(5),@ModelID),'NULL')
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_MainProcedure', 
							@EngineName = 'MFG_Solutions', @ModuleName = 'MainProcedure', @LogEventMessage = @LogMessage, 
							@StartDate = @StartTime, @EndDate = @EndTime, @LogEventType = 'I'	

END TRY

	BEGIN CATCH    
	SET @ErrorMessage = 'Fail Point: ' + CONVERT(VARCHAR(3), @FailPoint) + '. '+'SolutionID = '+ISNULL(convert(varchar(5),@SolutionID),'NULL')+', ModelGroupID = '+ISNULL(convert(varchar(5),@MGID),'NULL')+' ,ModelID = '+ISNULL(convert(varchar(5),@MID),'NULL') + ERROR_MESSAGE()
	EXEC AdvancedBIsystem.dbo.USP_GAL_InsertLogEvent @LogEventObjectName = 'USP_GM_MainProcedure', @EngineName = 'MFG_Solutions', @SectionName=@SolutionName,
							@ModuleName = 'MainProcedure', @LogEventMessage = @ErrorMessage, @LogEventType = 'E' 
	RAISERROR (N'USP_GM_MainProcedure::FailPoint- %d ERR-%s', 16,1, @FailPoint, @ErrorMessage)  
END CATCH 
GO

