USE [MFG_Solutions]
GO

/****** Object:  UserDefinedFunction [dbo].[UDF_GetStringTableFromList_New]    Script Date: 9/30/2014 12:58:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID (N'UDF_GetStringTableFromList_New', N'TF') IS NOT NULL
    DROP FUNCTION UDF_GetStringTableFromList_New;
GO


 
create FUNCTION [dbo].[UDF_GetStringTableFromList_New] (@CommaSeperatedList varchar(max),@Del char(1)=',',@Index INT=NULL)  
RETURNS   
@Result TABLE   
(  
 Value VARCHAR(255)  ,place INT
)  
AS  
BEGIN   
IF (@CommaSeperatedList is null) RETURN   
DECLARE @TempResult TABLE (Value VARCHAR(255),place INT)  
DECLARE @name VARCHAR(255)  ,@place INT =1, @PrevPlace INT  =0,@Ind INT=1
SET @CommaSeperatedList = @CommaSeperatedList +@Del
  
WHILE (@PrevPlace <LEN(@CommaSeperatedList) AND @place>0)   
BEGIN  
	SET @place= CHARINDEX ( @Del ,@CommaSeperatedList , @PrevPlace+1 )  
	SELECT @name=SUBSTRING (@CommaSeperatedList,@PrevPlace+1,@place-@PrevPlace-1)  
	INSERT INTO @TempResult values(LTRIM(RTRIM(@name)),@Ind)  
	IF @Index=@Ind 
		BREAK
	SELECT @PrevPlace = @place  ,@Ind=@Ind+1

END  
INSERT INTO @Result SELECT * FROM @TempResult WHERE ISNULL(@Index,place)=place ORDER BY place
RETURN
END  



GO


