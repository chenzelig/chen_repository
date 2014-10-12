USE [AdvancedBIsystem]
GO

/****** Object:  UserDefinedFunction [dbo].[UDF_GetIntTableFromList]    Script Date: 10/1/2014 10:05:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID (N'UDF_GetIntTableFromList', N'TF') IS NOT NULL
    DROP FUNCTION UDF_GetIntTableFromList;
GO

CREATE FUNCTION [dbo].[UDF_GetIntTableFromList] (@CommaSeperatedList varchar(max))  
RETURNS   
@Result TABLE   
(  
 Value INT  
)  
AS  
BEGIN  
 if (@CommaSeperatedList = '') return  
 if (@CommaSeperatedList is null) return   
 declare @TempResult TABLE (Value INT)  
 declare @id int  
 declare @place int  
 declare @current varchar(50)  
 set @place = 1  
  
 declare @PrevPlace int  
 set @Prevplace = 0  
  
  
 set @CommaSeperatedList = @CommaSeperatedList +','  
  
 while (@PrevPlace <len(@CommaSeperatedList) and @place>0)   
 begin  
  set @place= CHARINDEX ( ',' ,@CommaSeperatedList , @PrevPlace+1 )   
  select @current=substring (@CommaSeperatedList,@PrevPlace+1,@place-@PrevPlace-1)  
  IF UPPER(@current)='NULL' SET @current=NULL  
  set @id = (convert(int,@current))  
  insert into @TempResult values(@id)  
  select @PrevPlace = @place  
 end  
 insert into @Result  
 select distinct value from @TempResult  
 RETURN   
END  




GO


