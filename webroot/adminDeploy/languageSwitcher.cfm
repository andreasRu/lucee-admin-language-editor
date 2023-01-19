<cfscript>
  fileLocation = getpagecontext().getServletConfig().getInitParameter("lucee-web-directory") & "/context/admin/resources/language/#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.xml";
   
    if ( !fileExists( fileLocation ) ){
         writeOutput( "The language resource file <b>#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.xml</b> is not available at: <br><br><i>#encodeForHTML( fileLocation )# </i>.<br><br>Please save &amp; push '#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.xml' file from the <b>Lucee Admin Language Editor</b> by clicking the ""Save Changes to '#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.xml' &amp; push to Admin"" first.");
    }else{

        if( structKeyExists( application.stText, form.lang ) ){ 
            structDelete( application.stText, form.lang ) 
        };   
        cfcookie(name = "lucee_admin_lang" value= "#form.lang#");
        session.lucee_admin_lang = "#form.lang#";
        include template="resources/text.cfm";
        location("#request.adminType#.cfm", "false", "302");


    }

</cfscript>