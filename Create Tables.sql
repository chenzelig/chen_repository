--------------------------------------------------------------------------------------------
-----------------------------------------Modeling Tables------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE ATM_GM_Solutions (
SolutionID int NOT NULL PRIMARY KEY,
SolutionDescription NOT NULL varchar(500)
)

CREATE TABLE ATM_GM_Parameters (
ParameterID int NOT NULL PRIMARY KEY,
DefaultValue varchar(500)
)

CREATE TABLE ATM_GM_Features (
FeatureID int NOT NULL PRIMARY KEY,
SolutionID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Solutions(SolutionID),
Test_Name varchar(250) NOT NULL,
Operation int NOT NULL,
SourceTable varchar(250) NOT NULL,
Categorizing_Value int NOT NULL, ----------CHECK DATATYPE!!!
Distinctive_Value int NOT NULL,
XMLTestCaption xml NOT NULL
)

CREATE TABLE ATM_GM_ModelGroups (
SolutionID int NOT NULL PRIMARY KEY,
ModelGroupID int NOT NULL,
ModelGroupDescription varchar(500) NOT NULL,
PreStep int NOT NULL  ----------CHECK DATATYPE!!!
)

CREATE TABLE ATM_GM_Models (
ModelID int NOT NULL PRIMARY KEY,
SolutionID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Solutions(SolutionID),
Product varchar(250) NOT NULL,  ----------CHECK DATATYPE!!!
Operation int NUT NULL,
DieStructure varchar(250) NOT NULL, ----------CHECK DATATYPE!!!
Package varchar(250) NOT NULL, ----------CHECK DATATYPE!!!
Version/Specification varchar(250) NOT NULL, ----------CHECK DATATYPE!!!
GenericColumn varchar(250) NOT NULL, ----------CHECK DATATYPE!!!
ModelGroupID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_ModelGroups(ModelGroupID),
IsBackground BIT DEFAULT 0, -----------TO CHECK!!!
IsProduction BIT DEFAULT 0,
IsIndicators BIT DEFAULT 0
)

CREATE TABLE ATM_GM_ModelingFeatures (
ModelID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Models(ModelID),
FeatureID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Features(FeatureID),
UpdateTimestamp datetime NOT NULL,
IsActive BIT DEFAULT 1, ---------TO CHECK!
CONSTRAINT pk_ATM_GM_ModelingFeatures PRIMARY KEY (ModelID,FeatureID)
) 

CREATE TABLE ATM_GM_ModelingParameters (
SolutionID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Solutions(SolutionID),
ModelGroupID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_ModelGroups(ModelGroupID),
ModelID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Models(ModelID),
FeatureID int NULL FOREIGN KEY REFERENCES ATM_GM_Features(FeatureID),
ParameterID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Parameters(ParameterID),
Value float NOT NULL,
CONSTRAINT pk_ATM_GM_ModelingParameters PRIMARY KEY (SolutionID,ModelGroupID,ModelID,FeatureID,ParameterID)
)

CREATE TABLE ATM_GM_Remodeling (
ModelID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Models(ModelID),
RemodelingTimestamp datetime NOT NULL,
SubmodelID DEFAULT 0, ----------TO CHECK!!!
SubmodelCondition varchar(max) NULL, ---------CHECK DATADYPE!!!
SubmodelWeight float NULL,
Formula varchar(max) NOT NULL,
CONSTRAINT pk_ATM_GM_Remodeling PRIMARY KEY (ModelID,RemodelingTimestamp,SubmodelID)
)


--------------------------------------------------------------------------------------------
-----------------------------------------Data Extraction------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE ATM_GM_DE_Connections (
ConnectionID int NOT NULL PRIMARY KEY,
ConnectionDesc varchar(500) NOT NULL,
Provider varchar(50) NOT NULL,
ConnectionString varchar(1000) NOT NULL -----ASK ERAN OR DAVID!!!!
)

CREATE TABLE ATM_GM_DE_DataSource (
DataSourceID int NOT NULL PRIMARY KEY,
DataSourceDesc varchar(500) NOT NULL,
ConnectionID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_DE_Connections(ConnectionID),
QueryTemplate varchar(max) NULL
)

--------------------------------------------------------------------------------------------
-----------------------------------------Evaluation-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE ATM_GM_EvaluationMeasures (
EvaluationMeasureID int NOT NULL PRIMARY KEY,
EvaluationMeasureName varchar(250) NOT NULL,
EvaluationDefinition varchar(500) NOT NULL
)

CREATE TABLE ATM_GM_ModelEvaluation (
SolutionID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Solutions(SolutionID), --------FIX THE FOREIGN KEYS
ModelGroupID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_ModelGroups(ModelGroupID),
ModelID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Models(ModelID),
EvaluationMeasureID int NOT NULL REFERENCES ATM_GM_EvaluationMeasures (EvaluationMeasureID),
CONSTRAINT pk_ATM_GM_ModelEvaluation PRIMARY KEY (SolutionID,ModelGroupID,ModelID,EvaluationMeasureID)
)

CREATE TABLE ATM_GM_ModelEvaluationResults (
ModelID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Models(ModelID),
RemodelingTimestamp datetime NOT NULL,
Dataset varchar(250) NOT NULL,
EvaluationMeasureID int NOT NULL REFERENCES ATM_GM_EvaluationMeasures (EvaluationMeasureID),
Value float NOT NULL,
CONSTRAINT pk_ATM_GM_ModelEvaluationResults PRIMARY KEY (ModelID,RemodelingTimestamp,Dataset,EvaluationMeasureID)
)

--------------------------------------------------------------------------------------------
-----------------------------------------Indicators-----------------------------------------
--------------------------------------------------------------------------------------------

CREATE TABLE ATM_GM_Indicators (
IndicatorId int NOT NULL PRIMARY KEY,
IndicatorName varchar(50) NOT NULL,
IndicatorDefinition varchar(1000) NOT NULL,
IndicatorCaption varchar(100) NOT NULL
)



CREATE TABLE ATM_GM_ModelIndicators (
SolutionID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Solutions(SolutionID),
ModelGroupID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_ModelGroups(ModelGroupID),
ModelID int NOT NULL FOREIGN KEY REFERENCES ATM_GM_Models(ModelID),
IndicatorLevelID int NOT NULL,


