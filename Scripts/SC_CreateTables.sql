---------------------------------------------------------
-----------------------DROP TABLES-----------------------
---------------------------------------------------------
DROP TABLE GM_R_ModelIndicatorValues
DROP TABLE GM_R_IndicatorLevelInstances --?
DROP TABLE GM_D_IndicatorLevels
DROP TABLE GM_F_ModelIndicators
DROP TABLE GM_D_Indicators
DROP TABLE GM_R_ModelEvaluationResults
DROP TABLE GM_F_ModelEvaluation
DROP TABLE GM_D_EvaluationMeasures
DROP TABLE GM_R_Remodeling
DROP TABLE GM_F_ModelingParameters
DROP TABLE GM_F_ModelingFeatures
DROP TABLE GM_D_Models
DROP TABLE GM_D_ModelGroups
DROP TABLE GM_D_Features
DROP TABLE GM_D_Parameters
DROP TABLE GM_D_Solutions
DROP TABLE GM_D_DE_DataSource
DROP TABLE GM_D_DE_Connections


--------------------------------------------------------------------------------------------
-----------------------------------------Data Extraction------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE GM_D_DE_Connections (
ConnectionID int NOT NULL PRIMARY KEY,
ConnectionDesc varchar(500) NOT NULL,
Provider varchar(50) NOT NULL,
ConnectionString varchar(1000) NOT NULL, -----ASK ERAN OR DAVID!!!!
ConnUser varbinary(50) NOT NULL,
CannPass varbinary(50) NOT NULL,
ServerName varbinary(100) NOT NULL,
ServiceName varchar(200) NULL,
PortNo int NULL
)

CREATE TABLE GM_D_DE_DataSource (
DataSourceID int NOT NULL PRIMARY KEY,
DataSourceDesc varchar(500) NOT NULL,
ConnectionID int NOT NULL FOREIGN KEY REFERENCES GM_D_DE_Connections(ConnectionID),
QueryTemplate varchar(max) NULL
)


--------------------------------------------------------------------------------------------
-----------------------------------------Modeling Tables------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE GM_D_Solutions (
SolutionID int NOT NULL PRIMARY KEY,
SolutionDescription varchar(500) NOT NULL
)

CREATE TABLE GM_D_Parameters (
ParameterID int NOT NULL PRIMARY KEY,
ParameterDesc varchar(500) NOT NULL,
DefaultValue varchar(500) NOT NULL
)

CREATE TABLE GM_D_Features (
FeatureID int NOT NULL,
SolutionID int NOT NULL FOREIGN KEY REFERENCES GM_D_Solutions(SolutionID),
Test_Name varchar(250) NOT NULL,
Operation varchar(50) NOT NULL,
SourceTable varchar(250) NOT NULL,
Categorizing_Value varchar(16) NOT NULL, ----------CHECK DATATYPE!!!
Distinctive_Value float NOT NULL,
XMLTestCaption xml NOT NULL
CONSTRAINT PK_GM_D_Features PRIMARY KEY (FeatureID,SolutionID)
) ON UPS_SolutionID_PartitionScheme(SolutionID)

CREATE TABLE GM_D_ModelGroups (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
ModelGroupDescription varchar(500) NOT NULL,
PreStep varchar(max) NULL  ----------CHECK DATATYPE!!!
CONSTRAINT PK_GM_D_ModelGroups PRIMARY KEY (SolutionID,ModelGroupID)
) ON UPS_SolutionID_PartitionScheme(SolutionID)

CREATE TABLE GM_D_Models (
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
 CONSTRAINT PK_GM_D_Models PRIMARY KEY (ModelID,SolutionID)
) ON UPS_SolutionID_PartitionScheme(SolutionID)

ALTER Table GM_D_Models
ADD  CONSTRAINT FK_GM_D_Models FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES GM_D_ModelGroups(SolutionID,ModelGroupID)

CREATE TABLE GM_F_ModelingFeatures (
ModelID int NOT NULL, --FOREIGN KEY REFERENCES GM_D_Models(ModelID),
SolutionID int NOT NULL,
FeatureID int NOT NULL,-- FOREIGN KEY REFERENCES GM_D_Features(FeatureID),
UpdateTimestamp datetime NOT NULL,
IsActive BIT DEFAULT 1, ---------TO CHECK!
CONSTRAINT pk_GM_F_ModelingFeatures PRIMARY KEY (ModelID,FeatureID)
)

