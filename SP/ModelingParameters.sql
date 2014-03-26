--CREATE TABLE #ATM_GM_ModelingParameters (
--SolutionID int,
--ModelGroupID int,
--ModelID int,
--ParameterID int,
--Value varchar(250)
--)

--CREATE TABLE #FinalParametersDefinitions (
--SolutionID int,
--ModelGroupID int,
--ModelID int,
--ParameterID int,
--Value varchar(250)
--)

--INSERT INTO #FinalParametersDefinitions
--SELECT
--	SolutionID,
--	ModelGroupID,
--	ModelID,
--	ParameterID,
--	Value
--FROM #ATM_GM_ModelingParameters M JOIN ATM_GM_ModelingParameters MP
--	ON MP.ModelGroupID=F.ModelGroupID
--	AND MP.ModelGroupID=F.ModelGroupID
--	WHERE MP.SolutionID=-1


CREATE TABLE #GM_ModelingParametesFinal (
	SolutionID int,
	ModelGroupID int,
	ModelID int,
	FeatureID int,
	ParameterID int,
	Value varchar(500)
	)

INSERT INTO #GM_ModelingParametesFinal (SolutionID,ModelGroupID,ModelID,FeatureID,ParameterID,Value)
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
			FROM ATM_GM_Models ) A, [dbo].[ATM_GM_Parameters] P


UPDATE M
SET M.Value = MP.Value,M.FeatureID=MP.FeatureID FROM 
#GM_ModelingParametesFinal M JOIN ATM_GM_ModelingParameters MP
ON M.SolutionID=MP.SolutionID AND M.ParameterID=MP.ParameterID
WHERE MP.ModelGroupID =-1
AND MP.ModelID = -1

UPDATE M
SET M.Value = MP.Value,M.FeatureID=MP.FeatureID FROM 
#GM_ModelingParametesFinal M JOIN ATM_GM_ModelingParameters MP
ON M.SolutionID=MP.SolutionID
AND M.ModelGroupID=MP.ModelGroupID
AND M.ParameterID=MP.ParameterID
WHERE MP.ModelID = -1
AND MP.ModelGroupID <>-1

UPDATE M
SET M.Value = MP.Value,M.FeatureID=MP.FeatureID FROM 
#GM_ModelingParametesFinal M JOIN ATM_GM_ModelingParameters MP
ON M.SolutionID=MP.SolutionID
AND M.ModelGroupID=MP.ModelGroupID
AND M.ModelID=MP.ModelID
AND M.ParameterID=MP.ParameterID
WHERE MP.ModelID <> -1
AND MP.ModelGroupID <>-1




SELECT * FROM #GM_ModelingParametesFinal
WHERE SolutionID <> -1 AND ModelGroupID <> -1 AND ModelID <> -1

