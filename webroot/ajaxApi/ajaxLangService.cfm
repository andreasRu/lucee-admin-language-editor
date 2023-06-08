<cfscript>
    
    


    if( structKeyExists( url, "method" )){

        LangEditorService=new components.LangEditorService();

       
        if( url.method == "cleanWorkingDirAndPullResources" and structKeyExists( url, "lang") ){
            
            LangEditorService.cleanWorkingDirAndPullResources( url.lang );
            result={};
            result["error"]=0;
            result["success"]=true;
            result["contentForHtmlOutput"]= "";
            result["ajaxPopulateNotificationFlyingBar"]= "Resource Files pulled. Reloading page!";
            LangEditorService.outputAsJson( result );


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
            result["contentForHtmlOutput"]= "<textarea style=""width:80vw;max-width:900px;height:6rem;"" readonly>" & encodeForHTML( jsonSnippet ) & "</textarea>";
            LangEditorService.outputAsJson( result );
            
        }

        


   
    }
    
</cfscript>