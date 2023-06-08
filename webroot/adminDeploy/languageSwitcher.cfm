<cfscript>
  fileLocation = getpagecontext().getServletConfig().getInitParameter("lucee-web-directory") & "/context/admin/resources/language/#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.json";

        if( structKeyExists( application.stText, form.lang ) ){ 
            structDelete( application.stText, form.lang ) 
        };   
        cfcookie(name = "lucee_admin_lang" value= "#form.lang#");
        session.lucee_admin_lang = "#form.lang#";
        
        include template="resources/text.cfm";
        
        if(getApplicationSettings().singleContext) {
            location url="index.cfm?reinit=true" addtoken="no";
        }
        else {
            location url="#request.adminType#.cfm?reinit=true" addtoken="no";
        }
        

</cfscript>