USE MFG_Solutions
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GM_ModelIndicators]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_GM_ModelIndicators]

GO

/*******************************************************           
* Procedure:		[USP_GM_ModelIndicators]  
*                                                              
* Description:		Creating indicators configuration list per solution/model group/model
* 
* ----------------------------------------------------------     
*                                                                    
* Modification Log:                                            
* Date			Modified By			Modification:                         
* ----			-----------			--------------------         
* 2014-09-04	Itamar Golan		Creating the SP 
*******************************************************/ 

CREATE PROCEDURE USP_GM_ModelIndicators

AS

IF OBJECT_ID('tempdb..#GM_ModelIndicators') IS NOT NULL
	DROP TABLE #GM_ModelIndicators

-------------------------------------------------------------------------
-- Table that holds the parameters for each solution, model group id, and model id
-------------------------------------------------------------------------

CREATE TABLE #GM_ModelIndicators (
	SolutionID int,
	ModelGroupID int,
	ModelID int,
	IndicatorLevelID int,
	IndicatorID int,
	DataTableID int
)


--Configuration by model
INSERT INTO #GM_ModelIndicators (SolutionID,ModelGroupID,ModelID,IndicatorLevelID,IndicatorID,DataTableID)
SELECT
	SolutionID,
	ModelGroupID,
	ModelID,
	IndicatorLevelID,
	IndicatorID,
	DataTableIDs
	FROM [dbo].[GM_F_ModelIndicators](nolock)
	WHERE ModelID<>-1

--Configuration by model group
INSERT INTO #GM_ModelIndicators (SolutionID,ModelGroupID,ModelID,IndicatorLevelID,IndicatorID,DataTableID)
SELECT
	I.SolutionID,
	I.ModelGroupID,
	M.ModelID,
	I.IndicatorLevelID,
	I.IndicatorID,
	I.DataTableIDs
	FROM [dbo].[GM_F_ModelIndicators](nolock) I
	INNER JOIN [dbo].[GM_D_Models](nolock) M
	ON I.ModelGroupID=M.ModelGroupID
	LEFT JOIN #GM_ModelIndicators MI
	ON MI.SolutionID=I.SolutionID
	  AND MI.ModelGroupID=I.ModelGroupID
	  AND MI.ModelID=M.ModelID
	  AND MI.IndicatorLevelID=I.IndicatorLevelID
	  AND MI.IndicatorID=I.IndicatorID
	WHERE I.ModelGroupID<>-1
	  AND I.ModelID=-1
	  AND MI.SolutionID IS NULL

--Configuration by solution	  
INSERT INTO #GM_ModelIndicators (SolutionID,ModelGroupID,ModelID,IndicatorLevelID,IndicatorID,DataTableID)
SELECT
	I.SolutionID,
	M.ModelGroupID,
	M.ModelID,
	I.IndicatorLevelID,
	I.IndicatorID,
	I.DataTableIDs
	FROM [dbo].[GM_F_ModelIndicators](nolock) I
	INNER JOIN [dbo].[GM_D_Models](nolock) M
	ON I.SolutionID=M.SolutionID
	LEFT JOIN #GM_ModelIndicators MI
	ON MI.SolutionID=I.SolutionID
	  AND MI.ModelGroupID=M.ModelGroupID
	  AND MI.ModelID=M.ModelID
	  AND MI.IndicatorLevelID=I.IndicatorLevelID
	  AND MI.IndicatorID=I.IndicatorID
	WHERE I.ModelGroupID=-1
	  AND I.ModelID=-1
	  AND MI.SolutionID IS NULL
	  
------------------------------
-- return all configurations
------------------------------
SELECT * FROM #GM_ModelIndicators
