-----------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------Linked Server--------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

USE [master]
GO

/****** Object:  LinkedServer [LNK_DAAS_INTERNAL_IBI-DAAS]    Script Date: 7/30/2014 4:19:57 PM ******/
IF EXISTS (SELECT 1 FROM sysservers WHERE SRVNAME = 'LNK_DAAS_INTERNAL_IBI-DAAS')
EXEC master.dbo.sp_dropserver @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [LNK_DAAS_INTERNAL_IBI-DAAS]    Script Date: 7/30/2014 4:19:57 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'LNK_DAAS_INTERNAL_IBI-DAAS', @srvproduct=N'iBI DaaS', @provider=N'MSDASQL', @datasrc=N'iBI DaaS;host=ibi-services.intel.com;port=9999;'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LNK_DAAS_INTERNAL_IBI-DAAS',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL

GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO



-----------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------Connection-----------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
USE MFG_Solutions

GO

DELETE FROM [dbo].[GM_D_DE_Connections]
WHERE ConnectionID = 2

INSERT INTO [dbo].[GM_D_DE_Connections] (ConnectionID,ConnectionDesc,ConnectionTypeID,					ConnectionString,					SourceType)
								VALUES	(		2,		'iBI OpenRowSet',		1,		'Driver={iBI DaaS}; Server=ibi-services.intel.com,9999;','MSDASQL')

IF NOT EXISTS (SELECT 1 FROM [dbo].[GM_D_DE_ConnectionTypes] WHERE ConnectionTypeID =3)
insert into [dbo].[GM_D_DE_ConnectionTypes] (ConnectionTypeID,ConnectionTypeDesc,ConnectionAttributes)
									VALUES(			3,		'Linked Server',	'ConnectionString')

IF NOT EXISTS(SELECT 1 FROM [dbo].[GM_D_DE_Connections] WHERE ConnectionID = 3)
INSERT INTO [dbo].[GM_D_DE_Connections] (ConnectionID,ConnectionDesc,ConnectionTypeID,			ConnectionString	)
								VALUES	(		3,	'iBI LinkedServer',		3,		'[LNK_DAAS_INTERNAL_IBI-DAAS]')


UPDATE A
SET Value = 
'<Queries>
  <Row>
    <QueryNum>1</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
      select [visual_id],
      [sort_lot],
      [sort_wafer_id] AS sort_wafer,
      [sort_x],
      [sort_y],
      [6051_INTERFACE_BIN] AS Interface_Bin,
      [6051_FUNCTIONAL_BIN] AS Functional_Bin,
      ''6051'' AS Operation,
      [6051_FACILITY] AS Facility,
      [6051_PROGRAM_NAME] AS TP,
      [6051_DEVREVSTEP] AS DevRevStep,
      [6051_WORKWEEK] AS WW,
      [6051_UPDATE_DATE] AS LOTS_End_Date_Time,
      ''SORT'' AS SourceDomain,
      LEFT([6051_PROGRAM_NAME],3) AS Product,
      CONVERT(varchar(15),NULL) AS Segment,
      SUBSTRING([6051_PROGRAM_NAME],8,1) AS DieStructure,
      CONVERT(varchar(10),NULL) AS Package,
      SUBSTRING([6051_PROGRAM_NAME],8,2) AS Step
      from  [V_BM_POPAI_HSX_PHI_UNIT]
      where [6051_UPDATE_DATE]>=(GetUTCDate()-40)
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>40</NumDistributionGroups>
  </Row>
  <Row>
    <QueryNum>2</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
      select [visual_id],
      [sort_lot],
      [sort_wafer_id] AS sort_wafer,
      [sort_x],
      [sort_y],
      [7721_INTERFACE_BIN] AS Interface_Bin,
      [7721_FUNCTIONAL_BIN] AS Functional_Bin,
      ''7721'' AS Operation,
      [7721_FACILITY] AS Facility,
      [7721_PROGRAM_NAME] AS TP,
      [7721_DEVREVSTEP] AS DevRevStep,
      [7721_WORKWEEK] AS WW,
      [7721_UPDATE_DATE] AS LOTS_End_Date_Time,
      ''CLASS'' AS SourceDomain,
      LEFT([7721_PROGRAM_NAME],3) AS Product,
      CONVERT(varchar(15),NULL) AS Segment,
      SUBSTRING([7721_PROGRAM_NAME],8,1) AS DieStructure,
      SUBSTRING([7721_PROGRAM_NAME],4,2) AS Package,
      SUBSTRING([7721_PROGRAM_NAME],8,2) AS Step
      from  [V_BM_POPAI_HSX_PHI_UNIT]
      where [7721_UPDATE_DATE]>=(GetUTCDate()-40)
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>40</NumDistributionGroups>
  </Row>
