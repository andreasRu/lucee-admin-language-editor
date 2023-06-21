<cfif !arrayIsEmpty( availableLangResourceLanguage )>
	
	<cfset variables.adminKeyNameListOrdered=langData["en"].keylist().listSort( "textnocase" )>
	
	<cfoutput>
		<table class="langEditor">
			<thead>
				<tr>
					<th>Property</th>
					<cfloop array="#availableLangResourceLanguage#" item="itemLanguageKey" >
						<th>
							#encodeForHTML( structKeyExists( availableJavaLocales, itemLanguageKey)?availableJavaLocales[ itemLanguageKey ]:"" )#</div>
							#encodeForHTML( itemLanguageKey )#.json
							<cfif itemLanguageKey == "en">(default)</cfif>
								
								<button disabled class="button enhanced" id="save_#encodeForHTMLAttribute( itemLanguageKey )#" onClick="window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=updateJsonWorkingFile&amp;adminLang=#itemLanguageKey#', 'POST', '.updateContainer-#ucase(itemLanguageKey)# textarea', '##ajaxPopulateNotificationFlyingBar', 'reloadURLDelayed' );">Save Changes to "#itemLanguageKey#.json"<br><cfif !variables.LangEditorService.runningOnlineProductionMode  && server.lucee.version gt "6"> &amp; push to Admin</cfif></button>
								<!---a class="button" href="#encodeForHTMLAttribute( "/ajaxApi/ajaxLangService.cfm?method=viewFileJSON&viewFileJSON=" & encodeforURL( itemLanguageKey ) )#" target="_blank">View File JSON-Source</a--->
								<a class="button" href="#encodeForHTMLAttribute( "/ajaxApi/ajaxLangService.cfm?method=downloadFileJSON&downloadLanguageJSONFile=" & encodeforURL( itemLanguageKey ) )#" target="_blank">Download File For PR</a>
								
								<cfif !variables.LangEditorService.runningOnlineProductionMode && server.lucee.version gt "6">
									<cfif variables.LangEditorService.isSingleContext>
								   
										<form action="lucee/admin/index.cfm?action=languageSwitcher&amp;reinit=true" method="POST" target="server_#encodeForHTMLAttribute( itemLanguageKey )#">
											<input type="hidden" name="lang" value="#encodeForHTMLAttribute( itemLanguageKey )#">
											<button  class="button" onClick="console.dir(window.langUpdater.updatedWithoutSaving);if( window.langUpdater.updatedWithoutSaving.includes( '#encodeForHTMLAttribute( encodeForJavascript( itemLanguageKey ) )#' ) ){ alert( 'There are unsaved changes for \'#encodeForHTMLAttribute( encodeForJavascript( itemLanguageKey ) )#\'. Please save the changes before opening the server admin.' ); event.preventDefault(); };">View in Server Admin (Single-Mode)</button> 
										</form>
								
									<cfelse>

								
										<form action="lucee/admin/server.cfm?action=languageSwitcher&amp;reinit=true" method="POST" target="server_#encodeForHTMLAttribute( itemLanguageKey )#">
											<input type="hidden" name="lang" value="#encodeForHTMLAttribute( itemLanguageKey )#">
											<button  class="button" onClick="console.dir(window.langUpdater.updatedWithoutSaving);if( window.langUpdater.updatedWithoutSaving.includes( '#encodeForHTMLAttribute( encodeForJavascript( itemLanguageKey ) )#' ) ){ alert( 'There are unsaved changes for \'#encodeForHTMLAttribute( encodeForJavascript( itemLanguageKey ) )#\'. Please save the changes before opening the server admin.' ); event.preventDefault(); };">View in Server Admin (Multi-Mode)</button> 
										</form>

										<form action="lucee/admin/web.cfm?action=languageSwitcher&amp;reinit=true" method="POST" target="web_#encodeForHTMLAttribute( itemLanguageKey )#">
											<input type="hidden" name="lang" value="#encodeForHTMLAttribute( itemLanguageKey )#">
											<button  class="button" onClick="if( window.langUpdater.updatedWithoutSaving.includes( '#encodeForHTMLAttribute( encodeForJavascript( itemLanguageKey ) )#' ) ){ alert( 'There are unsaved changes for \'#encodeForHTMLAttribute( encodeForJavascript( itemLanguageKey ) )#\'. Please save the changes before opening the web admin.' ); event.preventDefault(); };">View in Web Admin  (Multi-Mode)</button> 
										</form>

									
									</cfif>

								
								</cfif>
								<button title="View/Paste JSON-Code #ucase( itemLanguageKey)#" class="button" onClick="window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=getJSONForm&amp;lang=#encodeForHTMLAttribute( encodeForJavascript( encodeForURL( itemLanguageKey ) ) )#', 'GET', undefined, '##modalMainContent', 'replaceInner' , function(){ $('.modalContainer').fadeIn() });">View/Add JSON (#ucase( itemLanguageKey )#)</button>
								
								<cfif itemLanguageKey !== "en">
									<button disabled class="button" onClick="if( confirm( 'Warning: This will remove the working file \'#encodeForHTMLAttribute( encodeForJavascript( LangEditorService.sanitizeFilename( itemLanguageKey ) & ".json") )#\'. Are you sure you want to proceed?' ) ){ window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=cleanWorkingDir&amp;lang=#encodeForHTMLAttribute( encodeForJavascript( encodeForURL( itemLanguageKey ) ) )#', 'GET', undefined, 'ajaxPopulateNotificationFlyingBar', 'reloadURLDelayed');}">Delete "#encodeForHTML( itemLanguageKey)#.json"</button>
								</cfif>
						</th>
					</cfloop>
				</tr>
			</thead>

			
			<tbody>
				<cfloop list="#adminKeyNameListOrdered#" item="itemLanguage" >
					<tr id="#itemLanguage#">
						<td class="keyName">
							#encodeForHTML( itemLanguage )# 
							<!--- Search needs to be adapted to be searchable in JSON --->
							<div class="propertyCommands">
								<a  title="Search '#encodeForHTMLAttribute( itemLanguage)#' in Lucee Admin Source" class="propertyCommandsButton viewSourceButton" href="#variables.LangEditorService.getGithubSourceSearchURL( itemLanguage )#" target="_blank"></a>
								<!---button title="Copy '#encodeForHTMLAttribute( itemLanguage)#' to Clipboard" class="propertyCommandsButton copyButton" href="#variables.LangEditorService.getGithubSourceSearchURL( itemLanguage )#" data-value="#encodeForHTMLAttribute( itemLanguage)#" onClick="window.langUpdater.copyToClipboard( $( this ).attr('data-value') );"></button--->
							
							</div>
						</td>
						<cfloop array="#availableLangResourceLanguage#" item="itemLanguageKey" >
							<td class="updateContainer-#ucase( itemLanguageKey )#">
								<cfset txtareaID="txtarea-#itemLanguageKey#-#replaceNoCase(itemLanguage, ".", "_", "All" )#">
								<textarea onChange="window.langUpdater.setEditionAsUnsaved('#encodeForHTMLAttribute(encodeForJavaScript( itemLanguageKey ))#')" <cfif !structKeyExists( langData[ itemLanguageKey ], itemLanguage ) or  trim( langData[ itemLanguageKey  ][ itemLanguage ] ) is "">class="isempty"</cfif> id="#encodeForHTMLAttribute( txtareaID )#" name="#encodeForHTMLAttribute( replaceNoCase(itemLanguage, ".", "~", "All" ) )#"><cfif structKeyExists( langData[ itemLanguageKey ], itemLanguage )>#encodeForHTML( langData[ itemLanguageKey ][ itemLanguage ] )#</cfif></textarea>
								<div class="propertyCommands">
								<button title="Get JSON-Code Snippet for '#encodeForHTMLAttribute( itemLanguage)# (#ucase( itemLanguageKey )#)'" class="propertyCommandsButton getJSONCode" onClick="window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=getJSONCodeSnippet&amp;lang=#encodeForHTMLAttribute( encodeForJavascript( encodeForURL( itemLanguageKey ) ) )#', 'POST', '###encodeForHTMLAttribute( encodeForJavascript( txtareaID ))#', '##modalMainContent', 'replaceInner' , function(){ $('.modalContainer').fadeIn() });"></button>
								</div>
							</td>
						</cfloop>
					</tr>
				</cfloop>
			</tbody>
			
		</table>
	</cfoutput>
</cfif>