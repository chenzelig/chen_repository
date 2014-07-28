USE MFG_Solutions

GO

---------------------------------------------------------
-----------------------DROP TABLES-----------------------
---------------------------------------------------------
--if not exists before each table creation
--add logical keys indexes

IF OBJECT_ID('dbo.GM_R_ModelIndicatorValues') IS NOT NULL DROP TABLE dbo.GM_R_ModelIndicatorValues
IF OBJECT_ID('dbo.GM_R_IndicatorLevelInstances') IS NOT NULL DROP TABLE dbo.GM_R_IndicatorLevelInstances
IF OBJECT_ID('dbo.GM_D_IndicatorLevels') IS NOT NULL DROP TABLE dbo.GM_D_IndicatorLevels
IF OBJECT_ID('dbo.GM_F_ModelIndicators') IS NOT NULL DROP TABLE dbo.GM_F_ModelIndicators
IF OBJECT_ID('dbo.GM_D_Indicators') IS NOT NULL DROP TABLE dbo.GM_D_Indicators
IF OBJECT_ID('dbo.GM_R_ModelEvaluationResults') IS NOT NULL DROP TABLE dbo.GM_R_ModelEvaluationResults
IF OBJECT_ID('dbo.GM_F_ModelEvaluation') IS NOT NULL DROP TABLE dbo.GM_F_ModelEvaluation
IF OBJECT_ID('dbo.GM_D_EvaluationMeasures') IS NOT NULL DROP TABLE dbo.GM_D_EvaluationMeasures
IF OBJECT_ID('dbo.GM_R_Remodeling') IS NOT NULL DROP TABLE dbo.GM_R_Remodeling
IF OBJECT_ID('dbo.GM_F_ModelingParameters') IS NOT NULL DROP TABLE dbo.GM_F_ModelingParameters
IF OBJECT_ID('dbo.GM_F_ModelingFeatures') IS NOT NULL DROP TABLE dbo.GM_F_ModelingFeatures
IF OBJECT_ID('dbo.GM_D_Models') IS NOT NULL DROP TABLE dbo.GM_D_Models
IF OBJECT_ID('dbo.GM_D_ModelGroups') IS NOT NULL DROP TABLE dbo.GM_D_ModelGroups
IF OBJECT_ID('dbo.GM_D_Features') IS NOT NULL DROP TABLE dbo.GM_D_Features
IF OBJECT_ID('dbo.GM_D_Parameters') IS NOT NULL DROP TABLE dbo.GM_D_Parameters
IF OBJECT_ID('dbo.GM_D_ParameterLevels') IS NOT NULL DROP TABLE dbo.GM_D_ParameterLevels
IF OBJECT_ID('dbo.GM_D_Solutions') IS NOT NULL DROP TABLE dbo.GM_D_Solutions
IF OBJECT_ID('dbo.GM_D_DE_DataSource') IS NOT NULL DROP TABLE dbo.GM_D_DE_DataSource
IF OBJECT_ID('dbo.GM_D_DE_Connections') IS NOT NULL DROP TABLE dbo.GM_D_DE_Connections
IF OBJECT_ID('dbo.GM_D_DE_ConnectionTypes') IS NOT NULL DROP TABLE dbo.GM_D_DE_ConnectionTypes


--------------------------------------------------------------------------------------------
-----------------------------------------Data Extraction------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE dbo.GM_D_DE_ConnectionTypes (
	ConnectionTypeID int NOT NULL,
	ConnectionTypeDesc varchar(100),
	ConnectionAttributes varchar(200)
)

ALTER TABLE dbo.GM_D_DE_ConnectionTypes
ADD CONSTRAINT PK_GM_D_DE_ConnectionTypes PRIMARY KEY (ConnectionTypeID) 


CREATE TABLE dbo.GM_D_DE_Connections (
	ConnectionID int NOT NULL,
	ConnectionDesc varchar(500) NOT NULL,
	ConnectionTypeID int NOT NULL,
	Provider varchar(50) NULL,
	ConnectionString varchar(1000) NULL,
	ConnUser varbinary(50) NULL,
	ConnPass varchar(1000)  NULL,
	ServerName varbinary(100) NULL,
	ServiceName varchar(200) NULL,
	PortNo int NULL,
	SourceType varchar(20) NULL,
	Driver varchar(400) NULL,
	Module varchar(20) NULL,
)

