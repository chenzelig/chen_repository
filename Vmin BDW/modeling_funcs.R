library(RODBC)

get.groups<- function(conn,project.id)
{
    query <- paste0("
                  SELECT AttributeName, A.jobid
                  FROM VM2Fsystem..ARS_AttributesInJob A 
                  JOIN VM2Fsystem..ARS_Attributes B 
                  ON A.ProjectID=B.ProjectID 
                  AND A.AttributeID=B.AttributeID
                  WHERE A.ProjectID=",project.id,"
                  AND IsTarget=1"
                    )
    groups <- sqlQuery(myconn, query);
    groups<- as.data.frame(groups) 
    groups<-data.frame(t(groups))
    return(groups);
}


get.data <- function(conn, product.id, group.id, view.prefix,target.values.table) {
  query <- paste0("
    SELECT D.[",group.id,"] AS [Target], T.[IsTrain], D.* 
    FROM [MPDExploration].[dbo].[",view.prefix,"_",group.id,"_VW] D
  	INNER JOIN (
			SELECT	DISTINCT [UnitID], [IsTrain]
			FROM	[MPDExploration].[dbo].[",target.values.table,"]
			WHERE	[GroupID] = ",group.id,"
					AND [ProductID] = ",product.id,"
		) T
			ON T.[UnitID] = D.[UnitID]
    WHERE [",group.id,"] IS NOT NULL");
  data <- sqlQuery(conn, query);
  return(data);
}
get.ars.features <- function(conn, project.id, job.id){
  query <-paste0("
                 SELECT top 10 AttributeName 
                 FROM   VM2Fsystem..ARS_AttributeReductionResults C 
                 INNER JOIN VM2Fsystem..ARS_Attributes A 
                 ON A.AttributeID = C.AttributeID 
                 AND A.ProjectID = C.ProjectID 
                 WHERE  C.Projectid=",project.id," 
                 and c.jobid=",job.id," 
                 and C.status=1  
                 and C.JobExecutionTS=(SELECT MAX(JobExecutionTS) 
                                       FROM VM2Fsystem..ARS_AttributeReductionResults 
                                       WHERE ProjectID=",project.id,"
                                       AND JobID=",job.id,") ORDER BY ABS(Rankvalue) DESC");
  features <- sqlQuery(conn, query, stringsAsFactors=FALSE);
  features <-features[,1];
  return(features);
}

get.shift <- function(y, prediction, OS, step.res){
  shift <- 0
  while(length(y[(prediction-y)>0]) / length(y) > OS)
  {
    shift <- shift + step.res
    prediction <- prediction - step.res
  }
  return(shift)
}
