USE [MPDExploration]
GO

IF OBJECT_ID('[dbo].[UDF_VMIN_VLV_Calc_Steps_WP]') IS NOT NULL
	DROP FUNCTION [dbo].[UDF_VMIN_VLV_Calc_Steps_WP];
GO

CREATE FUNCTION [dbo].[UDF_VMIN_VLV_Calc_Steps_WP](
	@ActualValue		FLOAT,
	@PredictedValue		FLOAT,
	@LowSearchValue		FLOAT,
	@HighSearchValue	FLOAT,
	@Resolution			FLOAT
) RETURNS INT AS BEGIN

DECLARE @Factor FLOAT = 1 / @Resolution; -- Helper variable for rounding

-- Round down predicted value.
SET @PredictedValue = FLOOR(@Factor*@PredictedValue)/@Factor;

-- Predicted value out of range
IF @PredictedValue < @LowSearchValue OR @PredictedValue > @HighSearchValue BEGIN
	RETURN [dbo].[UDF_VMIN_VLV_Calc_Steps_NP](
		@ActualValue,
		@LowSearchValue,
		@HighSearchValue,
		@Resolution
	);
END

-- Overshoot, use @PredictedValue as new @HighSearchValue
IF @PredictedValue >= @ActualValue BEGIN
	RETURN [dbo].[UDF_VMIN_VLV_Calc_Steps_NP](
		@ActualValue,
		@LowSearchValue,
		@PredictedValue,
		@Resolution
	)
END


-- Linear search is done, +1 is for @HighSearchValue.
RETURN ROUND((@ActualValue - @PredictedValue)/@Resolution,0) + 1;


END
