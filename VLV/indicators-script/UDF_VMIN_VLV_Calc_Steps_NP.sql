USE [MPDExploration]
GO

IF OBJECT_ID('[dbo].[UDF_VMIN_VLV_Calc_Steps_WP]') IS NOT NULL
	DROP FUNCTION [dbo].[UDF_VMIN_VLV_Calc_Steps_WP];
GO
IF OBJECT_ID('[dbo].[UDF_VMIN_VLV_Calc_Steps_NP]') IS NOT NULL
	DROP FUNCTION [dbo].[UDF_VMIN_VLV_Calc_Steps_NP];
GO

CREATE FUNCTION [dbo].[UDF_VMIN_VLV_Calc_Steps_NP](
	@ActualValue		FLOAT,
	@LowSearchValue		FLOAT,
	@HighSearchValue	FLOAT,
	@Resolution			FLOAT
) RETURNS INT AS BEGIN

DECLARE @High INT = ROUND(@HighSearchValue / @Resolution, 0);
DECLARE @Low INT = ROUND(@LowSearchValue / @Resolution, 0);
DECLARE @Mid INT;
DECLARE @Actual INT = ROUND(@ActualValue / @Resolution, 0);

-- Minimum and maximum are always checked, so steps start from 2.
DECLARE @Steps INT = 2; 

IF @Actual <= @Low BEGIN
	-- A super awesome unit that works with minimum voltage, no search is done.
	RETURN @Steps;
END

WHILE @High - @Low > 1 BEGIN
	SET @Mid = (@Low + @High + 1) / 2;  -- (int)((a+b+1)/2) is eqivalent to ceiling((a+b)/2)

	SET @Steps = @Steps + 1;

	IF @Mid < @Actual BEGIN
		SET @Low = @Mid;
	END ELSE BEGIN
		SET @High = @Mid;
	END

	-- Safegaurd against infinite loops.
	IF @Steps > 100 BEGIN
		DECLARE @Error VARCHAR(MAX) = CONCAT(
			'Error, endless loop on input ',@ActualValue,', ',@LowSearchValue
			,', ',@HighSearchValue,', ',@Resolution);
		RETURN CAST(@Error AS INT);
	END
END

RETURN @Steps;

END
