USE MFG_Solutions
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GM_ModelingParameters]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_GM_ModelingParameters]

GO

/*******************************************************           
* Procedure:		[USP_GM_ModelingParameters]  
*                                                              
* Description:		Creating a table of configuration for each solution, model group and model that are in the data base
* 
* ----------------------------------------------------------     
*                                                                    
* Modification Log:                                            
* Date			Modified By			Modification:                         
* ----			-----------			--------------------         
* 2014-6-09		Gil Ben Shalom		Creating the SP 
*******************************************************/ 

CREATE PROCEDURE USP_GM_ModelingParameters 

AS

IF OBJECT_ID('tempdb..#GM_ModelingParameters') IS NOT NULL
	DROP TABLE #GM_ModelingParameters

-------------------------------------------------------------------------
-- Table that holds the parameters for each solution, model group id, and model id
-------------------------------------------------------------------------

CREATE TABLE #GM_ModelingParameters (
	SolutionID int,
	ModelGroupID int,
	ModelID int,
	FeatureID int,
	ParameterID int,
	Value varchar(max)
	)

-------------------------------------------------------------------------------------
-- Sets initial parametrs values for each SolutionID, ModelGroupID, and ModelID
-------------------------------------------------------------------------------------

INSERT INTO #GM_ModelingParameters (SolutionID,ModelGroupID,ModelID,FeatureID,ParameterID,Value)
SELECT
	F.SolutionID,
	F.ModelGroupID,
	F.ModelID,
	F.FeatureID,
	P.ParameterID,
	F.Value
	FROM [dbo].[GM_F_ModelingParameters](nolock) F
	INNER JOIN [dbo].[GM_D_Parameters] P
	ON P.ParameterLevelId=4 --Feature parameters
	WHERE FeatureID IS NOT NULL

INSERT INTO #GM_ModelingParameters (SolutionID,ModelGroupID,ModelID,FeatureID,ParameterID,Value)
SELECT
	M.SolutionID,
	M.ModelGroupID,
	M.ModelID,
	NULL as FeatureID,
	P.ParameterID,
	P.DefaultValue
	FROM GM_D_Models(nolock) M 
	INNER JOIN [dbo].[GM_D_Parameters] P
	ON P.ParameterLevelId=3 --Model parameters
	WHERE ModelID<>-1

INSERT INTO #GM_ModelingParameters (SolutionID,ModelGroupID,ModelID,FeatureID,ParameterID,Value)
SELECT
	MG.SolutionID,
	MG.ModelGroupID,
	NULL as ModelID,
	NULL as FeatureID,
	P.ParameterID,
	P.DefaultValue
	FROM GM_D_ModelGroups(nolock) MG 
	INNER JOIN [dbo].[GM_D_Parameters] P
	ON P.ParameterLevelId=2 --ModelGroup parameters
	WHERE ModelGroupID<>-1

INSERT INTO #GM_ModelingParameters (SolutionID,ModelGroupID,ModelID,FeatureID,ParameterID,Value)
SELECT
	S.SolutionID,
	NULL as ModelGroupID,
	NULL as ModelID,
	NULL as FeatureID,
	P.ParameterID,
	P.DefaultValue
	FROM GM_D_Solutions(nolock) S 
	INNER JOIN [dbo].[GM_D_Parameters] P
	ON P.ParameterLevelId=1 --Solution parameters
	WHERE SolutionID<>-1

-------------------------------------------------------------------------------------
-- changes all parameters values in the SolutionID level
-------------------------------------------------------------------------------------

UPDATE M
SET M.Value = MP.Value
FROM #GM_ModelingParameters M 
INNER JOIN GM_F_ModelingParameters MP
ON M.SolutionID=MP.SolutionID 
 AND M.ParameterID=MP.ParameterID
WHERE MP.ModelGroupID =-1
 AND MP.ModelID = -1

-------------------------------------------------------------------------------------
-- changes all parameters values in the ModelGroupID level
-------------------------------------------------------------------------------------

UPDATE M
SET M.Value = MP.Value,M.FeatureID=MP.FeatureID 
FROM #GM_ModelingParameters M 
INNER JOIN GM_F_ModelingParameters MP
ON M.SolutionID=MP.SolutionID
 AND M.ModelGroupID=MP.ModelGroupID
 AND M.ParameterID=MP.ParameterID
WHERE MP.ModelID = -1

------------------------------------------------------
-- changes all parameters values in the ModelID level
------------------------------------------------------

UPDATE M
SET M.Value = MP.Value,M.FeatureID=MP.FeatureID 
FROM #GM_ModelingParameters M 
INNER JOIN GM_F_ModelingParameters MP
ON M.SolutionID=MP.SolutionID
 AND M.ModelGroupID=MP.ModelGroupID
 AND M.ModelID=MP.ModelID
 AND M.ParameterID=MP.ParameterID

------------------------------
-- return all configurations
------------------------------
SELECT * FROM #GM_ModelingParameters


