SELECT  
			MUTB.Assembled_Unit_Seq_Key,      			  
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
	              INNER JOIN MDS_Unit_Testing_Bins MUTB 
	                     ON MUTB.LATO_Start_WW = C.LATO_Start_WW 
	                     AND MUTB.Lot = MLOTS.Lot 
	                     AND MUTB.LOTS_Seq_Key = MLOTS.LOTS_Seq_Key 
	                     AND MUTB.Unit_Testing_Seq_Key = C.Unit_Testing_Seq_Key 
	                     AND MUTB.Substructure_ID = C.Substructure_ID 
	              INNER JOIN MDS_Unit_Testing MUT
	                     ON MUT.LATO_Start_WW = MUTB.LATO_Start_WW 
	                     AND MUT.Lot = MUTB.Lot 
	                     AND MUT.LOTS_Seq_Key = MUTB.LOTS_Seq_Key 
	                     AND MUT.Unit_Testing_Seq_Key = MUTB.Unit_Testing_Seq_Key 
				  INNER JOIN (SELECT Program_Or_BI_Recipe_Name 
				  			  FROM MDS_Lot_Oper_Testing_Session
				  			  WHERE 1=1
				  			  AND <<Program_Or_BI_Recipe_Name>>
				  			  AND <<Operation>>
				  			  GROUP BY Program_Or_BI_Recipe_Name
				  			  HAVING <<SumTested>>) Res1
						 ON Res1.Program_Or_BI_Recipe_Name=MLOTS.Program_Or_BI_Recipe_Name
WHERE 1=1
				  AND <<MLOTS_LATO_Valid_Flag>>
				  AND <<MLOTS_LOTS_Complete_Flag>>  
				  AND <<MUTB_LATO_Valid_Flag>>        
				  AND <<MUTB_Within_LOTS_Latest_Flag>>

		          AND <<Temperture>>
				  AND <<Summary_Letter>>
				  AND <<Operation>>
				  AND <<SubStructure_ID>> 
				  AND <<Test_Name>>
				  