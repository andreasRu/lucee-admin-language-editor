<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<cfoutput>
    <link rel="stylesheet" href="/css/animate.min.css?version=#hash(application.appversion)#" />
    <link rel="stylesheet" href="/css/app.css?version=#hash(application.appversion)#" />
    <link rel="stylesheet" href="/css/spinner.css?version=#hash(application.appversion)#" />
</cfoutput>
</head>

<body>

   
<cfoutput>

    <!--- initialize LangEditor Component --->
    <cfset variables.LangEditorService=new components.LangEditorService()>
    <cfset variables.langData= LangEditorService.parseDataForTableOutput( LangEditorService.getFullWorkingData( ) )>
    <cfset variables.availableLangResourceLanguage=LangEditorService.getLanguagesAvailableInWorkingData()>
    <!---cfset variables.LangEditorService.convertXMLLanguageToJson("es")--->
    

    <!--- Pull en.json from github if not in working directory --->
    <cfif !arrayContains( variables.availableLangResourceLanguage, "en")>
        <cfset variables.LangEditorService.pullLangResourcesFromGithubToWorkingDirectory("en")>
        <cflocation URL="index.cfm">
    </cfif>
    
    <!--- sort keynames for output --->
    <cfset variables.adminKeyNameListOrdered=langData["en"].keylist().listSort( "textnocase" )>
    <!--- get languages of resource files available in working folder --->
    <cfset variables.availableLangResourceLanguage=LangEditorService.getLanguagesAvailableInWorkingData()>
    <h1>
       Lucee Admin Language Editor #encodeForHTML(  variables.LangEditorService.version )#
    </h1>
   
    <div class="commandDivWrapper">
        <cfset variables.availableJavaLocales=LangEditorService.getAvailableJavaLocalesAsStruct()>
               
        <div class="commandDiv">
            <select name="selectLangResource" id="selectLangResource">
                <cfset variables.langInLuceeSourceArray=LangEditorService.getAvailableLanguagesInLuceeGitSource()>
                <option value="">Select resource file</option>
                <cfloop array="#variables.langInLuceeSourceArray#" item="letterCode">
                    <option value="#encodeForHTMLAttribute( letterCode )#">#encodeForHTML( structKeyExists( availableJavaLocales, letterCode)?availableJavaLocales[ letterCode ]:letterCode )# (#encodeForHTML( letterCode )#.json)</option>
                </cfloop>
            </select>
            <br>
            <button disabled class="button" onClick="var lang=$('##selectLangResource').val();if(lang==''){$('##selectLangResource').css({'border':'2px dotted red'})}else{ if( confirm( 'Warning: This will download and overwrite any existing \'' + lang + '.json\' file in the working directory. Are you sure you want to proceed?'  ) ){ window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=cleanWorkingDirAndPullResources&lang='+ lang, 'GET', undefined, 'ajaxPopulateNotificationFlyingBar', 'reloadURLDelayed');}}">Pull From Lucee at github</button>
        </div>

        <div class="commandDiv">
            <select name="selectCreateLangResource" id="selectCreateLangResource">
                <option value="">Start from scratch</option>
                <cfloop collection="#variables.availableJavaLocales#" item="letterCode">
                    <cfif !langInLuceeSourceArray.contains( lettercode ) && !availableLangResourceLanguage.contains( lettercode ) >
                        <option value="#encodeForHTMLAttribute( letterCode )#">#encodeForHTML( structKeyExists( availableJavaLocales, letterCode)?availableJavaLocales[ letterCode ]:letterCode )# (#encodeForHTML( letterCode )#.json)</option>
                    </cfif>
                </cfloop>
            </select>
            <br>
            <button disabled class="button" onClick="var lang=$('##selectCreateLangResource').val();if(lang==''){$('##selectCreateLangResource').css({'border':'2px dotted red'})}else{ if( confirm( 'Warning: This will create and overwrite any existing \'' + lang + '.json\' file in the working directory. Are you sure you want to proceed?'  ) ){ window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=createUpdateWorkingLanguageResourceFile&lang='+ lang, 'GET', undefined, 'ajaxPopulateNotificationFlyingBar', 'reloadURLDelayed');}}">Initialize File</button>
        </div>
        <cfif !arrayIsEmpty( availableLangResourceLanguage )>
            <div class="commandDiv">
                <button disabled class="button" onClick="if( confirm( 'Warning: This will remove all working files from the working directory and changes will be lost forever. Are you sure you want to proceed?' ) ){ window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=cleanWorkingDir', 'GET', undefined, 'ajaxPopulateNotificationFlyingBar', 'reloadURLDelayed');}" style="white-space:normal;">Reset WorkingDirectory</button>
            
            </div>
        </cfif>
        
        <div class="commandDiv lastPullRight" style="background: transparent;color:black;">
            <div>
                <cfset variables.generatedPWD=variables.LangEditorService.getPasswordFromPasswordTXT()>
                <cfif variables.generatedPWD != "" >
                    <div style="margin-bottom: 0.2rem;">
                        <div>Generated Lucee Password(password.txt):</div>
                        <div>
                            <b><pre style="display:inline-block;margin:0 0.1rem 0;">#encodeForHTML( variables.generatedPWD )#</pre></b>
                            <button style="display:inline-block;background: transparent;margin: 0;" title="Copy password to Clipboard" class="propertyCommandsButton copyButton" data-value="#encodeForHTMLAttribute( variables.generatedPWD )#" onclick="window.langUpdater.copyToClipboard( $( this ).attr('data-value') );"></button>
                            <form style="display:inline-block;margin:0 0.1rem 0;" action="/lucee/admin/server.cfm" method="post" target="_blank">
                                <input type="hidden" name="checkPassword" value="true">
                                <input class="button submit" type="submit" name="submit" value="Import password.txt">
                            </form>
                        </div>
                    </div>
                </cfif>
                <div style="font-style: italic;max-height:3rem;overflow-y:scroll;background:white;font-size:0.6rem;overflow-wrap:anywhere;">
                        
                        <cfif len( variables.LangEditorService.loadedAdminFiles[ "languagesPulledToAdmin" ] ) >
                            <b style="color:red;">Files&nbsp;deployed&nbsp;to&nbsp;Lucee&nbsp;Admin on last load:</b><br>
                            <cfloop collection="#variables.LangEditorService.loadedAdminFiles[ "languagesPulledToAdmin" ]#" item="currentKey">
                                <b>#currentKey#.json:</b>&nbsp;#variables.LangEditorService.loadedAdminFiles["languagesPulledToAdmin"][ currentKey ]#<br>
                            </cfloop>
                        </cfif>
                        <b style="color:red;">Files&nbsp;deployed&nbsp;to&nbsp;Lucee&nbsp;Admin during initialization:</b><br>
                        <b>password.txt:</b>&nbsp;#variables.LangEditorService.loadedAdminFiles["adminPasswordTxtLocation"]#<br>
                        <b>langSwitcher.cfm:</b>&nbsp;#variables.LangEditorService.loadedAdminFiles["langSwitcherInjectedLocation"]#<br>
                        <b>admin_layout.cfm:</b>&nbsp;#variables.LangEditorService.loadedAdminFiles["adminLayoutInjectedLocation"]#<br>
                       
                    </div>
                
             </div>
                       
            </div>
        </div>

        
    </div>

    <cfif !arrayIsEmpty( availableLangResourceLanguage )>
        <table class="langEditor">
            <thead>
                <tr>
                    <th>Property</th>
                    <cfloop array="#availableLangResourceLanguage#" item="itemLanguageKey" >
                        <th>
                            #encodeForHTML( structKeyExists( availableJavaLocales, itemLanguageKey)?availableJavaLocales[ itemLanguageKey ]:"" )#</div>
                            #encodeForHTML( itemLanguageKey )#.json
                            <cfif itemLanguageKey == "en">(default)</cfif>
                                <button disabled class="button enhanced" id="save_#encodeForHTMLAttribute( itemLanguageKey )#" onClick="window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=updateJsonWorkingFile&amp;adminLang=#itemLanguageKey#', 'POST', '.updateContainer-#ucase(itemLanguageKey)# textarea', '##ajaxPopulateNotificationFlyingBar', 'reloadURLDelayed' );">Save Changes to "#itemLanguageKey#.json"<br> &amp; push to Admin </button>
                                <a class="button" href="#encodeForHTMLAttribute( "/workingDir/" & encodeforURL( itemLanguageKey ) & ".json")#" target="_blank">View File JSON-Source</a>
                                <a class="button" href="#encodeForHTMLAttribute( "/ajaxApi/ajaxLangService.cfm?method=downloadFileJSON&downloadLanguageJSONFile=" & encodeforURL( itemLanguageKey ) )#" target="_blank">Download File For PR</a>
                                <cfif getApplicationSettings().singleContext >
                                    
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
    </cfif>

    <span id="forkongithub">
        <a href="https://github.com/andreasRu/lucee-admin-language-editor" target="_blank">Fork me on GitHub</a>
    </span>

    <cfif !arrayIsEmpty( availableLangResourceLanguage )>
        <div class="scrollUpButton" onClick="window.scrollTo({ top: 0 });">&##8679;</div>
    </cfif>

    <div id="modalContainer" class="modalContainer" onClick="e = window.event || e; 
    if(this === e.target) {
        $( this ).hide();
    }">
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
    /* call floatThead for fixed table head */ 
     $(function(){
            $('table').floatThead({
                position: 'fixed'
            });
        });


    /**  create a MutationObserver for ajaxPopulateNotificationFlyingbar: This is the flying Bar that
    *    is shown for a feedback 
    *    More Details https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver  
    **/
    /*  select the target node */
    var target = document.querySelector("##ajaxPopulateNotificationFlyingBar div");
    /* create an observer instance */
    var observer = new MutationObserver(function(mutations) {
        $( '##ajaxPopulateNotificationFlyingBar' ).removeClass( 'fadeOutLeft' ).removeClass( 'hidden' ).addClass( 'fadeInLeft' );
        setTimeout(function(){ 
            $( '##ajaxPopulateNotificationFlyingBar' ).removeClass( 'fadeInLeft' ).addClass( 'fadeOutLeft' ).addClass( 'hidden' );
            }, 5000);
    });
    /* configuration of the observer: */
    var config = { attributes: true, childList: true, characterData: true };
    /* pass in the target node, as well as the observer options */
    observer.observe(target, config);

    $('button').prop('disabled', false);
    </script>
</cfoutput>


</body></html>




