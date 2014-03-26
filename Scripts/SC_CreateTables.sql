---------------------------------------------------------
-----------------------DROP TABLES-----------------------
---------------------------------------------------------
DROP TABLE R_ATM_GM_ModelIndicatorValues
DROP TABLE R_ATM_GM_IndicatorLevelInstances --?
DROP TABLE D_ATM_GM_IndicatorLevels
DROP TABLE F_ATM_GM_ModelIndicators
DROP TABLE D_ATM_GM_Indicators
DROP TABLE R_ATM_GM_ModelEvaluationResults
DROP TABLE F_ATM_GM_ModelEvaluation
DROP TABLE D_ATM_GM_EvaluationMeasures
DROP TABLE D_ATM_GM_DE_DataSource
DROP TABLE D_ATM_GM_DE_Connections
DROP TABLE R_ATM_GM_Remodeling
DROP TABLE F_ATM_GM_ModelingParameters
DROP TABLE F_ATM_GM_ModelingFeatures
DROP TABLE D_ATM_GM_Models
DROP TABLE D_ATM_GM_ModelGroups
DROP TABLE D_ATM_GM_Features
DROP TABLE D_ATM_GM_Parameters
DROP TABLE D_ATM_GM_Solutions

--------------------------------------------------------------------------------------------
-----------------------------------------Modeling Tables------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE D_ATM_GM_Solutions (
SolutionID int NOT NULL PRIMARY KEY,
SolutionDescription varchar(500) NOT NULL
)

CREATE TABLE D_ATM_GM_Parameters (
ParameterID int NOT NULL PRIMARY KEY,
ParameterDesc varchar(500) NOT NULL,
DefaultValue varchar(500) NOT NULL
)

CREATE TABLE D_ATM_GM_Features (
FeatureID int NOT NULL,
SolutionID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Solutions(SolutionID),
Test_Name varchar(250) NOT NULL,
Operation varchar(50) NOT NULL,
SourceTable varchar(250) NOT NULL,
Categorizing_Value varchar(16) NOT NULL, ----------CHECK DATATYPE!!!
Distinctive_Value float NOT NULL,
XMLTestCaption xml NOT NULL
CONSTRAINT PK_ATM_GM_Features PRIMARY KEY (FeatureID,SolutionID)
) ON UPS_SolutionID_PartitionScheme(SolutionID)

CREATE TABLE D_ATM_GM_ModelGroups (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
ModelGroupDescription varchar(500) NOT NULL,
PreStep varchar(max) NULL  ----------CHECK DATATYPE!!!
CONSTRAINT PK_ATM_GM_ModelGroups PRIMARY KEY (SolutionID,ModelGroupID)
) ON UPS_SolutionID_PartitionScheme(SolutionID)

CREATE TABLE D_ATM_GM_Models (
ModelID int identity(1,1) NOT NULL,
SolutionID int NOT NULL,
Product varchar(10) NOT NULL,  ----------CHECK DATATYPE!!!
Operation varchar(50) NOT NULL,
DieStructure varchar(250) NOT NULL, ----------CHECK DATATYPE!!!
Package varchar(10) NOT NULL, ----------CHECK DATATYPE!!!
[Version/Specification] varchar(50) NOT NULL, ----------CHECK DATATYPE!!!
GenericColumn varchar(250) NOT NULL, ----------CHECK DATATYPE!!!
ModelGroupID int NOT NULL,
IsBackground BIT DEFAULT 0, -----------TO CHECK!!!
IsProduction BIT DEFAULT 0,
IsIndicators BIT DEFAULT 0
 CONSTRAINT PK_ATM_GM_Models PRIMARY KEY (ModelID,SolutionID)
) ON UPS_SolutionID_PartitionScheme(SolutionID)

ALTER Table ATM_GM_Models
ADD  CONSTRAINT FK_ATM_GM_Models FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES ATM_GM_ModelGroups(SolutionID,ModelGroupID)

CREATE TABLE F_ATM_GM_ModelingFeatures (
ModelID int NOT NULL, --FOREIGN KEY REFERENCES ATM_GM_Models(ModelID),
SolutionID int NOT NULL,
FeatureID int NOT NULL,-- FOREIGN KEY REFERENCES ATM_GM_Features(FeatureID),
UpdateTimestamp datetime NOT NULL,
IsActive BIT DEFAULT 1, ---------TO CHECK!
CONSTRAINT pk_ATM_GM_ModelingFeatures PRIMARY KEY (ModelID,FeatureID)
)

ALTER TABLE ATM_GM_ModelingFeatures
ADD CONSTRAINT FK_ATM_GM_ModelingFeatures_1 FOREIGN KEY (ModelID,SolutionID) REFERENCES ATM_GM_Models (ModelID,SolutionID)

