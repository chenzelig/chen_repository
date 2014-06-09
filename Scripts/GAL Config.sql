INSERT INTO [dbo].[GAL_Engines]  (EngineName,IsDisabled,IsDisabledEmailNotifications,IsDisabledSMSNotifications,IsShadowing)
						VALUES	('MFG_Solutions', 0,		0,										0,				0		)

INSERT INTO [dbo].[GAL_LogEventObjects] (LogEventObjectName,IsDisabled,IsDisabledEmailNotifications,IsDisabledSMSNotifications,IsDisabledMeasures)
							VALUES		('USP_GM_MainProcedure', 0,					0,							0,						0		)




SELECT * FROM [dbo].[GAL_GenericLog_VW]
WHERE EngineName like '%MFG_Solution%'
order by 1 desc



exec [dbo].[USP_VM2F_ImportDataFromMIDAS] @sqlCommand='select top 100 [visual_id]
          ,[sort_lot]
          ,[sort_wafer_id] AS sort_wafer
          ,[sort_x]
          ,[sort_y]
          ,[6051_INTERFACE_BIN] AS Interface_Bin
          ,[6051_FUNCTIONAL_BIN] AS Functional_Bin
           ,''6051'' AS Operation
          ,[6051_FACILITY] AS Facility
          ,[6051_PROGRAM_NAME] AS TP
          ,[6051_DEVREVSTEP] AS DevRevStep
          ,[6051_WORKWEEK] AS WW
          ,[6051_UPDATE_DATE] AS LOTS_End_Date_Time
           ,''SORT'' AS SourceDomain
          ,LEFT([6051_PROGRAM_NAME],3) AS Product
          ,''A'' AS Segment    
from  [V_BM_POPAI_HSX_PHI_UNIT]
where [6051_UPDATE_DATE]>=(GetUTCDate()-40)',@password='b3563823-f1ae-40c6-b236-deaa478c873a' , @receiveTimeout=5000000, 
@module='iBI'
