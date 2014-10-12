
/****** Object:  PartitionScheme [UPS_SolutionID_PartitionScheme]    Script Date: 16/3/2013 5:09:46 PM ******/
IF EXISTS (SELECT * FROM sys.partition_schemes where name='UPS_SolutionID_PartitionScheme')
	DROP PARTITION SCHEME [UPS_SolutionID_PartitionScheme]
GO

/****** Object:  PartitionScheme [UPS_SolutionID_PartitionScheme]    Script Date: 16/3/2013 5:09:46 PM ******/
CREATE PARTITION SCHEME [UPS_SolutionID_PartitionScheme] AS PARTITION [UDF_SolutionID_PartitionFunction] TO ([SolutionID_FG1],[SolutionID_FG2],[SolutionID_FG3],[SolutionID_FG4],[SolutionID_FG5],[SolutionID_FG6],[SolutionID_FG7],[SolutionID_FG8],[SolutionID_FG9],[PRIMARY])
GO


