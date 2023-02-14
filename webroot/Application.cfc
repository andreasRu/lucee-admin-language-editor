component {


    this.appversion="0.0.8";
    this.name = "adminTranslator#server.lucee.version#-#this.appversion#";
	this.clientmanagement="no";
	this.scriptprotect="all";
	this.sessionmanagement="yes";
	this.sessionStorage="memory";
	this.sessiontimeout="#createTimeSpan(0,0,30,0)#";
	this.setclientcookies="yes";
	this.setdomaincookies="no"; 
	this.applicationtimeout="#createTimeSpan(1,0,0,0)#";
	this.web.charset="utf-8";
    this.basePath=getDirectoryFromPath( getCurrentTemplatePath() );
    this.mappings["/components"]=this.basePath & "components";
    this.mappings["/ajaxApi"]=this.basePath &  "ajaxApi";

    public boolean function OnApplicationStart(){
        application["appversion"]=this.appversion;
        return true;
    }
           
    
}