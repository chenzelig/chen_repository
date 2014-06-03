ALTER PROCEDURE USP_GM_MainProcedure

@SolutionID int=NULL,@ModelGroupID int = NULL, @ModelID int =NULL

AS

----------------------------------------------------
---------------DECLARE VARIABLES--------------------
----------------------------------------------------

DECLARE @MGID int, @MID int, @SID int, @CMD varchar(max)

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


IF OBJECT_ID('tempdb..#ATM_GM_ModelGroups') IS NOT NULL
	DROP TABLE #ATM_GM_ModelGroups

CREATE TABLE #ATM_GM_ModelGroups (SolutionId int,ModelGroupID int,ModelID Int)

INSERT INTO #ATM_GM_ModelGroups
SELECT S.SolutionID,MG.ModelGroupID,M.ModelID FROM [dbo].[GM_D_Solutions] S JOIN [dbo].[GM_D_ModelGroups] MG
on S.SolutionID = MG.SolutionID
join [dbo].[GM_D_Models] M on MG.ModelGroupID = M.ModelGroupID and MG.SolutionID = M.SolutionID
WHERE S.SolutionID <> -1 and MG.ModelGroupID <> -1 and M.ModelID <> -1
and S.SolutionID = isnull(@SolutionID,S.SolutionID)
and MG.ModelGroupID = isnull(@ModelGroupID,MG.ModelGroupID)
and M.ModelID = isnull(@ModelID,M.ModelID)
AND coalesce(@SolutionID,@ModelGroupID,@ModelID) is not null

---------------------------------------------------------------------------------------
--Executing the data extraction for each model group in the framework for current solution
---------------------------------------------------------------------------------------


	WHILE EXISTS(SELECT 1 FROM #ATM_GM_ModelGroups)
	BEGIN

		SET @MGID= ( SELECT min(ModelGroupID)
							 FROM #ATM_GM_ModelGroups)

	------------------------------------------------------------------
	--Generic Table for holding raw data for each model group
	------------------------------------------------------------------

		IF OBJECT_ID('tempdb..#ATM_GM_RawData') IS NOT NULL
			DROP TABLE #ATM_GM_RawData

		CREATE TABLE #ATM_GM_RawData (Dummy int)

		--------------TO DO!!!!!!!!!!!!!!! Add the execution of replacing parameters. will be configurated in the parameters table.

		EXEC USP_DataExtraction @ModelGroupID= @MGID

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

			SET @MID= (SELECT min(ModelID)
							FROM #ATM_GM_Models)

			CREATE TABLE #ATM_GM_PreparedData (Dummy int)

			SELECT @CMD = Value
			FROM #ATM_GM_ModelingParameters
			WHERE ModelID = @MID
			and ParameterId=4 -- Parameter 4 is Data preperation Attributes

			PRINT(@CMD)
			EXEC(@CMD)

			ALTER Table #ATM_GM_PreparedData
			DROP Column Dummy


			SELECT @CMD = Value
			FROM #ATM_GM_ModelingParameters
			WHERE ModelID = @MID
			and ParameterId=3 -- Parameter 3 i Data preperation SP

			PRINT(@CMD)
			EXEC(@CMD)

			SELECT * FROM  #ATM_GM_PreparedData -- For Testing

			--to DO!!!!!!!!!!!!!!!!!!!!!!!!!!!! Exec a procedure of this specific model

			DELETE FROM #ATM_GM_Models
			WHERE ModelID = @MID
		
		END -- End of model loop


		DELETE FROM #ATM_GM_ModelGroups
		WHERE ModelGroupID = @MGID
	END -- End of model group loop