</Queries>' FROM [dbo].[GM_F_ModelingParameters] A
WHERE ModelGroupID=1 and ParameterID=1


UPDATE A
SET Value = 
'<Queries>
  <Row>
    <QueryNum>1</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
	   select [visual_id],
	   [sort_lot],
	   [sort_wafer_id] AS sort_wafer,
	   [sort_x],
	   [sort_y],
	   [6051_INTERFACE_BIN] AS Interface_Bin,
	   [6051_FUNCTIONAL_BIN] AS Functional_Bin,
	   ''6051'' AS Operation,
	   [6051_FACILITY] AS Facility,
	   [6051_PROGRAM_NAME] AS TP,
	   [6051_DEVREVSTEP] AS DevRevStep,
	   [6051_WORKWEEK] AS WW,
	   [6051_UPDATE_DATE] AS LOTS_End_Date_Time,
	   ''SORT'' AS SourceDomain,
	   LEFT([6051_PROGRAM_NAME],3) AS Product,
	   CONVERT(varchar(15),NULL) AS Segment,
	   CONVERT(varchar(15),NULL) AS DieStructure,
	   CONVERT(varchar(10),NULL) AS Package,
	   SUBSTRING([6051_PROGRAM_NAME],8,2) AS Step
	   from  [V_BM_POPAI_CHT_PHI_UNIT]
	   where [6051_UPDATE_DATE]>=(GetUTCDate()-40)
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>15</NumDistributionGroups>
  </Row>
  <Row>
    <QueryNum>2</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
       select [visual_id],
	   [sort_lot],
	   [sort_wafer_id] AS sort_wafer,
	   [sort_x],
	   [sort_y],
	   [6262_INTERFACE_BIN] AS Interface_Bin,
	   [6262_FUNCTIONAL_BIN] AS Functional_Bin,
	   ''6262'' AS Operation,
	   [6262_FACILITY] AS Facility,
	   [6262_PROGRAM_NAME] AS TP,
	   [6262_DEVREVSTEP] AS DevRevStep,
	   [6262_WORKWEEK] AS WW,
	   [6262_UPDATE_DATE] AS LOTS_End_Date_Time,
	   ''CLASS'' AS SourceDomain,
	   LEFT([6262_PROGRAM_NAME],3) AS Product,
	   SUBSTRING([6262_PROGRAM_NAME],4,2) AS Segment,
	   CONVERT(varchar(15),NULL) AS DieStructure,
	   SUBSTRING([6262_PROGRAM_NAME],6,2) AS Package,
	   SUBSTRING([6262_PROGRAM_NAME],8,2) AS Step
	   from  [V_BM_POPAI_CHT_PHI_UNIT]
       where [6262_UPDATE_DATE]>=(GetUTCDate()-40)
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>15</NumDistributionGroups>
  </Row>
</Queries>' FROM [dbo].[GM_F_ModelingParameters] A
WHERE ModelGroupID=2 and ParameterID=1


UPDATE A
SET Value = 
'<Queries>
  <Row>
    <QueryNum>1</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
		SELECT CONVERT(varchar(50),NULL) AS [visual_id],
		[sort_lot],
		[sort_wafer_id] AS sort_wafer,
		[sort_x],
		[sort_y],
		[7721_INTERFACE_BIN] AS Interface_Bin,
		[7721_FUNCTIONAL_BIN] AS Functional_Bin,
		''7721'' AS Operation,-----------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------Linked Server--------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------

USE [master]
GO

/****** Object:  LinkedServer [LNK_DAAS_INTERNAL_IBI-DAAS]    Script Date: 7/30/2014 4:19:57 PM ******/
IF EXISTS (SELECT 1 FROM sysservers WHERE SRVNAME = 'LNK_DAAS_INTERNAL_IBI-DAAS')
EXEC master.dbo.sp_dropserver @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @droplogins='droplogins'
GO

/****** Object:  LinkedServer [LNK_DAAS_INTERNAL_IBI-DAAS]    Script Date: 7/30/2014 4:19:57 PM ******/
EXEC master.dbo.sp_addlinkedserver @server = N'LNK_DAAS_INTERNAL_IBI-DAAS', @srvproduct=N'iBI DaaS', @provider=N'MSDASQL', @datasrc=N'iBI DaaS;host=ibi-services.intel.com;port=9999;'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'LNK_DAAS_INTERNAL_IBI-DAAS',@useself=N'True',@locallogin=NULL,@rmtuser=NULL,@rmtpassword=NULL

GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'LNK_DAAS_INTERNAL_IBI-DAAS', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO



-----------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------Connection-----------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
USE MFG_Solutions

GO

DELETE FROM [dbo].[GM_D_DE_Connections]
WHERE ConnectionID = 2

