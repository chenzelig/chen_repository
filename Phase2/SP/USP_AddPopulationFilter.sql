USE MFG_Solutions
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GM_AddPopulationFilter]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_GM_AddPopulationFilter]

GO

/*******************************************************           
* Procedure:		[USP_GM_AddPopulationFilter]  
*                                                              
* Description:		
* 
* ----------------------------------------------------------     
*                                                                    
* Modification Log:                                            
* Date			Modified By			Modification:                         
* ----			-----------			--------------------         
* 2014-7-21		Gil Ben Shalom		Creating the SP 
*******************************************************/ 


CREATE PROCEDURE dbo.USP_GM_AddPopulationFilter @ModelID int = NULL, @PopulationFilter VARCHAR(max)=NULL, @ReplaceCurrentFilter Bit=0

AS

DECLARE @SolutionID int, @ModelGroupID int

IF EXISTS (SELECT 1 FROM [dbo].[GM_F_ModelingParameters]
				WHERE ModelID=@ModelID AND ParameterID=19)
BEGIN
	IF @ReplaceCurrentFilter=0
	BEGIN
		UPDATE A
		SET Value = REPLACE(Value,Value,Value+' AND '+@PopulationFilter)
		FROM [dbo].[GM_F_ModelingParameters] A
		WHERE ModelID=@ModelID AND ParameterID=19
	END

	ELSE
	BEGIN
		UPDATE A
		SET Value = @PopulationFilter
		FROM [dbo].[GM_F_ModelingParameters] A
		WHERE ModelID=@ModelID AND ParameterID=19
	END	
END

ELSE
BEGIN

	SELECT @SolutionID=SolutionID
	FROM [dbo].[GM_D_Models]
	WHERE ModelID=@ModelID

	SELECT @ModelGroupID=ModelGroupID
	FROM [dbo].[GM_D_Models]
	WHERE ModelID=@ModelID

	INSERT INTO [dbo].[GM_F_ModelingParameters]( SolutionID, ModelGroupID, ModelID,ParameterID,		Value	)
										VALUES (@SolutionID,@ModelGroupID,@ModelID,		19	,	@PopulationFilter)

END