USE MFG_Solutions

GO

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
DROP TABLE GM_D_ParameterLevels
DROP TABLE GM_D_Solutions
DROP TABLE GM_D_DE_DataSource
DROP TABLE GM_D_DE_Connections
DROP TABLE GM_D_DE_ConnectionTypes


--------------------------------------------------------------------------------------------
-----------------------------------------Data Extraction------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE GM_D_DE_ConnectionTypes (
ConnectionTypeID int NOT NULL,
ConnectionTypeDesc varchar(100),
ConnectionAttributes varchar(200)
)

ALTER TABLE GM_D_DE_ConnectionTypes
ADD CONSTRAINT PK_GM_D_DE_ConnectionTypes PRIMARY KEY (ConnectionTypeID) 



CREATE TABLE GM_D_DE_Connections (
ConnectionID int NOT NULL,
ConnectionDesc varchar(500) NOT NULL,
ConnectionTypeID int NOT NULL,
Provider varchar(50) NULL,
ConnectionString varchar(1000) NULL, -----ASK ERAN OR DAVID!!!!
ConnUser varbinary(50) NULL,
ConnPass varchar(1000)  NULL,
ServerName varbinary(100) NULL,
ServiceName varchar(200) NULL,
PortNo int NULL,
SourceType varchar(20) NULL,
Driver varchar(400) NULL,
Module varchar(20) NULL,
)

ALTER TABLE GM_D_DE_Connections
ADD CONSTRAINT PK_GM_D_DE_Connections PRIMARY KEY (ConnectionID),
	CONSTRAINT FK_GM_D_DE_Connections_ConnectionTypeID FOREIGN KEY (ConnectionTypeID) REFERENCES GM_D_DE_ConnectionTypes(ConnectionTypeID)


CREATE TABLE GM_D_DE_DataSource (
DataSourceID int NOT NULL,
DataSourceDesc varchar(500) NOT NULL,
ConnectionID int NOT NULL,
)

ALTER TABLE GM_D_DE_DataSource
ADD CONSTRAINT PK_GM_D_DE_DataSource PRIMARY KEY (DataSourceID),
	CONSTRAINT FK_GM_D_DE_DataSource_ConnectionID FOREIGN KEY (ConnectionID) REFERENCES GM_D_DE_Connections(ConnectionID)

--------------------------------------------------------------------------------------------
-----------------------------------------Modeling Tables------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE GM_D_Solutions (
SolutionID int NOT NULL,
SolutionDescription varchar(500) NOT NULL
)

ALTER TABLE GM_D_Solutions
ADD CONSTRAINT PK_GM_D_Solutions PRIMARY KEY (SolutionID)


CREATE TABLE GM_D_ParameterLevels (
ParameterLevelID int NOT NULL,
ParameterLevel varchar(20)
)

ALTER TABLE GM_D_ParameterLevels
ADD CONSTRAINT PK_GM_D_ParameterLevels PRIMARY KEY (ParameterLevelID)


CREATE TABLE GM_D_Parameters (
ParameterID int NOT NULL,
ParameterDesc varchar(500) NOT NULL,
ParameterLevelID int Foreign Key References GM_D_ParameterLevels(ParameterLevelID),
DefaultValue varchar(500) NOT NULL
)

ALTER TABLE GM_D_Parameters
ADD CONSTRAINT PK_GM_D_Parameters PRIMARY KEY (ParameterID),
	CONSTRAINT FK_GM_D_Parameters_ParameterLevelID FOREIGN KEY (ParameterLevelID) REFERENCES GM_D_ParameterLevels(ParameterLevelID)


CREATE TABLE GM_D_Features (
FeatureID int NOT NULL,
SolutionID int NOT NULL,
Test_Name varchar(250) NOT NULL,
Operation varchar(50) NOT NULL,
SourceTable varchar(250) NOT NULL,
Categorizing_Value varchar(16) NOT NULL, ----------CHECK DATATYPE!!!
Distinctive_Value float NOT NULL,
XMLTestCaption xml NOT NULL
)-- ON UPS_SolutionID_PartitionScheme(SolutionID)

ALTER TABLE GM_D_Features
ADD CONSTRAINT PK_GM_D_Features PRIMARY KEY (FeatureID,SolutionID),
	CONSTRAINT FK_GM_D_Features_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID)




CREATE TABLE GM_D_ModelGroups (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
ModelGroupDescription varchar(500) NOT NULL
)-- ON UPS_SolutionID_PartitionScheme(SolutionID)