ALTER TABLE dbo.GM_D_DE_Connections
ADD CONSTRAINT PK_GM_D_DE_Connections PRIMARY KEY (ConnectionID),
	CONSTRAINT FK_GM_D_DE_Connections_ConnectionTypeID FOREIGN KEY (ConnectionTypeID) REFERENCES GM_D_DE_ConnectionTypes(ConnectionTypeID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_DE_Connections ON dbo.GM_D_DE_Connections (ConnectionDesc)


CREATE TABLE dbo.GM_D_DE_DataSource (
	DataSourceID int NOT NULL,
	DataSourceDesc varchar(500) NOT NULL,
	ConnectionID int NOT NULL,
)

ALTER TABLE dbo.GM_D_DE_DataSource
ADD CONSTRAINT PK_GM_D_DE_DataSource PRIMARY KEY (DataSourceID),
	CONSTRAINT FK_GM_D_DE_DataSource_ConnectionID FOREIGN KEY (ConnectionID) REFERENCES GM_D_DE_Connections(ConnectionID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_DE_DataSource ON dbo.GM_D_DE_DataSource (DataSourceDesc)
--------------------------------------------------------------------------------------------
-----------------------------------------Modeling Tables------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE dbo.GM_D_Solutions (
	SolutionID int NOT NULL,
	SolutionDescription varchar(500) NOT NULL
)

ALTER TABLE dbo.GM_D_Solutions
ADD CONSTRAINT PK_GM_D_Solutions PRIMARY KEY (SolutionID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_Solutions ON dbo.GM_D_Solutions (SolutionDescription)

CREATE TABLE dbo.GM_D_ParameterLevels (
	ParameterLevelID int NOT NULL,
	ParameterLevel varchar(20)
)

ALTER TABLE dbo.GM_D_ParameterLevels
ADD CONSTRAINT PK_GM_D_ParameterLevels PRIMARY KEY (ParameterLevelID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_ParameterLevels ON dbo.GM_D_ParameterLevels (ParameterLevel)

CREATE TABLE dbo.GM_D_Parameters (
	ParameterID int NOT NULL,
	ParameterDesc varchar(500) NOT NULL,
	ParameterLevelID int,
	DefaultValue varchar(500) NOT NULL
)

ALTER TABLE dbo.GM_D_Parameters
ADD CONSTRAINT PK_GM_D_Parameters PRIMARY KEY (ParameterID),
	CONSTRAINT FK_GM_D_Parameters_ParameterLevelID FOREIGN KEY (ParameterLevelID) REFERENCES GM_D_ParameterLevels(ParameterLevelID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_Parameters ON dbo.GM_D_Parameters (ParameterDesc)

CREATE TABLE dbo.GM_D_Features (
	FeatureID int NOT NULL,
	SolutionID int NOT NULL,
	Test_Name varchar(250) NOT NULL,
	Operation varchar(50) NOT NULL,
	SourceTable varchar(250) NOT NULL,
	Categorizing_Value varchar(16) NOT NULL, 
	Distinctive_Value float NOT NULL,
	XMLTestCaption xml NOT NULL
)-- ON UPS_SolutionID_PartitionScheme(SolutionID)

ALTER TABLE dbo.GM_D_Features
ADD CONSTRAINT PK_GM_D_Features PRIMARY KEY (FeatureID,SolutionID),
	CONSTRAINT FK_GM_D_Features_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_Features ON dbo.GM_D_Features (SolutionID,Test_Name,Operation,SourceTable,Categorizing_Value,Distinctive_Value)

CREATE TABLE dbo.GM_D_ModelGroups (
	SolutionID int NOT NULL,
	ModelGroupID int NOT NULL,
	ModelGroupDescription varchar(500) NOT NULL
)-- ON UPS_SolutionID_PartitionScheme(SolutionID)

ALTER TABLE dbo.GM_D_ModelGroups
ADD CONSTRAINT PK_GM_D_ModelGroups PRIMARY KEY (ModelGroupID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_ModelGroups ON dbo.GM_D_ModelGroups (ModelGroupDescription)

CREATE TABLE dbo.GM_D_Models (
	ModelID int NOT NULL,
	SolutionID int NOT NULL,
	Product varchar(10) NOT NULL, 
	Operation varchar(50) NOT NULL,
	DieStructure varchar(250) NOT NULL,
	Package varchar(10) NOT NULL, 
	[Version] varchar(50) NOT NULL,
	GenericColumn varchar(250) NOT NULL,
	ModelGroupID int NOT NULL,
	IsBackground BIT,
	IsProduction BIT,
	IsIndicators BIT
)-- ON UPS_SolutionID_PartitionScheme(SolutionID)

ALTER TABLE dbo.GM_D_Models
ADD CONSTRAINT PK_GM_D_Models PRIMARY KEY (ModelID),
	CONSTRAINT FK_GM_D_Models_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID),
	CONSTRAINT Default_GM_D_Models_IsBackground DEFAULT 0 FOR IsBackground,
	CONSTRAINT Default_GM_D_Models_IsProduction DEFAULT 0 FOR IsProduction,
	CONSTRAINT Default_GM_D_Models_IsIndicators DEFAULT 0 FOR IsIndicators

CREATE NONCLUSTERED INDEX IX_LK_GM_D_Models ON dbo.GM_D_Models (SolutionID,Product,Operation,DieStructure,Package,[Version],GenericColumn)
CREATE NONCLUSTERED INDEX IX_N_GM_D_Models_MGID ON dbo.GM_D_Models (ModelGroupID)

CREATE TABLE dbo.GM_F_ModelingFeatures (
	ModelID int NOT NULL, 
	SolutionID int NOT NULL,
	FeatureID int NOT NULL,
	UpdateTimestamp datetime NOT NULL,
	IsActive BIT
)

ALTER TABLE dbo.GM_F_ModelingFeatures
ADD CONSTRAINT PK_GM_F_ModelingFeatures PRIMARY KEY (ModelID,FeatureID),
	CONSTRAINT FK_GM_F_ModelingFeatures_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models (ModelID),
	CONSTRAINT FK_GM_F_ModelingFeatures_Feature FOREIGN KEY (FeatureID,SolutionID) REFERENCES GM_D_Features (FeatureID,SolutionID),
	CONSTRAINT Default_GM_F_ModelingFeatures_IsActive DEFAULT 1 FOR IsActive

CREATE NONCLUSTERED INDEX IX_LK_GM_F_ModelingFeatures ON dbo.GM_F_ModelingFeatures (ModelID,FeatureID)

CREATE TABLE dbo.GM_F_ModelingParameters (
	SolutionID int NOT NULL,
	ModelGroupID int NOT NULL,
	ModelID int NOT NULL,
	FeatureID int NULL,
	ParameterID int NOT NULL,
	Value varchar(max) NOT NULL
)

ALTER TABLE dbo.GM_F_ModelingParameters
ADD  CONSTRAINT FK_GM_F_ModelingParameters_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID),
	 CONSTRAINT FK_GM_F_ModelingParameters_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models (ModelID),
	 CONSTRAINT FK_GM_F_ModelingParameters_ParameterID FOREIGN KEY (ParameterID) REFERENCES GM_D_Parameters (ParameterID),
	 CONSTRAINT FK_GM_F_ModelingParameters_Feature FOREIGN KEY (FeatureID,SolutionID) REFERENCES GM_D_Features (FeatureID,SolutionID),
	 CONSTRAINT FK_GM_F_ModelingParameters_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions (SolutionID)

CREATE NONCLUSTERED INDEX IX_LK_GM_F_ModelingParameters ON dbo.GM_F_ModelingParameters (SolutionID,ModelGroupID,ModelID,FeatureID,ParameterID)

CREATE TABLE dbo.GM_R_Remodeling (
	ModelID int NOT NULL,
	SolutionID int NOT NULL,
	RemodelingTimestamp datetime NOT NULL,
	SubmodelID int NOT NULL,
	SubmodelCondition varchar(250) NULL,
	SubmodelWeight float NULL,
	Formula varchar(max) NOT NULL
)

ALTER TABLE dbo.GM_R_Remodeling
ADD CONSTRAINT PK_GM_R_Remodeling PRIMARY KEY (ModelID,SolutionID,RemodelingTimestamp,SubmodelID),
	CONSTRAINT FK_GM_R_Remodeling_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models (ModelID),
	CONSTRAINT FK_GM_R_Remodeling_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions (SolutionID),
	CONSTRAINT Default_GM_R_Remodeling_SubmodelID DEFAULT 0 FOR SubmodelID

CREATE NONCLUSTERED INDEX IX_LK_GM_R_Remodeling ON dbo.GM_R_Remodeling (ModelID,RemodelingTimestamp,SubmodelID)
--------------------------------------------------------------------------------------------
-----------------------------------------Evaluation-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE dbo.GM_D_EvaluationMeasures (
	EvaluationMeasureID int NOT NULL,
	EvaluationMeasureName varchar(250) NOT NULL,
	EvaluationDefinition varchar(max) NOT NULL
)

ALTER TABLE dbo.GM_D_EvaluationMeasures
ADD CONSTRAINT PK_GM_D_EvaluationMeasures PRIMARY KEY (EvaluationMeasureID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_EvaluationMeasures ON dbo.GM_D_EvaluationMeasures (EvaluationMeasureName)

CREATE TABLE dbo.GM_F_ModelEvaluation (
	SolutionID int NOT NULL,
	ModelGroupID int NOT NULL,
	ModelID int NOT NULL,
	EvaluationMeasureID int NOT NULL,
	Datasets varchar(100) NOT NULL
)

ALTER TABLE dbo.GM_F_ModelEvaluation
ADD  CONSTRAINT PK_GM_F_ModelEvaluation PRIMARY KEY (SolutionID,ModelGroupID,ModelID,EvaluationMeasureID),
	 CONSTRAINT FK_GM_F_ModelEvaluation_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	 CONSTRAINT FK_GM_F_ModelEvaluation_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID),
	 CONSTRAINT FK_GM_F_ModelEvaluation_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models(ModelID),
	 CONSTRAINT FK_GM_F_ModelEvaluation_EvaluationMeasureID FOREIGN KEY (EvaluationMeasureID) REFERENCES GM_D_EvaluationMeasures(EvaluationMeasureID)

CREATE NONCLUSTERED INDEX IX_LK_GM_F_ModelEvaluation ON dbo.GM_F_ModelEvaluation (SolutionID,ModelGroupID,ModelID,EvaluationMeasureID)

CREATE TABLE dbo.GM_R_ModelEvaluationResults (
	ModelID int NOT NULL,
	SolutionID int NOT NULL,
	RemodelingTimestamp datetime NOT NULL, --add timestamp as a foreign key to remodeling if possible
	Dataset varchar(250) NOT NULL,
	EvaluationMeasureID int NOT NULL,
	Value float NOT NULL
)

ALTER TABLE dbo.GM_R_ModelEvaluationResults
ADD  CONSTRAINT PK_GM_R_ModelEvaluationResults PRIMARY KEY (ModelID,SolutionID,RemodelingTimestamp,Dataset,EvaluationMeasureID),
	 CONSTRAINT FK_GM_R_ModelEvaluationResults_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models(ModelID),
	 CONSTRAINT FK_GM_R_ModelEvaluationResults_EvaluationMeasureID FOREIGN KEY (EvaluationMeasureID) REFERENCES GM_D_EvaluationMeasures (EvaluationMeasureID)

CREATE NONCLUSTERED INDEX IX_LK_GM_R_ModelEvaluationResults ON dbo.GM_R_ModelEvaluationResults (ModelID,RemodelingTimestamp,Dataset,EvaluationMeasureID)
--------------------------------------------------------------------------------------------
-----------------------------------------Indicators-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE dbo.GM_D_Indicators (
	IndicatorID int NOT NULL,
	IndicatorName varchar(50) NOT NULL,
	IndicatorDefinition varchar(1000) NOT NULL,
	IndicatorCaption varchar(100) NOT NULL
)

ALTER TABLE dbo.GM_D_Indicators
ADD CONSTRAINT PK_GM_D_Indicators PRIMARY KEY (IndicatorID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_Indicators ON dbo.GM_D_Indicators (IndicatorName)

CREATE TABLE dbo.GM_D_IndicatorLevels (
	SolutionID int NOT NULL,
	ModelGroupID int NOT NULL,
	IndicatorLevelID int NOT NULL,
	IndicatorComponentID int NOT NULL,
	IndicatorComponent float NOT NULL
)

ALTER TABLE dbo.GM_D_IndicatorLevels
ADD CONSTRAINT PK_GM_D_IndicatorLevels PRIMARY KEY(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorComponentID),
	CONSTRAINT FK_GM_D_IndicatorLevels_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	CONSTRAINT FK_GM_D_IndicatorLevels_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID)

CREATE NONCLUSTERED INDEX IX_LK_GM_D_IndicatorLevels ON dbo.GM_D_IndicatorLevels (SolutionID,ModelGroupID,IndicatorLevelID,IndicatorComponentID)

CREATE TABLE dbo.GM_F_ModelIndicators (
	SolutionID int NOT NULL,
	ModelID int NOT NULL,
	IndicatorLevelID int NOT NULL,--same as in easy (?)
	IndicatorID int NOT NULL
)

ALTER TABLE dbo.GM_F_ModelIndicators
ADD CONSTRAINT PK_GM_F_ModelIndicators PRIMARY KEY (ModelID,IndicatorLevelID,IndicatorID),
	CONSTRAINT FK_GM_F_ModelIndicators_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	CONSTRAINT FK_GM_F_ModelIndicators_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models(ModelID)

CREATE NONCLUSTERED INDEX IX_LK_GM_F_ModelIndicators ON dbo.GM_F_ModelIndicators (SolutionID,ModelID,IndicatorLevelID,IndicatorID)

CREATE TABLE dbo.GM_R_IndicatorLevelInstances (
	SolutionID int NOT NULL,
	ModelGroupID int NOT NULL,
	IndicatorLevelID int NOT NULL,
	IndicatorLevelInstanceID int NOT NULL,
	ComponentValues float NOT NULL
)

ALTER TABLE dbo.GM_R_IndicatorLevelInstances
ADD CONSTRAINT PK_GM_R_IndicatorLevelInstances PRIMARY KEY(SolutionID,ModelGroupID,IndicatorLevelID,IndicatorLevelInstanceID),
	CONSTRAINT FK_GM_R_IndicatorLevelInstances_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	CONSTRAINT FK_GM_R_IndicatorLevelInstances_ModelGroupID FOREIGN KEY (ModelGroupID) REFERENCES GM_D_ModelGroups(ModelGroupID)

CREATE NONCLUSTERED INDEX IX_LK_GM_R_IndicatorLevelInstances ON dbo.GM_R_IndicatorLevelInstances (SolutionID,ModelGroupID,IndicatorLevelID,IndicatorLevelInstanceID)

CREATE TABLE dbo.GM_R_ModelIndicatorValues (
	SolutionID int NOT NULL,
	ModelID int NOT NULL,
	IndicatorLevelID int NOT NULL,
	IndicatorLevelInstanceID int NOT NULL,
	IndicatorID int NOT NULL,
	[Timestamp] datetime NOT NULL,
	Value float NOT NULL
)

ALTER TABLE dbo.GM_R_ModelIndicatorValues
ADD CONSTRAINT PK_GM_R_ModelIndicatorValues PRIMARY KEY(ModelID,IndicatorLevelID,IndicatorLevelInstanceID,IndicatorID,[Timestamp]),
	CONSTRAINT FK_GM_R_ModelIndicatorValues_SolutionID FOREIGN KEY (SolutionID) REFERENCES GM_D_Solutions(SolutionID),
	CONSTRAINT FK_GM_R_ModelIndicatorValues_ModelID FOREIGN KEY (ModelID) REFERENCES GM_D_Models(ModelID),
	CONSTRAINT FK_GM_R_ModelIndicatorValues_IndicatorID FOREIGN KEY (IndicatorID) REFERENCES GM_D_Indicators(IndicatorID)

CREATE NONCLUSTERED INDEX IX_LK_GM_R_ModelIndicatorValues ON dbo.GM_R_ModelIndicatorValues (SolutionID,ModelID,IndicatorLevelID,IndicatorLevelInstanceID,IndicatorID,[Timestamp])
