<cfscript>
    
    fileLocation = getpagecontext().getServletConfig().getInitParameter("lucee-web-directory") & "/context/admin/resources/language/#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.xml";
    if ( !fileExists( fileLocation ) ){
        writeOutput( "Resource File '#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.xml' is not available to the admin! Please save & push '#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.xml' file from the Language Editor to the admin fisrt!");
        abort;
    }

 

    if( structKeyExists( application.stText, form.lang ) ){ 
        structDelete( application.stText, form.lang ) 
    };   
    cfcookie(name = "lucee_admin_lang" value= "#form.lang#");
    session.lucee_admin_lang = "#form.lang#";
    include template="resources/text.cfm";
    location("#request.adminType#.cfm", "false", "302");
</cfscript>