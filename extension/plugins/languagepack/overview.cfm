<cfoutput>

	<!--- The language switch happens here with the help of the original text.cfm file 
	that has been pulled as an original copy from the shipped lucee admin extension --->
	<cfif structKeyExists(form, "lang" ) and fileExists( expandPath("{lucee-#request.adminType#}/context/admin/resources/language/" & reReplaceNoCase( form.lang , "[^a-zA-Z0-9\-]" , "" , "ALL" ) & ".json" ))>
		<cfscript>
			cfcookie(name = "lucee_admin_lang" value= form.lang);
			session.lucee_admin_lang = form.lang;
		</cfscript>
		<cfinclude template="/lucee/admin/resources/text.cfm">
		<cflocation url="#request.self#" addtoken=false>
	</cfif>	


	<form action="#request.self#?action=plugin&amp;plugin=languagepack" method="post">
		<select name="lang">
			<cfloop collection="#app.availableLanguages#" index="key">
				<option value="#encodeForHTMLAttribute( key )#" <cfif key==session.lucee_admin_lang>selected</cfif>>#encodeForHTML( app.availableLanguages[key] )#</option>
			</cfloop>
		</select>
		<div>
			<input class="button submit" type="submit" name="submit" value="#encodeForHTMLAttribute( lang.btnSubmit )#" />
		</div>
	</form>

</cfoutput>