ALTER TABLE ATM_GM_ModelingFeatures
ADD CONSTRAINT FK_ATM_GM_ModelingFeatures_2 FOREIGN KEY (FeatureID,SolutionID) REFERENCES ATM_GM_Features (FeatureID,SolutionID)

CREATE TABLE F_ATM_GM_ModelingParameters ( -------To Check in Easy - domain level settings
SolutionID int NOT NULL, --Change foreign keys!!
ModelGroupID int NOT NULL,
ModelID int NOT NULL,-- FOREIGN KEY REFERENCES ATM_GM_Models(ModelID),
FeatureID int NULL,-- FOREIGN KEY REFERENCES ATM_GM_Features(FeatureID),
ParameterID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Parameters(ParameterID),
Value float NOT NULL,
CONSTRAINT pk_ATM_GM_ModelingParameters PRIMARY KEY (SolutionID,ModelGroupID,ModelID,ParameterID) ---Cannot define PRIMARY KEY constraint on nullable column FeatureID
)

ALTER Table ATM_GM_ModelingParameters
ADD  CONSTRAINT FK_ATM_GM_ModelingParameters FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES ATM_GM_ModelGroups(SolutionID,ModelGroupID)

ALTER TABLE ATM_GM_ModelingParameters
ADD CONSTRAINT FK_ATM_GM_ModelingParameters_1 FOREIGN KEY (ModelID,SolutionID) REFERENCES ATM_GM_Models (ModelID,SolutionID)

ALTER TABLE ATM_GM_ModelingParameters
ADD CONSTRAINT FK_ATM_GM_ModelingParameters_2 FOREIGN KEY (FeatureID,SolutionID) REFERENCES ATM_GM_Features (FeatureID,SolutionID)

CREATE TABLE R_ATM_GM_Remodeling (
ModelID int NOT NULL,
SolutionID int NOT NULL,-- FOREIGN KEY REFERENCES ATM_GM_Models(ModelID),
RemodelingTimestamp datetime NOT NULL,
SubmodelID int DEFAULT 0, ----------TO CHECK!!!
SubmodelCondition varchar(250) NULL, ---------CHECK DATADYPE!!!
SubmodelWeight float NULL,
Formula varchar(max) NOT NULL,
CONSTRAINT pk_ATM_GM_Remodeling PRIMARY KEY (ModelID,SolutionID,RemodelingTimestamp,SubmodelID)
)

ALTER TABLE ATM_GM_Remodeling
ADD CONSTRAINT FK_ATM_GM_Remodeling FOREIGN KEY (ModelID,SolutionID) REFERENCES ATM_GM_Models


--------------------------------------------------------------------------------------------
-----------------------------------------Data Extraction------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE D_ATM_GM_DE_Connections (
ConnectionID int NOT NULL PRIMARY KEY,
ConnectionDesc varchar(500) NOT NULL,
Provider varchar(50) NOT NULL,
ConnectionString varchar(1000) NOT NULL -----ASK ERAN OR DAVID!!!!
)

CREATE TABLE D_ATM_GM_DE_DataSource (
DataSourceID int NOT NULL PRIMARY KEY,
DataSourceDesc varchar(500) NOT NULL,
ConnectionID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_DE_Connections(ConnectionID),
QueryTemplate varchar(max) NULL
)

--------------------------------------------------------------------------------------------
-----------------------------------------Evaluation-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE D_ATM_GM_EvaluationMeasures (
EvaluationMeasureID int IDENTITY(1,1) PRIMARY KEY, ---add identity coulmn
EvaluationMeasureName varchar(250) NOT NULL,
EvaluationDefinition varchar(max) NOT NULL
)

CREATE TABLE F_ATM_GM_ModelEvaluation (
SolutionID int NOT NULL, --------FIX THE FOREIGN KEYS (to model groups)
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
EvaluationMeasureID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_EvaluationMeasures (EvaluationMeasureID),
CONSTRAINT pk_ATM_GM_ModelEvaluation PRIMARY KEY (SolutionID,ModelGroupID,ModelID,EvaluationMeasureID)
)

ALTER Table ATM_GM_ModelEvaluation
ADD  CONSTRAINT FK_ATM_GM_ModelEvaluation FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES ATM_GM_ModelGroups(SolutionID,ModelGroupID)

ALTER Table ATM_GM_ModelEvaluation
ADD  CONSTRAINT FK_ATM_GM_ModelEvaluation2 FOREIGN KEY (ModelID,SolutionID) REFERENCES ATM_GM_Models(ModelID,SolutionID)

