
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UDF_GM_GetFormulaString]') )
DROP function [dbo].[UDF_GM_GetFormulaString]
GO

/************************************************************************************************

COMMENTS HERE!!!
*************************************************************************************************/
CREATE function [dbo].[UDF_GM_GetFormulaString](@SolutionID int, @ModelID int)
RETURNS nvarchar(max)
as
  BEGIN
	DECLARE @NumCondition int= -1, @NumWeight int= -1, @MaxRemodelingTimestamp datetime, @rtnString varchar(max)
		
	SELECT @MaxRemodelingTimestamp = max(RemodelingTimestamp) FROM GM_R_Remodeling WHERE ModelID=@ModelID AND SolutionID=@SolutionID
	SELECT @NumCondition = count(*) FROM GM_R_Remodeling WHERE RemodelingTimestamp=@MaxRemodelingTimestamp AND ModelID=@ModelID AND SolutionID=@SolutionID AND SubmodelID<>0
	SELECT @NumWeight = count(*) FROM GM_R_Remodeling WHERE RemodelingTimestamp=@MaxRemodelingTimestamp AND ModelID=@ModelID AND SolutionID=@SolutionID AND SubmodelWeight is not null
	
	SET @rtnString = ''
	IF (@NumCondition = 0 AND @NumWeight = 0) BEGIN
		SELECT @rtnString = formula FROM GM_R_Remodeling where ModelID = @ModelID AND RemodelingTimestamp = @MaxRemodelingTimestamp
		return @rtnString
	END
	ELSE BEGIN
		IF (@NumCondition>0 and @NumWeight=0) BEGIN
			SET @rtnString = 'CASE '
			SELECT @rtnString = @rtnString + ' WHEN ' +SubmodelCondition+' THEN ' + formula from GM_R_Remodeling where RemodelingTimestamp=@MaxRemodelingTimestamp AND ModelID=@ModelID AND SolutionID=@SolutionID
			SELECT @rtnString = @rtnString + ' ELSE NULL END' 
			return @rtnString
		END
		ELSE BEGIN
			SELECT @rtnString = @rtnString + cast (SubmodelWeight as varchar(24)) + '* ( ' +formula+' ) +' from GM_R_Remodeling where RemodelingTimestamp=@MaxRemodelingTimestamp AND ModelID=@ModelID AND SolutionID=@SolutionID
			SET @rtnString = substring(@rtnString,1,len(@rtnString)-1)
			return @rtnString
		END
	END 
	return ' '
  END