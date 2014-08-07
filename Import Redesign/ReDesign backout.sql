

UPDATE A
SET Value = 
'<Queries>
  <Row>
    <QueryNum>1</QueryNum>
	<ConnectionID>1</ConnectionID>
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
	<ConnectionID>1</ConnectionID>
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
	<ConnectionID>1</ConnectionID>
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
	<ConnectionID>1</ConnectionID>
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
	   from [V_BM_POPAI_CHT_PHI_UNIT]
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
	<ConnectionID>1</ConnectionID>
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