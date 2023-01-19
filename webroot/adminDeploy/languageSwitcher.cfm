<cfscript>
if( structKeyExists( application.stText, form.lang ) ){ 
    structDelete( application.stText, form.lang ) };   
    cfcookie(name = "lucee_admin_lang" value= "#form.lang#");
    session.lucee_admin_lang = "#form.lang#";
    include template="resources/text.cfm";
    location("#request.adminType#.cfm", "false", "302");
</cfscript>