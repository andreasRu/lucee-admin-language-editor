<cfoutput>
	
	<form action="#request.self#?action=languagepack.switchLanguage" method="post">
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