ALTER TABLE GM_F_ModelingFeatures
ADD CONSTRAINT FK_GM_F_ModelingFeatures_1 FOREIGN KEY (ModelID,SolutionID) REFERENCES GM_D_Models (ModelID,SolutionID)

ALTER TABLE GM_F_ModelingFeatures
ADD CONSTRAINT FK_GM_F_ModelingFeatures_2 FOREIGN KEY (FeatureID,SolutionID) REFERENCES GM_D_Features (FeatureID,SolutionID)

CREATE TABLE GM_F_ModelingParameters ( -------To Check in Easy - domain level settings
SolutionID int NOT NULL, --Change foreign keys!!
ModelGroupID int NOT NULL,
ModelID int NOT NULL,-- FOREIGN KEY REFERENCES GM_D_Models(ModelID),
FeatureID int NULL,-- FOREIGN KEY REFERENCES GM_D_Features(FeatureID),
ParameterID int NOT NULL FOREIGN KEY REFERENCES GM_D_Parameters(ParameterID),
Value varchar(max) NOT NULL,
CONSTRAINT pk_GM_F_ModelingParameters PRIMARY KEY (SolutionID,ModelGroupID,ModelID,ParameterID) ---Cannot define PRIMARY KEY constraint on nullable column FeatureID
)

ALTER Table GM_F_ModelingParameters
ADD  CONSTRAINT FK_GM_F_ModelingParameters FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES GM_D_ModelGroups(SolutionID,ModelGroupID)

ALTER TABLE GM_F_ModelingParameters
ADD CONSTRAINT FK_GM_F_ModelingParameters_1 FOREIGN KEY (ModelID,SolutionID) REFERENCES GM_D_Models (ModelID,SolutionID)

ALTER TABLE GM_F_ModelingParameters
ADD CONSTRAINT FK_GM_F_ModelingParameters_2 FOREIGN KEY (FeatureID,SolutionID) REFERENCES GM_D_Features (FeatureID,SolutionID)

CREATE TABLE GM_R_Remodeling (
ModelID int NOT NULL,
SolutionID int NOT NULL,-- FOREIGN KEY REFERENCES GM_D_Models(ModelID),
RemodelingTimestamp datetime NOT NULL,
SubmodelID int DEFAULT 0, ----------TO CHECK!!!
SubmodelCondition varchar(250) NULL, ---------CHECK DATADYPE!!!
SubmodelWeight float NULL,
Formula varchar(max) NOT NULL,
CONSTRAINT pk_GM_R_Remodeling PRIMARY KEY (ModelID,SolutionID,RemodelingTimestamp,SubmodelID)
)

ALTER TABLE GM_R_Remodeling
ADD CONSTRAINT FK_GM_R_Remodeling FOREIGN KEY (ModelID,SolutionID) REFERENCES GM_D_Models


--------------------------------------------------------------------------------------------
-----------------------------------------Evaluation-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE GM_D_EvaluationMeasures (
EvaluationMeasureID int IDENTITY(1,1) PRIMARY KEY, ---add identity coulmn
EvaluationMeasureName varchar(250) NOT NULL,
EvaluationDefinition varchar(max) NOT NULL
)

CREATE TABLE GM_F_ModelEvaluation (
SolutionID int NOT NULL, --------FIX THE FOREIGN KEYS (to model groups)
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
EvaluationMeasureID int NOT NULL FOREIGN KEY REFERENCES GM_D_EvaluationMeasures (EvaluationMeasureID),
CONSTRAINT pk_GM_F_ModelEvaluation PRIMARY KEY (SolutionID,ModelGroupID,ModelID,EvaluationMeasureID)
)

ALTER Table GM_F_ModelEvaluation
ADD  CONSTRAINT FK_GM_F_ModelEvaluation FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES GM_D_ModelGroups(SolutionID,ModelGroupID)

ALTER Table GM_F_ModelEvaluation
ADD  CONSTRAINT FK_GM_F_ModelEvaluation2 FOREIGN KEY (ModelID,SolutionID) REFERENCES GM_D_Models(ModelID,SolutionID)

