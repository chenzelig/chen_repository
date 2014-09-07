USE MFG_Solutions
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_GM_AddDeleteStatement]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_GM_AddDeleteStatement]

GO

/*******************************************************           
* Procedure:		[USP_GM_AddDeleteStatement]  
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


CREATE PROCEDURE dbo.USP_GM_AddDeleteStatement @ModelID int = NULL, @DeleteStatement VARCHAR(max), @ReplaceCurrentStatement Bit=0

AS

DECLARE @SolutionID int, @ModelGroupID int


SELECT @SolutionID=SolutionID
FROM [dbo].[GM_D_Models]
WHERE ModelID=@ModelID

SELECT @ModelGroupID=ModelGroupID
FROM [dbo].[GM_D_Models]
WHERE ModelID=@ModelID

IF EXISTS (SELECT 1 FROM [dbo].[GM_F_ModelingParameters]
				WHERE ModelID=@ModelID AND ParameterID=19)
BEGIN
	IF @DeleteStatement is NULL
	BEGIN
		DELETE FROM [dbo].[GM_F_ModelingParameters]
		WHERE ModelID= @ModelID and ParameterID = 19
	END

	IF @ReplaceCurrentStatement=0
	BEGIN
		UPDATE A
		SET Value = REPLACE(Value,Value,Value+' AND '+@DeleteStatement)
		FROM [dbo].[GM_F_ModelingParameters] A
		WHERE ModelID=@ModelID AND ParameterID=19
	END

	ELSE
	BEGIN
		UPDATE A
		SET Value = @DeleteStatement
		FROM [dbo].[GM_F_ModelingParameters] A
		WHERE ModelID=@ModelID AND ParameterID=19
	END	
END

ELSE
BEGIN

if @DeleteStatement is not null
BEGIN
	INSERT INTO [dbo].[GM_F_ModelingParameters]( SolutionID, ModelGroupID, ModelID,ParameterID,		Value	)
										VALUES (@SolutionID,@ModelGroupID,@ModelID,		19	,	@DeleteStatement)
END

END