set.connection<-function(){
  serverName<- "haisqldev021"
  userName<-"BIAdm"
  password<-"1qazZAQA!"
  
  return(odbcConnect(serverName,uid=userName,pwd=password));
}