INSERT INTO [dbo].[GM_D_DE_Connections] (ConnectionID,ConnectionDesc,ConnectionTypeID,					ConnectionString,					SourceType)
								VALUES	(		2,		'iBI OpenRowSet',		1,		'Driver={iBI DaaS}; Server=ibi-services.intel.com,9999;','MSDASQL')

IF NOT EXISTS (SELECT 1 FROM [dbo].[GM_D_DE_ConnectionTypes] WHERE ConnectionTypeID =3)
insert into [dbo].[GM_D_DE_ConnectionTypes] (ConnectionTypeID,ConnectionTypeDesc,ConnectionAttributes)
									VALUES(			3,		'Linked Server',	'ConnectionString')

IF NOT EXISTS(SELECT 1 FROM [dbo].[GM_D_DE_Connections] WHERE ConnectionID = 3)
INSERT INTO [dbo].[GM_D_DE_Connections] (ConnectionID,ConnectionDesc,ConnectionTypeID,			ConnectionString	)
								VALUES	(		3,	'iBI LinkedServer',		3,		'[LNK_DAAS_INTERNAL_IBI-DAAS]')


UPDATE A
SET Value = 
'<Queries>
  <Row>
    <QueryNum>1</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
      select [visual_id],
      [sort_lot],
      [sort_wafer_id] AS sort_wafer,
      [sort_x],
      [sort_y],
      [6051_INTERFACE_BIN] AS Interface_Bin,
      [6051_FUNCTIONAL_BIN] AS Functional_Bin,
      ''6051'' AS Operation,
      [6051_FACILITY] AS Facility,
      [6051_PROGRAM_NAME] AS TP,
      [6051_DEVREVSTEP] AS DevRevStep,
      [6051_WORKWEEK] AS WW,
      [6051_UPDATE_DATE] AS LOTS_End_Date_Time,
      ''SORT'' AS SourceDomain,
      LEFT([6051_PROGRAM_NAME],3) AS Product,
      CONVERT(varchar(15),NULL) AS Segment,
      SUBSTRING([6051_PROGRAM_NAME],8,1) AS DieStructure,
      CONVERT(varchar(10),NULL) AS Package,
      SUBSTRING([6051_PROGRAM_NAME],8,2) AS Step
      from  [V_BM_POPAI_HSX_PHI_UNIT]
      where [6051_UPDATE_DATE]>=(GetUTCDate()-40)
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>40</NumDistributionGroups>
  </Row>
  <Row>
    <QueryNum>2</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
      select [visual_id],
      [sort_lot],
      [sort_wafer_id] AS sort_wafer,
      [sort_x],
      [sort_y],
      [7721_INTERFACE_BIN] AS Interface_Bin,
      [7721_FUNCTIONAL_BIN] AS Functional_Bin,
      ''7721'' AS Operation,
      [7721_FACILITY] AS Facility,
      [7721_PROGRAM_NAME] AS TP,
      [7721_DEVREVSTEP] AS DevRevStep,
      [7721_WORKWEEK] AS WW,
      [7721_UPDATE_DATE] AS LOTS_End_Date_Time,
      ''CLASS'' AS SourceDomain,
      LEFT([7721_PROGRAM_NAME],3) AS Product,
      CONVERT(varchar(15),NULL) AS Segment,
      SUBSTRING([7721_PROGRAM_NAME],8,1) AS DieStructure,
      SUBSTRING([7721_PROGRAM_NAME],4,2) AS Package,
      SUBSTRING([7721_PROGRAM_NAME],8,2) AS Step
      from  [V_BM_POPAI_HSX_PHI_UNIT]
      where [7721_UPDATE_DATE]>=(GetUTCDate()-40)
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>40</NumDistributionGroups>
  </Row>
</Queries>' FROM [dbo].[GM_F_ModelingParameters] A
WHERE ModelGroupID=1 and ParameterID=1


