<cfscript>
	fileLocation = getpagecontext().getServletConfig().getInitParameter("lucee-web-directory") & "/context/admin/resources/language/#reReplaceNoCase( form.lang, "[^a-zA-Z0-9\-]", "", "ALL" )#.json";

	if( structKeyExists( application.stText, form.lang ) ){ 
		structDelete( application.stText, form.lang ) 
	};   
	
	cfcookie(name = "lucee_admin_lang" value= "#form.lang#");
	session.lucee_admin_lang = "#form.lang#";
	include template="resources/text.cfm";
	
	local.applicationSettings= getApplicationSettings();
	local.isSingleContext=( structKeyExists( local.applicationSettings, "singleContext" )  && local.applicationSettings.singleContext )?true:false;

	if( local.isSingleContext ) {
		location url="index.cfm?action=overview&reinit=true" addtoken="no";
	}
	else {
		location url="#request.adminType#.cfm?action=overview&reinit=true" addtoken="no";
	}
		

</cfscript>