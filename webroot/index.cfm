<!DOCTYPE html>
	<html lang="en">
	<head>
		 <meta charset="UTF-8">
		 <meta name="viewport" content="width=device-width, initial-scale=1">
		 <meta http-equiv="X-UA-Compatible" content="ie=edge">
		 <meta name="description" content="An online editor for adding languages to the Lucee6 Administrator.">
		 <meta name="robots" content="index,follow">
		 <meta property="og:url" content="https://lucee-lang-editor.rhein-berg-digital.de/">
		 <meta property="og:title" content="Lucee Admin Language Editor">
		 <meta property="og:type" content="website">
		 <meta property="og:site_name" content="Lucee Admin Language Editor">
		 <meta property="og:description" content="An online editor for adding languages to the Lucee6 Administrator.">
	 
		 <cfoutput>

        <head>
            <meta charset="utf-8">
            <link rel="stylesheet" href="/css/animate.min.css?version=#hash(application.appversion)#" />
            <link rel="stylesheet" href="/css/app.css?version=#hash(application.appversion)#" />
            <link rel="stylesheet" href="/css/spinner.css?version=#hash(application.appversion)#" />
            <title>#encodeForHTML( application[ "appTitleName" ] )#</title>
        </head>

        <body>
            <!--- initialize LangEditor Component --->
            <cfset variables.LangEditorService=new components.LangEditorService() />
			
			<cfset variables.langData=LangEditorService.parseDataForTableOutput( LangEditorService.getFullWorkingData( ) ) />
		
            <!--- get languages of resource files available in working folder --->
            <cfset variables.availableLangResourceLanguage=LangEditorService.getLanguagesAvailableInWorkingData() />
            <!--- get all available Language resources from Java for new langcreation--->
            <cfset variables.availableJavaLocales=LangEditorService.getAvailableJavaLocalesAsStruct() />

            <div class="header">
                <a href="/" target="_self" >
					<h1>#encodeForHTML( application[ "appTitleName" ] )#</h1>
				</a>
                <h3 class="headingInfo"><i><div class="CFML">CF<span class="thunder">&##x26a1;</span>ML</div><div style="display:inline-block;position: relative;top: -0.24rem;left: 0.4rem;">rocks more than ever! Let's internationalize Lucee's 6.0 Administrator!</div></i></h3>
				<cfif variables.LangEditorService.runningOnlineProductionMode>
					<div class="linkContainer">
						<a href="https://github.com/andreasRu/lucee-admin-language-editor/graphs/contributors" rel="nofollow" class="defaultLink"  target="_blank">Contributors</a>
						| <a href="https://github.com/andreasRu/lucee-admin-language-editor/" rel="nofollow" class="defaultLink"  target="_blank">Github</a>
						| <a href="https://www.rhein-berg-digital.de/en/lucee-admin-lang-editor-imprint" class="defaultLink" rel="nofollow" target="_blank">Imprint</a> 
						| <a href="https://www.rhein-berg-digital.de/en/lucee-admin-lang-editor-privacy-policy" rel="nofollow" class="defaultLink"  target="_blank">Privacy Policy</a>
						</div>
                </cfif>
				<div class="commandDivWrapper">
                    <cfif len( availableLangResourceLanguage ) < application.maxFileCountInWorkingDir>
						<div class="commandDiv">
							<select name="selectLangResource" id="selectLangResource">
								<cfset variables.langInSources=LangEditorService.getAvailableLanguagesInGitSource() />
								<option value="">Select resource file</option>
								<cfloop array="#variables.langInSources.langEditor#" item="letterCode">
									<option value="#encodeForHTMLAttribute( letterCode )#">#encodeForHTML(
										structKeyExists( availableJavaLocales,
										letterCode)?availableJavaLocales[ letterCode ]:letterCode )#
										(#encodeForHTML( letterCode )#.json)</option>
								</cfloop>
							</select>
							<br>
							<button disabled class="button" onClick="var lang=$('##selectLangResource').val();availableLangs=#encodeForHTMLAttribute( serializeJSON( availableLangResourceLanguage ) )#;if(lang==''){$('##selectLangResource').css({'border':'2px dotted red'})}else{ if( !availableLangs.includes( lang ) || confirm( 'Warning: This will download and overwrite any existing \'' + lang + '.json\' file in the working directory. Are you sure you want to proceed?'  ) ){ window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=cleanWorkingDirAndPullResources&amp;lang='+ lang, 'GET', undefined, 'ajaxPopulateNotificationFlyingBar', 'reloadURLDelayed');}}">Pull
								Latest From github</button>
						</div>
					</cfif>

					
                    <cfif len( availableLangResourceLanguage ) < application.maxFileCountInWorkingDir>

                        <div class="commandDiv">
                            <select name="selectCreateLangResource" id="selectCreateLangResource">
                                <option value="">Start from scratch</option>
                                <cfloop collection="#variables.availableJavaLocales#" item="letterCode">
                                    <cfif !langInSources.langEditor.contains( lettercode ) && !availableLangResourceLanguage.contains( lettercode )>
                                        <option value="#encodeForHTMLAttribute( letterCode )#">
                                            #encodeForHTML( structKeyExists( availableJavaLocales,
                                            letterCode)?availableJavaLocales[ letterCode ]:letterCode )#
                                            (#encodeForHTML( letterCode )#.json)</option>
                                    </cfif>
                                </cfloop>
                            </select>
                            <br>
                            <button disabled class="button" onClick="var lang=$('##selectCreateLangResource').val();availableLangs=#encodeForHTMLAttribute( serializeJSON( availableLangResourceLanguage ) )#;if(lang==''){$('##selectCreateLangResource').css({'border':'2px dotted red'})}else{ if( !availableLangs.includes( lang ) || confirm( 'Warning: This will create and overwrite any existing \'' + lang + '.json\' file in the working directory. Are you sure you want to proceed?'  ) ){ window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=createUpdateWorkingLanguageResourceFile&amp;lang='+ lang, 'GET', undefined, 'ajaxPopulateNotificationFlyingBar', 'reloadURLDelayed');}}">Initialize
                                File</button>
                        </div>
                    </cfif>


                    <cfif !arrayIsEmpty( availableLangResourceLanguage )>
                        <div class="commandDiv">
                            <button disabled class="button enhanced" onClick="if( confirm( 'Warning: This will remove all working files from the working directory and changes will be lost forever. Are you sure you want to proceed?' ) ){ window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=cleanWorkingDir', 'GET', undefined, 'ajaxPopulateNotificationFlyingBar', 'reloadURLDelayed');}">ReInitialize!</button>
                      	</div>
						
                    </cfif>

                    

					<div class="commandDiv">
                        <div style="position: relative;top:-2px;white-space:normal;">Get the latest Beta LanguagePack-Plugin:<br>English, German, Spanish.</div>
                        <div>
							<a class="button" href="https://github.com/andreasRu/lucee-admin-language-editor/raw/master/extension/F1A3EEAF-5B7A-499C-9656DE3E103C8EA9.lex" target="_blank">Download Extension (beta)</a>
						</div>
                    </div>

					<!---div class="commandDiv">
                        <div style="position: relative;top:-2px;">Contributors:</div>
                        <div>
                            <cfloop index="i" from="1" to="#arrayLen( application.contributors )#">
								<a class="contributors" href="#encodeForHTMLAttribute( application.contributors[i]["html_url"] )#" target="_blank" title="#encodeForHTML( application.contributors[i]["login"] )#"><img src="#encodeForHTMLAttribute( variables.LangEditorService.contribTempPath & application.contributors[i]["login"] )#.png"></a>
                            </cfloop>
							
                        </div>
                    </div--->



                    <cfif !variables.LangEditorService.runningOnlineProductionMode && server.lucee.version gt "6">

                        <div class="commandDiv lastPullRight" style="background: transparent;color:##b2aeae;">
                            <div>
                                <cfset variables.generatedPWD=variables.LangEditorService.getPasswordFromPasswordTXT() />
                                <cfif variables.generatedPWD !="">
                                    <div style="margin-bottom: 0.2rem;">
                                        <div>Generated Lucee Password(password.txt):</div>
                                        <div>
                                            <b>
                                                <pre style="display:inline-block;margin:0 0.1rem 0;">#encodeForHTML( variables.generatedPWD )#</pre>
                                            </b>
                                            <button style="display:inline-block;background: transparent;margin: 0;" title="Copy password to Clipboard" class="propertyCommandsButton copyButton" data-value="#encodeForHTMLAttribute( variables.generatedPWD )#" onclick="window.langUpdater.copyToClipboard( $( this ).attr('data-value') );"></button>
                                            <form style="display:inline-block;margin:0 0.1rem 0;" action="/lucee/admin/server.cfm" method="post" target="_blank">
                                                <input type="hidden" name="checkPassword" value="true">
                                                <input class="button submit" type="submit" name="submit" value="Import password.txt">
                                            </form>
                                        </div>
                                    </div>
                                </cfif>
                            </div>

                        </div>
                </div>
                </cfif>


            </div>

            </div>

            <cfinclude template="htmlTable.cfm" />

            <span id="forkongithub">
                <a href="https://github.com/andreasRu/lucee-admin-language-editor" target="_blank">Fork me
                    on GitHub</a>
            </span>

            <cfif !arrayIsEmpty( availableLangResourceLanguage )>
                <div class="scrollUpButton" onClick="window.scrollTo({ top: 0 });">&##8679;</div>
            </cfif>

            <div id="modalContainer" class="modalContainer" onClick="e = window.event || e; if(this === e.target) { $( this ).hide(); }">
                <div class="modalMainWrapper" class="modalMain">
                    <button onClick="$('##modalContainer').hide();" class="modalButton">X</button>
                    <div id="modalMainContent" class="modalMainContent"></div>
                </div>
            </div>

            <div id="ajaxPopulateNotificationFlyingBar" class="animated hidden">
                <div></div>
            </div>

            <div id="loadingSpinner">
                <div class="sk-chase">
                    <div class="sk-chase-dot"></div>
                    <div class="sk-chase-dot"></div>
                    <div class="sk-chase-dot"></div>
                    <div class="sk-chase-dot"></div>
                    <div class="sk-chase-dot"></div>
                    <div class="sk-chase-dot"></div>
                </div>
            </div>


            <script type="text/javascript" src="/js/distro/jsbundle.js?version=#hash(application.appversion)#"></script>
            <script type="text/javascript" src="/js/distro/vendors.js?version=#hash(application.appversion)#"></script>
            <script>
            
            /**  create a MutationObserver for ajaxPopulateNotificationFlyingbar: This is the flying Bar that
             *	is shown for a feedback 
             *	More Details https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver  
             **/
            /*  select the target node */
            var target = document.querySelector("##ajaxPopulateNotificationFlyingBar div");
            /* create an observer instance */
            var observer = new MutationObserver(function(mutations) {
                $('##ajaxPopulateNotificationFlyingBar').removeClass('fadeOutLeft').removeClass('hidden').addClass(
                    'fadeInLeft');
                setTimeout(function() {
                    $('##ajaxPopulateNotificationFlyingBar').removeClass('fadeInLeft').addClass(
                        'fadeOutLeft').addClass('hidden');
                }, 5000);
            });
            /* configuration of the observer: */
            var config = {
                attributes: true,
                childList: true,
                characterData: true
            };
            /* pass in the target node, as well as the observer options */
            observer.observe(target, config);

            $('button').prop('disabled', false);
            </script>

        </body>
    </cfoutput>

</html>