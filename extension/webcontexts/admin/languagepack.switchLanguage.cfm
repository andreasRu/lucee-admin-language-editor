<!--- The language switch happens here with the help of the original text.cfm file 
that has been pulled as an original copy from the shipped lucee admin extension --->
<cfif structKeyExists(form, "lang") 
      and fileExists( expandPath("{lucee-web}/context/admin/resources/language/" & reReplaceNoCase( form.lang , "[^a-zA-Z0-9\-]", "", "ALL" ) & ".json"))>
    <cfscript>
        cfcookie(name = "lucee_admin_lang" value= form.lang);
        session.lucee_admin_lang = form.lang;
    </cfscript>
    <cfinclude template="/lucee/admin/resources/text.cfm">
</cfif>
<cflocation url="#request.self#?reinit=true" addtoken=false>
