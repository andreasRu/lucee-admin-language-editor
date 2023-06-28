<cfscript>
	
	if( structKeyExists( url, "method" )){

		LangEditorService=new components.LangEditorService();
		
		if( LangEditorService.getWorkingSpaceInMB() >= application.maxWorkingSizeMB ){

			result={};
			result["error"]=1;
			result["success"]=false;
			result["contentForHtmlOutput"]= "";
			result["ajaxPopulateNotificationFlyingBar"]= "At the moment there is no available workingspace left on this server!";
			LangEditorService.outputAsJson( result );
			abort;
		}

		

		if( url.method == "addProperty" and structKeyExists( form, "addPropertyName") ){

			workingData=LangEditorService.mapStructToDotPathVariable( LangEditorService.getWorkingDataForLanguageByLettercode("en").data );
			
			if( LangEditorService.createProperty( form.addPropertyName ) ){

				result={};
				result["error"]=0;
				result["success"]=true;
				result["contentForHtmlOutput"]= "";
				result["ajaxPopulateNotificationFlyingBar"]= "PropertyAdded. Reloading page!";

			}else{

				result={};
				result["error"]=1;
				result["success"]=false;
				result["contentForHtmlOutput"]= "";
				result["ajaxPopulateNotificationFlyingBar"]= "Key-Conflict detected: Property <i style=""color:red;"">#encodeForHTML( form.addPropertyName )#</i> not added.";


			}
			
			LangEditorService.outputAsJson( result );
			
		}
		

		if( url.method == "cleanWorkingDirAndPullResources" and structKeyExists( url, "lang") ){
			
			LangEditorService.cleanWorkingDirAndPullResources( url.lang );
		
			result={};
			result["error"]=0;
			result["success"]=true;
			result["contentForHtmlOutput"]= "";
			result["ajaxPopulateNotificationFlyingBar"]= "Resource Files pulled. Reloading page!";
			LangEditorService.outputAsJson( result );
		
		}


		if( url.method == "viewFileJSON" ){
			
			file= "#LangEditorService.workingDir##LangEditorService.sanitizeFilename( url.viewFileJSON)#.json"
			
			if(  fileExists( file ) ) {
				cfcontent( file=file type="application/json" );
			}else{
				cfheader( statuscode="404" statustext="Invalid Access" );
				echo("<html><body>404 Invalid Access</body></html>");
			}

		}


		if( url.method == "pullToAdmin" and structKeyExists( url, "lang") ){
			
			LangEditorService.pullResourceFileToWebAdmin( url.lang );
			
			result={};
			result["error"]=0;
			result["success"]=true;
			result["contentForHtmlOutput"]= "";
			result["ajaxPopulateNotificationFlyingBar"]= "Language file pushed to Web Administrator.";
			LangEditorService.outputAsJson( result );

		}

		

		if( url.method == "updateJsonWorkingFile" and structKeyExists( url, "adminLang") ){

			
			LangEditorService.createUpdateWorkingLanguageResourceFile( url.adminlang,  form );
			result={};
			result["error"]=0;
			result["success"]=true;
			result["contentForHtmlOutput"]= "";
			result["ajaxPopulateNotificationFlyingBar"]= "JSON-File '#encodeForHTML( url.adminlang )#.json' saved!";
			LangEditorService.outputAsJson( result );


		}

		if( url.method == "downloadFileJSON" and structKeyExists( url, "downloadLanguageJSONFile") ){
			
			LangEditorService.downloadFileJSON( url.downloadLanguageJSONFile );
		   
		}

		if( url.method == "cleanWorkingDir"){

			
			LangEditorService.cleanWorkingDir( url.lang?:"" );
			result={};
			result["error"]=0;
			result["success"]=true;
			result["contentForHtmlOutput"]= "";
			result["ajaxPopulateNotificationFlyingBar"]= "#(structKeyExists( url, "lang")?'File removed from working directory.':'Working Directory initialized!')# Reloading Page...";
			LangEditorService.outputAsJson( result );
			
		}


		if( url.method == "createUpdateWorkingLanguageResourceFile"){

			LangEditorService.createUpdateWorkingLanguageResourceFile( url.lang );
			result={};
			result["error"]=0;
			result["success"]=true;
			result["contentForHtmlOutput"]= "";
			result["ajaxPopulateNotificationFlyingBar"]= "Working Directory initialized! Reloading Page...";
			LangEditorService.outputAsJson( result );
			
		}

		if( url.method == "getJSONCodeSnippet" ){

			formfieldname=listFirst( form.fieldnames, ",")
			name=formfieldname.replaceNoCase( "~", ".", "All" );
			jsonSnippet=LangEditorService.getJSONCodeSnippet( name, form[ formfieldname ] );
			
			result["error"]=0;
			result["success"]=true;
			result["contentForHtmlOutput"]= "<textarea style=""width:80vw;max-width:900px;height:40vh;"" readonly>" & encodeForHTML( jsonSnippet ) & "</textarea>";
			LangEditorService.outputAsJson( result );
			
		}

		
		if( url.method == "getChatGPTPrompt" ){
			
			jsonSnippet=LangEditorService.getChatGPTPrompt( url.lang );
			result["error"]=0;
			result["success"]=true;
			result["contentForHtmlOutput"]= "<textarea name=""jsonEditor"" id=""jsonEditor"" style=""white-space: pre;overflow-wrap: normal;overflow-x: scroll;width:80vw;max-width:900px;height:40vh;"">" & encodeForHTML( jsonSnippet ) & "</textarea>";
			LangEditorService.outputAsJson( result );
			
		}


		if( url.method == "getJSONForm" ){

			jsonSnippet=LangEditorService.getFullJSON( url.lang );
			result["error"]=0;
			result["success"]=true;
			result["contentForHtmlOutput"]= "<textarea name=""jsonEditor"" id=""jsonEditor"" style=""white-space: pre;overflow-wrap: normal;overflow-x: scroll;width:80vw;max-width:900px;height:40vh;"">" & encodeForHTML( jsonSnippet ) & "</textarea>";
			result["contentForHtmlOutput"]= result["contentForHtmlOutput"] & "<button onClick=""if( confirm( 'Warning: This will overwrite the working file \'#encodeForHTMLAttribute( encodeForJavascript( LangEditorService.sanitizeFilename( url.lang ) & ".json") )#\'. Are you sure you want to proceed?' ) ){ window.langUpdater.myAjaxUtils.buildPayLoad( '/ajaxApi/ajaxLangService.cfm?method=saveJSONCodeSnippet&amp;lang=#encodeForHTMLAttribute( encodeForJavascript( encodeForURL( url.lang ) ) )#', 'POST', '##jsonEditor', '##modalMainContent', 'replaceInner' , function(){ $( '##loadingSpinner' ).show(); $('.modalContainer').hide();setTimeout(function(){window.location.reload();}, 2000); });};""> Save </button>";
			LangEditorService.outputAsJson( result );
			
		}


		if( url.method == "saveJSONCodeSnippet" ){
			
			if( structkeyExists( form, "jsonEditor" ) && isJSON( form.jsonEditor ) ){
				LangEditorService.saveJSON( url.lang, form.jsonEditor  );
				result["error"]=0;
				result["success"]=true;
				result["ajaxPopulateNotificationFlyingBar"]="Json saved as file. Reloading page...";
			}else{
				result["error"]=0;
				result["success"]=true;
				result["ajaxPopulateNotificationFlyingBar"]="Not a Json. Reloading page...";
			}
			result["contentForHtmlOutput"]= "";
			LangEditorService.outputAsJson( result );
			
		}

		
		


   
	}
	
</cfscript>