ALTER TABLE GM_D_ModelGroups
ADD CONSTRAINT PK_GM_D_ModelGroups PRIMARY KEY (ModelGroupID)


CREATE TABLE GM_D_Models (
ModelID int NOT NULL,
SolutionID int NOT NULL,
Product varchar(10) NOT NULL,  ----------CHECK DATATYPE!!!
Operation varchar(50) NOT NULL,
DieStructure varchar(250) NOT NULL, ----------CHECK DATATYPE!!!
Package varchar(10) NOT NULL, ----------CHECK DATATYPE!!!
[Version] varchar(50) NOT NULL, ----------CHECK DATATYPE!!!
GenericColumn varchar(250) NOT NULL, ----------CHECK DATATYPE!!!
ModelGroupID int NOT NULL,
IsBackground BIT DEFAULT 0, -----------TO CHECK!!!
IsProduction BIT DEFAULT 0,
IsIndicators BIT DEFAULT 0
)-- ON UPS_SolutionID_PartitionScheme(SolutionID)

ALTER TABLE GM_D_Models
ADD CONSTRAINT PK_GM_D_Models PRIMARY KEY (ModelID),
	CONSTRAINT FK_GM_D_Models_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID)

CREATE TABLE GM_F_ModelingFeatures (
ModelID int NOT NULL, 
SolutionID int NOT NULL,
FeatureID int NOT NULL,
UpdateTimestamp datetime NOT NULL,
IsActive BIT DEFAULT 1
)

ALTER TABLE GM_F_ModelingFeatures
ADD CONSTRAINT PK_GM_F_ModelingFeatures PRIMARY KEY (ModelID,FeatureID),
	CONSTRAINT FK_GM_F_ModelingFeatures_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models (ModelID),
	CONSTRAINT FK_GM_F_ModelingFeatures_Feature FOREIGN KEY (FeatureID,SolutionID) REFERENCES GM_D_Features (FeatureID,SolutionID)

CREATE TABLE GM_F_ModelingParameters ( -------To Check in Easy - domain level settings
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
FeatureID int NULL,
ParameterID int NOT NULL,
Value varchar(max) NOT NULL
)

ALTER TABLE GM_F_ModelingParameters
ADD  CONSTRAINT FK_GM_F_ModelingParameters_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID),
	 CONSTRAINT FK_GM_F_ModelingParameters_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models (ModelID),
	 CONSTRAINT FK_GM_F_ModelingParameters_ParameterID FOREIGN KEY (ParameterID) REFERENCES GM_D_Parameters (ParameterID),
	 CONSTRAINT FK_GM_F_ModelingParameters_Feature FOREIGN KEY (FeatureID,SolutionID) REFERENCES GM_D_Features (FeatureID,SolutionID),
	 CONSTRAINT FK_GM_F_ModelingParameters_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions (SolutionID)

CREATE TABLE GM_R_Remodeling (
ModelID int NOT NULL,
SolutionID int NOT NULL,
RemodelingTimestamp datetime NOT NULL,
SubmodelID int NOT NULL DEFAULT 0, ----------TO CHECK!!!
SubmodelCondition varchar(250) NULL, ---------CHECK DATADYPE!!!
SubmodelWeight float NULL,
Formula varchar(max) NOT NULL
)

ALTER TABLE GM_R_Remodeling
ADD CONSTRAINT PK_GM_R_Remodeling PRIMARY KEY (ModelID,SolutionID,RemodelingTimestamp,SubmodelID),
	CONSTRAINT FK_GM_R_Remodeling_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models (ModelID),
	CONSTRAINT FK_GM_R_Remodeling_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions (SolutionID)


--------------------------------------------------------------------------------------------
-----------------------------------------Evaluation-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE GM_D_EvaluationMeasures (
EvaluationMeasureID int IDENTITY(1,1),
EvaluationMeasureName varchar(250) NOT NULL,
EvaluationDefinition varchar(max) NOT NULL
)

ALTER TABLE GM_D_EvaluationMeasures
ADD CONSTRAINT PK_GM_D_EvaluationMeasures PRIMARY KEY (EvaluationMeasureID)


CREATE TABLE GM_F_ModelEvaluation (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
EvaluationMeasureID int NOT NULL 
)

