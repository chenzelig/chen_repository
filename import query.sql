SELECT  MU.Assembled_Unit_Seq_Key	  ,
	              MT.Test_Name,
				  C.string_result Test_Result	  			  
FROM MDS_Lot_Oper_Testing_Session MLOTS
	            INNER JOIN MDS_Test_In_LOTS MT 
	                     ON   MT.LATO_Start_WW = MLOTS.LATO_Start_WW 
	                     AND MT.Lot = MLOTS.Lot
	                     AND MT.LOTS_Seq_Key = MLOTS.LOTS_Seq_Key 
	              INNER JOIN MDS_Unit_String_Test_Result C 
	                     ON MT.LATO_Start_WW = C.LATO_Start_WW 
	                     AND MT.Lot = C.Lot 
	                     AND MT.LOTS_Seq_Key = C.LOTS_Seq_Key 
	                     AND MT.Test_In_LOTS_Seq_Key = C.Test_In_LOTS_Seq_Key 
	              INNER JOIN MDS_Unit_Testing_Bins MU 
	                     ON MU.LATO_Start_WW = C.LATO_Start_WW 
	                     AND MU.Lot = MLOTS.Lot 
	                     AND MU.LOTS_Seq_Key = MLOTS.LOTS_Seq_Key 
	                     AND MU.Unit_Testing_Seq_Key = C.Unit_Testing_Seq_Key 
	                     AND MU.Substructure_ID = C.Substructure_ID 
	              INNER JOIN MDS_Unit_Testing MUT
	                     ON MUT.LATO_Start_WW = MU.LATO_Start_WW 
	                     AND MUT.Lot = MU.Lot 
	                     AND MUT.LOTS_Seq_Key = MU.LOTS_Seq_Key 
	                     AND MUT.Unit_Testing_Seq_Key = MU.Unit_Testing_Seq_Key 
WHERE 1=1
				  AND MLOTS.LATO_Valid_Flag = 'Y'
				  AND MLOTS.LOTS_Complete_Flag = 'Y'   
				  AND MU.LATO_Valid_Flag = 'Y'         
				  AND MU.Within_LOTS_Latest_Flag = 'Y'
		   --       AND MT.Test_Name IN (/*test list*/)  
	     --         AND MLOTS.Lot IN (/*lot list*/)
			--	  AND MLOTS.Program_Or_BI_Recipe_Name IN( /*ilter TestProgram*/)
				  AND MLOTS.Operation='6881'
				  AND MLOTS.LATO_Start_WW=(SELECT MAX(LATO_Start_WW) FROM MDS_Lot_Oper_Testing_Session)