CREATE TABLE R_ATM_GM_ModelEvaluationResults (
ModelID int NOT NULL,
SolutionID int NOT NULL,
RemodelingTimestamp datetime NOT NULL, --add timestamp as a foreign key to remodeling if possible
Dataset varchar(250) NOT NULL,
EvaluationMeasureID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_EvaluationMeasures (EvaluationMeasureID),
Value float NOT NULL,
CONSTRAINT pk_ATM_GM_ModelEvaluationResults PRIMARY KEY (ModelID,SolutionID,RemodelingTimestamp,Dataset,EvaluationMeasureID)
)

ALTER Table ATM_GM_ModelEvaluationResults
ADD  CONSTRAINT FK_ATM_GM_ModelEvaluationResults FOREIGN KEY (ModelID,SolutionID) REFERENCES ATM_GM_Models(ModelID,SolutionID)

--ALTER Table ATM_GM_ModelEvaluationResults
--ADD  CONSTRAINT FK_ATM_GM_ModelEvaluationResults FOREIGN KEY (ModelID,RemodelingTimestamp) REFERENCES ATM_GM_Remodeling(ModelID,RemodelingTimestamp) ------Check if it works! Not worling, ask Itamar what to do 

--------------------------------------------------------------------------------------------
-----------------------------------------Indicators-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE D_ATM_GM_Indicators (
IndicatorID int NOT NULL PRIMARY KEY,
IndicatorName varchar(50) NOT NULL,
IndicatorDefinition varchar(1000) NOT NULL,
IndicatorCaption varchar(100) NOT NULL
)

CREATE TABLE F_ATM_GM_ModelIndicators (
SolutionID int NOT NULL, --Goes together
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
IndicatorLevelID int NOT NULL,--same as in easy (?)
IndicatorID int NOT NULL,
CONSTRAINT PK_ATM_GM_ModelIndicators PRIMARY KEY(SolutionID,ModelGroupID,ModelID,IndicatorLevelID,IndicatorID)
)

ALTER Table ATM_GM_ModelIndicators
ADD CONSTRAINT FK_ATM_GM_ModelIndicators FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES ATM_GM_ModelGroups(SolutionID,ModelGroupID)

CREATE TABLE D_ATM_GM_IndicatorLevels (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
IndicatorLevelID int NOT NULL,
IndicatorComponentID int NOT NULL,
IndicatorComponent float NOT NULL
CONSTRAINT PK_ATM_GM_IndicatorLevels PRIMARY KEY(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorComponentID)
)

ALTER Table ATM_GM_IndicatorLevels
ADD CONSTRAINT FK_ATM_GM_IndicatorLevels FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES ATM_GM_ModelGroups(SolutionID,ModelGroupID)

CREATE TABLE R_ATM_GM_IndicatorLevelInstances (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
IndicatorLevelID int NOT NULL,-- FOREIGN KEY REFERENCES ATM_GM_IndicatorLevels(IndicatorLevelID) ,
IndicatorLevelInstanceID int NOT NULL,
ComponentValues float NOT NULL
CONSTRAINT PK_ATM_GM_IndicatorLevelInstances PRIMARY KEY(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorLevelInstanceID)
)

ALTER Table ATM_GM_IndicatorLevelInstances
ADD CONSTRAINT FK_ATM_GM_IndicatorLevelInstances FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES ATM_GM_ModelGroups(SolutionID,ModelGroupID)

CREATE TABLE R_ATM_GM_ModelIndicatorValues (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
IndicatorLevelID int NOT NULL,
IndicatorLevelInstanceID int NOT NULL,
IndicatorID int FOREIGN KEY REFERENCES ATM_GM_Indicators(IndicatorID)  NOT NULL,
[Timestamp] datetime NOT NULL,
Value float NOT NULL
CONSTRAINT PK_ATM_GM_ModelIndicatorValues PRIMARY KEY(SolutionID,ModelGroupID,ModelID,IndicatorLevelID,IndicatorLevelInstanceID,IndicatorID,[Timestamp])
)

ALTER Table ATM_GM_ModelIndicatorValues
ADD CONSTRAINT FK_ATM_GM_ModelIndicatorValues FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES ATM_GM_ModelGroups(SolutionID,ModelGroupID)
--ALTER TABLE ATM_GM_ModelIndicatorValues
--ADD CONSTRAINT FK_ATM_GM_ModelIndicatorValues FOREIGN KEY (SolutionID,ModelGroupID,IndicatorLevelID,IndicatorLevelInstanceID) REFERENCES ATM_GM_IndicatorLevelInstances(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorLevelInstanceID) -- cannot add this constraint... Do something instead?


------------------------------------------------------------------------------------------------