CREATE TABLE GM_R_ModelEvaluationResults (
ModelID int NOT NULL,
SolutionID int NOT NULL,
RemodelingTimestamp datetime NOT NULL, --add timestamp as a foreign key to remodeling if possible
Dataset varchar(250) NOT NULL,
EvaluationMeasureID int NOT NULL FOREIGN KEY REFERENCES GM_D_EvaluationMeasures (EvaluationMeasureID),
Value float NOT NULL,
CONSTRAINT pk_GM_R_ModelEvaluationResults PRIMARY KEY (ModelID,SolutionID,RemodelingTimestamp,Dataset,EvaluationMeasureID)
)

ALTER Table GM_R_ModelEvaluationResults
ADD  CONSTRAINT FK_GM_R_ModelEvaluationResults FOREIGN KEY (ModelID,SolutionID) REFERENCES GM_D_Models(ModelID,SolutionID)

--ALTER Table GM_R_ModelEvaluationResults
--ADD  CONSTRAINT FK_GM_R_ModelEvaluationResults FOREIGN KEY (ModelID,RemodelingTimestamp) REFERENCES GM_R_Remodeling(ModelID,RemodelingTimestamp) ------Check if it works! Not worling, ask Itamar what to do 

--------------------------------------------------------------------------------------------
-----------------------------------------Indicators-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE GM_D_Indicators (
IndicatorID int NOT NULL PRIMARY KEY,
IndicatorName varchar(50) NOT NULL,
IndicatorDefinition varchar(1000) NOT NULL,
IndicatorCaption varchar(100) NOT NULL
)

CREATE TABLE GM_F_ModelIndicators (
SolutionID int NOT NULL, --Goes together
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
IndicatorLevelID int NOT NULL,--same as in easy (?)
IndicatorID int NOT NULL,
CONSTRAINT PK_GM_F_ModelIndicators PRIMARY KEY(SolutionID,ModelGroupID,ModelID,IndicatorLevelID,IndicatorID)
)

ALTER Table GM_F_ModelIndicators
ADD CONSTRAINT FK_GM_F_ModelIndicators FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES GM_D_ModelGroups(SolutionID,ModelGroupID)

CREATE TABLE GM_D_IndicatorLevels (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
IndicatorLevelID int NOT NULL,
IndicatorComponentID int NOT NULL,
IndicatorComponent float NOT NULL
CONSTRAINT PK_GM_D_IndicatorLevels PRIMARY KEY(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorComponentID)
)

ALTER Table GM_D_IndicatorLevels
ADD CONSTRAINT FK_GM_D_IndicatorLevels FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES GM_D_ModelGroups(SolutionID,ModelGroupID)

CREATE TABLE GM_R_IndicatorLevelInstances (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
IndicatorLevelID int NOT NULL,-- FOREIGN KEY REFERENCES GM_D_IndicatorLevels(IndicatorLevelID) ,
IndicatorLevelInstanceID int NOT NULL,
ComponentValues float NOT NULL
CONSTRAINT PK_GM_R_IndicatorLevelInstances PRIMARY KEY(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorLevelInstanceID)
)

ALTER Table GM_R_IndicatorLevelInstances
ADD CONSTRAINT FK_GM_R_IndicatorLevelInstances FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES GM_D_ModelGroups(SolutionID,ModelGroupID)

CREATE TABLE GM_R_ModelIndicatorValues (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
IndicatorLevelID int NOT NULL,
IndicatorLevelInstanceID int NOT NULL,
IndicatorID int FOREIGN KEY REFERENCES GM_D_Indicators(IndicatorID)  NOT NULL,
[Timestamp] datetime NOT NULL,
Value float NOT NULL
CONSTRAINT PK_GM_R_ModelIndicatorValues PRIMARY KEY(SolutionID,ModelGroupID,ModelID,IndicatorLevelID,IndicatorLevelInstanceID,IndicatorID,[Timestamp])
)

ALTER Table GM_R_ModelIndicatorValues
ADD CONSTRAINT FK_GM_R_ModelIndicatorValues FOREIGN KEY (SolutionID,ModelGroupID) REFERENCES GM_D_ModelGroups(SolutionID,ModelGroupID)
--ALTER TABLE GM_R_ModelIndicatorValues
--ADD CONSTRAINT FK_GM_R_ModelIndicatorValues FOREIGN KEY (SolutionID,ModelGroupID,IndicatorLevelID,IndicatorLevelInstanceID) REFERENCES GM_R_IndicatorLevelInstances(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorLevelInstanceID) -- cannot add this constraint... Do something instead?


------------------------------------------------------------------------------------------------

