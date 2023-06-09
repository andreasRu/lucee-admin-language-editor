<cfscript>
  fileLocation = getpagecontext().getServletConfig().getInitParameter("lucee-web-directory") & "/context/admin/resources/language/#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.json";

        if( structKeyExists( application.stText, form.lang ) ){ 
            structDelete( application.stText, form.lang ) 
        };   
        cfcookie(name = "lucee_admin_lang" value= "#form.lang#");
        session.lucee_admin_lang = "#form.lang#";
        if( structKeyExists( cookie, "LUCEE_ADMIN_LASTPAGE"  )){
            actionStr="&action=#encodeForURL( cookie.LUCEE_ADMIN_LASTPAGE )#";
        }else{
            actionStr="";
        }
        
        include template="resources/text.cfm";
        
        if(getApplicationSettings().singleContext) {
            location url="index.cfm?reinit=true#actionStr#" addtoken="no";
        }
        else {
           
            location url="#request.adminType#.cfm?reinit=true#actionStr#" addtoken="no";
        }
        

</cfscript>