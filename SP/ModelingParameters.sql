ALTER PROCEDURE USP_ModelingParameters 

AS

IF OBJECT_ID('tempdb..#GM_ModelingParametes') IS NOT NULL
	DROP TABLE #GM_ModelingParametes

-------------------------------------------------------------------------
-- Table that olds the parameters for each solution, model group id, and model id
-------------------------------------------------------------------------

CREATE TABLE #GM_ModelingParametes (
	SolutionID int,
	ModelGroupID int,
	ModelID int,
	FeatureID int,
	ParameterID int,
	Value varchar(500)
	)


-------------------------------------------------------------------------------------
-- Sets initial parametrs values for each SolutionID, ModelGroupID, and ModelID
-------------------------------------------------------------------------------------

INSERT INTO #GM_ModelingParametes (SolutionID,ModelGroupID,ModelID,FeatureID,ParameterID,Value)
SELECT
	A.SolutionID,
	A.ModelGroupID,
	A.ModelID,
	NULL as FeatureID,
	P.ParameterID,
	P.DefaultValue
	FROM ( SELECT DISTINCT
			SolutionID,
			ModelGroupID,
			ModelID
			FROM GM_D_Models ) A, [dbo].[GM_D_Parameters] P

-------------------------------------------------------------------------------------
-- changes all parameters values in the SolutionID level
-------------------------------------------------------------------------------------

UPDATE M
SET M.Value = MP.Value,M.FeatureID=MP.FeatureID FROM 
#GM_ModelingParametes M JOIN GM_F_ModelingParameters MP
ON M.SolutionID=MP.SolutionID AND M.ParameterID=MP.ParameterID
WHERE MP.ModelGroupID =-1
AND MP.ModelID = -1

-------------------------------------------------------------------------------------
-- changes all parameters values in the ModelGroupID level
-------------------------------------------------------------------------------------

UPDATE M
SET M.Value = MP.Value,M.FeatureID=MP.FeatureID FROM 
#GM_ModelingParametes M JOIN GM_F_ModelingParameters MP
ON M.SolutionID=MP.SolutionID
AND M.ModelGroupID=MP.ModelGroupID
AND M.ParameterID=MP.ParameterID
WHERE MP.ModelID = -1
AND MP.ModelGroupID <>-1

-------------------------------------------------------------------------------------
-- changes all parameters values in the ModelID level
-------------------------------------------------------------------------------------

UPDATE M
SET M.Value = MP.Value,M.FeatureID=MP.FeatureID FROM 
#GM_ModelingParametes M JOIN GM_F_ModelingParameters MP
ON M.SolutionID=MP.SolutionID
AND M.ModelGroupID=MP.ModelGroupID
AND M.ModelID=MP.ModelID
AND M.ParameterID=MP.ParameterID
WHERE MP.ModelID <> -1
AND MP.ModelGroupID <>-1

SELECT * FROM #GM_ModelingParametes
WHERE SolutionID <> -1 AND ModelGroupID <> -1 AND ModelID <> -1

