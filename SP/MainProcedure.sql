ALTER PROCEDURE USP_GM_MainProcedure

AS

----------------------------------------------------
---------------DECLARE VARIABLES--------------------
----------------------------------------------------

DECLARE @ModelGroupID int, @ModelID int, @SolutionID int

---------------------------------------------------------------------------------------
--Creating a table that holds the configuration for each solution,model group and model
---------------------------------------------------------------------------------------

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

INSERT INTO #ATM_GM_ModelingParameters
EXEC USP_ModelingParameters

---------------------------------------------------------------------------------------
--Creating a table that holds all the solution id's in the framework
---------------------------------------------------------------------------------------


IF OBJECT_ID('tempdb..#ATM_GM_Solutions') IS NOT NULL
	DROP TABLE #ATM_GM_Solutions

CREATE TABLE #ATM_GM_Solutions (SolutionId int)

INSERT INTO #ATM_GM_Solutions
SELECT DISTINCT SolutionId
FROM [dbo].[GM_D_Solutions]
WHERE SolutionID <>-1

WHILE EXISTS(SELECT 1 FROM #ATM_GM_Solutions)
BEGIN

	SET @SolutionID= ( SELECT min(SolutionID)
						FROM #ATM_GM_Solutions)

	---------------------------------------------------------------------------------------
	--Creating a table that holds all the model group id's in the framework
	---------------------------------------------------------------------------------------


	IF OBJECT_ID('tempdb..#ATM_GM_ModelGroups') IS NOT NULL
		DROP TABLE #ATM_GM_ModelGroups

	CREATE TABLE #ATM_GM_ModelGroups (ModelGroupId int)

	INSERT INTO #ATM_GM_ModelGroups
	SELECT DISTINCT ModelGroupID
	FROM [dbo].[GM_D_ModelGroups]
	WHERE SolutionID =  @SolutionID
	AND ModelGroupID <> -1

	---------------------------------------------------------------------------------------
	--Executing the data extraction for each model group in the framework for current solution
	---------------------------------------------------------------------------------------


	WHILE EXISTS(SELECT 1 FROM #ATM_GM_ModelGroups)
	BEGIN

		SET @ModelGroupId= ( SELECT min(ModelGroupID)
							 FROM #ATM_GM_ModelGroups)

	------------------------------------------------------------------
	--Generic Table for holding raw data for each model group
	------------------------------------------------------------------

		IF OBJECT_ID('tempdb..#ATM_GM_RawData') IS NOT NULL
			DROP TABLE #ATM_GM_RawData

		CREATE TABLE #ATM_GM_RawData (Dummy int)

		--------------TO DO!!!!!!!!!!!!!!! Add the execution of replacing parameters. will be configurated in the parameters table.

		EXEC USP_DataExtraction @ModelGroupID= @ModelGroupId, @SolutionID = @SolutionID

		---------------------------------------------------------------------------------------
		--Creating a table that holds all the model id's in the framework
		---------------------------------------------------------------------------------------

		IF OBJECT_ID('tempdb..#ATM_GM_Models') IS NOT NULL
			DROP TABLE #ATM_GM_Models

		CREATE TABLE #ATM_GM_Models (ModelId int)

		INSERT INTO #ATM_GM_Models
		SELECT DISTINCT ModelID
		FROM [dbo].[GM_D_Models]
		WHERE ModelGroupId = @ModelGroupId
		AND SolutionID = @SolutionID
		AND ModelID <> -1

		WHILE EXISTS(SELECT 1 FROM #ATM_GM_Models)
		BEGIN

		------------------------------------------------------------------
		--Generic Table for holding prepared data for each model
		------------------------------------------------------------------

			IF OBJECT_ID('tempdb..#ATM_GM_PreparedData') IS NOT NULL
				DROP TABLE #ATM_GM_PreparedData

			CREATE TABLE #ATM_GM_PreparedData (Dummy int)

				SET @ModelId= ( SELECT min(ModelID)
								FROM #ATM_GM_Models)
			--to DO!!!!!!!!!!!!!!!!!!!!!!!!!!!! Exec a procedure of this specific model

			DELETE FROM #ATM_GM_Models
			WHERE ModelID = @ModelID
		
		END -- End of model loop


		DELETE FROM #ATM_GM_ModelGroups
		WHERE ModelGroupID = @ModelGroupId

	END --end of model group loop

	DELETE FROM #ATM_GM_Solutions
	WHERE SolutionID = @SolutionID

END