USE [master]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG1]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_1', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_1.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG1]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG2]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_2', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_2.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG2]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG3]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_3', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_3.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG3]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG4]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_4', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_4.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG4]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG5]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_5', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_5.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG5]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG6]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_6', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_6.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG6]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG7]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_7', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_7.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG7]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG8]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_8', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_8.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG8]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG9]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_9', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_9.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG9]
GO
ALTER DATABASE [MFG_Solutions] ADD FILEGROUP [SolutionID_FG10]
GO
ALTER DATABASE [MFG_Solutions] ADD FILE ( NAME = N'MFG_10', FILENAME = N'F:\MSSQL11.SQL01\MSSQL\DATA\MFG_10.ndf' , SIZE = 51200KB , FILEGROWTH = 25%) TO FILEGROUP [SolutionID_FG10]
GO

