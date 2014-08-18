set.connection<-function(){
  serverName<- "haisqldev021"
  userName<-""
  password<-""
  
  return(odbcConnect(serverName,uid=userName,pwd=password));
}