UPDATE A
SET Value = 
'<Queries>
  <Row>
    <QueryNum>1</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
	   select [visual_id],
	   [sort_lot],
	   [sort_wafer_id] AS sort_wafer,
	   [sort_x],
	   [sort_y],
	   [6051_INTERFACE_BIN] AS Interface_Bin,
	   [6051_FUNCTIONAL_BIN] AS Functional_Bin,
	   ''6051'' AS Operation,
	   [6051_FACILITY] AS Facility,
	   [6051_PROGRAM_NAME] AS TP,
	   [6051_DEVREVSTEP] AS DevRevStep,
	   [6051_WORKWEEK] AS WW,
	   [6051_UPDATE_DATE] AS LOTS_End_Date_Time,
	   ''SORT'' AS SourceDomain,
	   LEFT([6051_PROGRAM_NAME],3) AS Product,
	   CONVERT(varchar(15),NULL) AS Segment,
	   CONVERT(varchar(15),NULL) AS DieStructure,
	   CONVERT(varchar(10),NULL) AS Package,
	   SUBSTRING([6051_PROGRAM_NAME],8,2) AS Step
	   from  [V_BM_POPAI_CHT_PHI_UNIT]
	   where [6051_UPDATE_DATE]>=(GetUTCDate()-40)
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>15</NumDistributionGroups>
  </Row>
  <Row>
    <QueryNum>2</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
       select [visual_id],
	   [sort_lot],
	   [sort_wafer_id] AS sort_wafer,
	   [sort_x],
	   [sort_y],
	   [6262_INTERFACE_BIN] AS Interface_Bin,
	   [6262_FUNCTIONAL_BIN] AS Functional_Bin,
	   ''6262'' AS Operation,
	   [6262_FACILITY] AS Facility,
	   [6262_PROGRAM_NAME] AS TP,
	   [6262_DEVREVSTEP] AS DevRevStep,
	   [6262_WORKWEEK] AS WW,
	   [6262_UPDATE_DATE] AS LOTS_End_Date_Time,
	   ''CLASS'' AS SourceDomain,
	   LEFT([6262_PROGRAM_NAME],3) AS Product,
	   SUBSTRING([6262_PROGRAM_NAME],4,2) AS Segment,
	   CONVERT(varchar(15),NULL) AS DieStructure,
	   SUBSTRING([6262_PROGRAM_NAME],6,2) AS Package,
	   SUBSTRING([6262_PROGRAM_NAME],8,2) AS Step
	   from  [V_BM_POPAI_CHT_PHI_UNIT]
       where [6262_UPDATE_DATE]>=(GetUTCDate()-40)
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>15</NumDistributionGroups>
  </Row>
</Queries>' FROM [dbo].[GM_F_ModelingParameters] A
WHERE ModelGroupID=2 and ParameterID=1


UPDATE A
SET Value = 
'<Queries>
  <Row>
    <QueryNum>1</QueryNum>
	<ConnectionID>3</ConnectionID>
    <Query>
		SELECT CONVERT(varchar(50),NULL) AS [visual_id],
		[sort_lot],
		[sort_wafer_id] AS sort_wafer,
		[sort_x],
		[sort_y],
		[7721_INTERFACE_BIN] AS Interface_Bin,
		[7721_FUNCTIONAL_BIN] AS Functional_Bin,
		''7721'' AS Operation,
		[7721_FACILITY] AS Facility,
		[7721_PROGRAM_NAME] AS TP,
		[7721_DEVREVSTEP] AS DevRevStep,
		[7721_WORKWEEK] AS WW,
		[7721_UPDATE_DATE] AS LOTS_End_Date_Time,
		''CLASS'' AS SourceDomain,
		LEFT([7721_PROGRAM_NAME],3) AS Product,
		CONVERT(varchar(50),NULL) AS Segment,
		CONVERT(varchar(50),NULL) AS DieStructure,
		CONVERT(varchar(50),NULL) as Package,
		CONVERT(varchar(50),NULL) AS Step
		FROM [V_BM_POPAI_SKL_UNIT_LEVEL_SOURCE]
		WHERE [7721_UPDATE_DATE]>=(GetUTCDate()-40)
		AND [7721_INTERFACE_BIN] IS NOT NULL
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>40</NumDistributionGroups>
  </Row>
</Queries>' FROM [dbo].[GM_F_ModelingParameters] A
WHERE ModelGroupID=3 and ParameterID=1
		[7721_FACILITY] AS Facility,
		[7721_PROGRAM_NAME] AS TP,
		[7721_DEVREVSTEP] AS DevRevStep,
		[7721_WORKWEEK] AS WW,
		[7721_UPDATE_DATE] AS LOTS_End_Date_Time,
		''CLASS'' AS SourceDomain,
		LEFT([7721_PROGRAM_NAME],3) AS Product,
		CONVERT(varchar(50),NULL) AS Segment,
		CONVERT(varchar(50),NULL) AS DieStructure,
		CONVERT(varchar(50),NULL) as Package,
		CONVERT(varchar(50),NULL) AS Step
		FROM [V_BM_POPAI_SKL_UNIT_LEVEL_SOURCE]
		WHERE [7721_UPDATE_DATE]>=(GetUTCDate()-40)
		AND [7721_INTERFACE_BIN] IS NOT NULL
    </Query>
	<DistributionField>DATEDIFF(GetUTCDate(),LOTS_End_Date_Time,day)</DistributionField>
	<NumDistributionGroups>40</NumDistributionGroups>
  </Row>
</Queries>' FROM [dbo].[GM_F_ModelingParameters] A
WHERE ModelGroupID=3 and ParameterID=1