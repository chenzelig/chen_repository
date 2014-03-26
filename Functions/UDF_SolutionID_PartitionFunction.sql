
/****** Object:  PartitionFunction [UDF_SolutionID_PartitionFunction]    Script Date: 16/3/2013 5:10:50 PM ******/
IF EXISTS (SELECT * FROM sys.partition_functions where name='UDF_SolutionID_PartitionFunction')
	DROP PARTITION FUNCTION [UDF_SolutionID_PartitionFunction]
GO

/****** Object:  PartitionFunction [UDF_SolutionID_PartitionFunction]    Script Date: 16/3/2013 5:10:50 PM ******/
CREATE PARTITION FUNCTION [UDF_SolutionID_PartitionFunction](int) AS RANGE RIGHT FOR VALUES (1,2,3,4,5,6,7,8,9)
GO


