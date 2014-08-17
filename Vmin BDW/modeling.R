## CONFIGURATION ###########################################################
#How to use: 1. define productid,projectid,groupid,jobid, overshoot limit, resolution in the corresponding field
#            2. adjust the file_name to a directory in your computer
#            3. define the dsn in the corresponding field
#            4. Run the entire script

### ENTER THE PRODUCT ID, project id, group id job id overshoot limit, resolution

product.id <- 6;
project.id <- 132;
OS <- 0.05;
step.res <- 0.01;
view.prefix<-"VM2F_BDU_Class_UT_GroupID_653_693"
target.values.table<-"VM2F_BDU_Class_UT_Filtered_Target_Values_653_693"
modeling.results.table<-"VM2F_BDU_Class_UT_ModelingResults_653_693"
####################################################################

myconn <- set.connection(); #Set connection should be implemented according to each project
groups<-get.groups(myconn,project.id)
#groups<-groups[16]
for (group in groups)
{
    group.id <- group[1];
    job.id <- group[2];
    cat(paste0("--Started: groupID=",group.id," JobID=",job.id,"\n"))
    
    ### ENTER THE PATH AND THE CSV NAME HERE
    output.file.name <- paste(outputDir,product.id,".csv", sep="")
    
    ### ENTER THE DSN CONNECTION NAME HERE
    
    ############################################################################
    cat("get.data\n")
    data <- get.data(myconn, product.id, group.id,view.prefix ,target.values.table);
    
    cat("get.ars.features\n")
    features <- get.ars.features(myconn, project.id, job.id);
    
    cat("special values handdling\n")
    train <- data[data$IsTrain == '1',];
    train <- train[,sapply(train, is.numeric)];
    train <- apply(train,2,function(x){
      x[which(x==-999)] <- NA;
      return(x);
    });
    
    train <- as.data.frame(train);
    
    cat("replace Nulls\n")
    na.percentages <- sapply(features,function(f){
      x <- train[,f];
      return(sum(is.na(x))/length(x));
    });
    features <- features[na.percentages < 0.1];
    
    length(features);
    
    features <- features[1:5];
    
    cat("create model\n")
    reg <- lm(train[,c('Target',features)]);
    prediction.train <- predict(reg,train);
    
    cat("create equation\n")
    equation <-paste0(reg$coefficients[1],
                     '+',format(reg$coefficients[2],scientific = FALSE),'*',names(reg$coefficients)[2],
                     '+',format(reg$coefficients[3],scientific = FALSE),'*',names(reg$coefficients)[3],
                     '+',format(reg$coefficients[4],scientific = FALSE),'*',names(reg$coefficients)[4],
                     '+',format(reg$coefficients[5],scientific = FALSE),'*',names(reg$coefficients)[5],
                     '+',format(reg$coefficients[6],scientific = FALSE),'*',names(reg$coefficients)[6] )
    shift<-get.shift(train[,"Target"],prediction.train,OS, step.res)
    
    cat("Write to SQL\n")
    query<-paste0("INSERT INTO ",modeling.results.table," VALUES(",group.id,",'",equation,"',",shift,")");
    sqlQuery(myconn, query);
    
    cat(paste0("--Finished\n\n"))
}

close(myconn);

