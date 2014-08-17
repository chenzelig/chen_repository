USE MFG_Solutions

-- solution=2
-- modelGroup=5
--model= 6,7
INSERT INTO [dbo].[GM_D_Solutions]
VALUES(2,'VM2F')

INSERT INTO [dbo].[GM_D_ModelGroups]
VALUES (1,5,'BDW')

INSERT INTO [dbo].[GM_D_Models] VALUES 
 (6,2,'ULT',1272,'All','All','',NULL,5,0,0,0)
,(7,2,'ULX',1272,'All','All','',NULL,5,0,0,0)

SELECT * FROM [GM_F_ModelingParameters]
order BY ParameterID

SELECT mp.*, p.ParameterDesc
FROM [dbo].[GM_F_ModelingParameters] mp
inner JOIN GM_D_Parameters p
on mp.ParameterID=p.ParameterID
order BY p.parameterid 

INSERT INTO [GM_F_ModelingParameters] --modelID=-1 since the data extraction is for all the models together
VALUES(2,5,-1,NULL,1,'???? needs to be written dynamicly according to the relevant lots and dffs
<Queries>
  <Row>
    <QueryNum>1</QueryNum>
	<ConnectionID></ConnectionID>
    <Query>
    </Query>	
  </Row>
  <Row>
	<QueryNum>2</QueryNum>
	<ConnectionID></ConnectionID>
	<Query>
	</Query>
  </Row>
</Queries>')
,(2,5,6,NULL,3,'USP_VM2F_BDW_ULT_DataPreparation') -- Data preparation Stored Procedure
,(2,5,7,NULL,3,'USP_VM2F_BDW_ULX_DataPreparation') -- Data preparation Stored Procedure
,(2,4,-1,NULL,4,'???') --Prepared Data Schema
,(2,5,6,NULL,5,'???') --Modeling Stored Procedure
,(2,5,7,NULL,5,'???') --Modeling Stored Procedure
,(2,5,-1,NULL,7,'????')--Raw Data Schema