ALTER TABLE GM_F_ModelEvaluation
ADD  CONSTRAINT PK_GM_F_ModelEvaluation PRIMARY KEY (SolutionID,ModelGroupID,ModelID,EvaluationMeasureID),
	 CONSTRAINT FK_GM_F_ModelEvaluation_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	 CONSTRAINT FK_GM_F_ModelEvaluation_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID),
	 CONSTRAINT FK_GM_F_ModelEvaluation_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models(ModelID),
	 CONSTRAINT FK_GM_F_ModelEvaluation_EvaluationMeasureID FOREIGN KEY (EvaluationMeasureID) REFERENCES GM_D_EvaluationMeasures(EvaluationMeasureID)


CREATE TABLE GM_R_ModelEvaluationResults (
ModelID int NOT NULL,
SolutionID int NOT NULL,
RemodelingTimestamp datetime NOT NULL, --add timestamp as a foreign key to remodeling if possible
Dataset varchar(250) NOT NULL,
EvaluationMeasureID int NOT NULL,
Value float NOT NULL
)

ALTER TABLE GM_R_ModelEvaluationResults
ADD  CONSTRAINT PK_GM_R_ModelEvaluationResults PRIMARY KEY (ModelID,SolutionID,RemodelingTimestamp,Dataset,EvaluationMeasureID),
	 CONSTRAINT FK_GM_R_ModelEvaluationResults_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models(ModelID),
	 CONSTRAINT FK_GM_R_ModelEvaluationResults_EvaluationMeasureID FOREIGN KEY (EvaluationMeasureID) REFERENCES GM_D_EvaluationMeasures (EvaluationMeasureID)

--------------------------------------------------------------------------------------------
-----------------------------------------Indicators-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE GM_D_Indicators (
IndicatorID int NOT NULL,
IndicatorName varchar(50) NOT NULL,
IndicatorDefinition varchar(1000) NOT NULL,
IndicatorCaption varchar(100) NOT NULL
)

ALTER TABLE GM_D_Indicators
ADD CONSTRAINT PK_GM_D_Indicators PRIMARY KEY (IndicatorID)

CREATE TABLE GM_D_IndicatorLevels (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
IndicatorLevelID int NOT NULL,
IndicatorComponentID int NOT NULL,
IndicatorComponent float NOT NULL
)

ALTER TABLE GM_D_IndicatorLevels
ADD CONSTRAINT PK_GM_D_IndicatorLevels PRIMARY KEY(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorComponentID),
	CONSTRAINT FK_GM_D_IndicatorLevels_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	CONSTRAINT FK_GM_D_IndicatorLevels_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID)


CREATE TABLE GM_F_ModelIndicators (
SolutionID int NOT NULL, --Goes together
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
IndicatorLevelID int NOT NULL,--same as in easy (?)
IndicatorID int NOT NULL
)

ALTER TABLE GM_F_ModelIndicators
ADD CONSTRAINT PK_GM_F_ModelIndicators PRIMARY KEY (SolutionID,ModelGroupID,ModelID,IndicatorLevelID,IndicatorID),
	CONSTRAINT FK_GM_F_ModelIndicators_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	CONSTRAINT FK_GM_F_ModelIndicators_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID),
	CONSTRAINT FK_GM_F_ModelIndicators_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models(ModelID)



CREATE TABLE GM_R_IndicatorLevelInstances (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
IndicatorLevelID int NOT NULL,
IndicatorLevelInstanceID int NOT NULL,
ComponentValues float NOT NULL
)

ALTER TABLE GM_R_IndicatorLevelInstances
ADD CONSTRAINT PK_GM_R_IndicatorLevelInstances PRIMARY KEY(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorLevelInstanceID),
	CONSTRAINT FK_GM_R_IndicatorLevelInstances_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	CONSTRAINT FK_GM_R_IndicatorLevelInstances_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID)

CREATE TABLE GM_R_ModelIndicatorValues (
SolutionID int NOT NULL,
ModelGroupID int NOT NULL,
ModelID int NOT NULL,
IndicatorLevelID int NOT NULL,
IndicatorLevelInstanceID int NOT NULL,
IndicatorID int FOREIGN KEY REFERENCES GM_D_Indicators(IndicatorID)  NOT NULL,
[Timestamp] datetime NOT NULL,
Value float NOT NULL
)

ALTER TABLE GM_R_ModelIndicatorValues
ADD CONSTRAINT PK_GM_R_ModelIndicatorValues PRIMARY KEY(SolutionID,ModelGroupID,ModelID,IndicatorLevelID,IndicatorLevelInstanceID,IndicatorID,[Timestamp]),
	CONSTRAINT FK_GM_R_ModelIndicatorValues_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	CONSTRAINT FK_GM_R_ModelIndicatorValues_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID),
	CONSTRAINT FK_GM_R_ModelIndicatorValues_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models(ModelID)


