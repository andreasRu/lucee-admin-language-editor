/**********************************************************
*  LangEditorService.cfc: 
*  A component used for creating and editing the language 
*  resource XML files used in the Lucee administrator.
*  License: MIT License  
*  (c)2023 C. Andreas Rüger
*  https://github.com/andreasRu/lucee-admin-language-editor
************************************************************/

component {


    public struct function init( ){
        
        this.version=application.appversion;
        this.luceeSourceUrl="https://raw.githubusercontent.com/lucee/Lucee/6.0";
        this.workingDir = "/workingDir/";
        if ( !directoryExists( ".." & this.workingDir ) ){
            directoryCreate( ".." & this.workingDir );
        }
        this.adminResourcePath=getServerWebContextInfoAsStruct()["servletInitParameters"]["lucee-web-directory"] & "/context/admin";
        this.adminServerContextPath=getServerWebContextInfoAsStruct()["servletInitParameters"]["lucee-server-directory"] & "/lucee-server/context";
        this.loadedAdminFiles = deploySwitcherFilesToLuceeAdmin();

        return this;
    }

    /*********  
    *
    *  An alternative encoding of encodeForXML (specifically XML 1.0) simplified
    *  See: https://stackoverflow.com/a/28152666/2645359 https://www.w3.org/TR/xml/#syntax
    *
    *********/
    public string function encodeXML( string value required ) localmode=true {
        
        result=replace( arguments.value, "&", "&amp;", "All"); // this MUST go first!!!
        result=replace( result, "<", "&lt;", "All");
        result=replace( result, ">", "&gt;", "All");
        // apostrophes and quotes are allowed in tag bodies (values), so lets add it, 
        // so the same function may be used for attributes
        result=replace( result, """", "&quot;", "All");
        result=replace( result, "'", "&apos;", "All");
        
        return result;
    }

     /*********  
    *
    *  Create a languageSwitcher for fast access loading the language file in the logged in Admin
    *
    *********/
    public struct function deploySwitcherFilesToLuceeAdmin( ) localmode=true {

        result={};
        result[ "languagesPulledToAdmin" ]={};
        languagesArray=getLanguagesAvailableInWorkingData();

        // this is done on each init, but only if languageSwitcher has not been deployed already
        if ( !fileExists( this.adminResourcePath & "/languageSwitcher.cfm" ) ){

            fileCopy(   source= expandPath("./") & "adminDeploy/languageSwitcher.cfm", 
            destination=this.adminResourcePath & "/languageSwitcher.cfm" );

            fileCopy(   source= expandPath("./") & "adminDeploy/admin_layout.cfm", 
            destination=this.adminResourcePath & "/admin_layout.cfm" );

            fileCopy(   source= "https://raw.githubusercontent.com/lucee/Lucee/5.3/core/src/main/cfml/context/admin/resources/text.cfm", 
            destination=this.adminResourcePath & "/resources/text.cfm" );

            createPasswordFile();

            fileCopy(   source= expandPath("./") & "adminDeploy/password.txt", 
            destination=this.adminServerContextPath & "/password.txt" );
           
        }

        // this is done on each init, and on load
        for ( language in languagesArray ){

            fileCopy(   source= this.workingDir & "#sanitizeFilename( language )#.xml", 
            destination=this.adminResourcePath & "/resources/language/#sanitizeFilename( language )#.xml" );
            result[ "languagesPulledToAdmin" ][ language ]= this.adminResourcePath & "/resources/language/#sanitizeFilename( language )#.xml";
         }

        result[ "langSwitcherInjectedLocation" ] = this.adminResourcePath & "/languageSwitcher.cfm";
        result[ "adminLayoutInjectedLocation" ] = this.adminResourcePath & "/admin_layout.cfm";
        result[ "adminLayoutInjectedLocation" ] = this.adminResourcePath & "/resources/text.cfm";
        result[ "adminPasswordTxtLocation" ] = this.adminServerContextPath & "/password.txt";


        return result;

    }

   
    public void function createPasswordFile() localmode=true {
        if( !fileExists( expandPath("./") & "adminDeploy/password.txt" )){
            allowedChars="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890"   
            randomStr="";
            for (i = 1; i < 10 ; i++) {
                randomStr=randomStr & mid( allowedChars, randRange( 1, len( allowedChars ) ),1);
            }
            fileWrite( expandPath("./") & "adminDeploy/password.txt",  randomStr, "utf-8" );
        }
    }


    public string function getPasswordFromPasswordTXT() localmode=true {
        if( fileExists( expandPath("./") & "adminDeploy/password.txt" )){
            result=fileRead( expandPath("./") & "adminDeploy/password.txt", "utf-8" );
        }else{
            result=""
        }
        return result;
    }

    
    public string function getXMLCodeSnippet( required string dataPropertyName, required string dataPropertyValue  ) localmode=true {
           
            result="";
            
            if( arguments.dataPropertyValue != "" ){
                    result="<data key=""" & encodeXML( dataPropertyName ) & """>" & encodeXML( dataPropertyValue ) & "</data>";
                }else{
                    result="";
            }
        
            return result;

    }


    /**
    * returns a struct with the server/web context information that is bound to this template.
    */
    public struct function getServerWebContextInfoAsStruct() localmode=true {

        //get pageContext/CFMLFactoryConfig of actual template
        local.pageContext=getpagecontext();
        local.pageCFMLFactory=local.pageContext.getCFMLFactory();
        local.pageCFMLFactoryConfig=local.pageCFMLFactory.getConfig();

        //get the Servlets configuration and initial Parameters (e.g. set in Tomcats conf/web.xml)
        local.servletConfig = getpagecontext().getServletConfig();
        local.servletInitParamNames = servletConfig.getInitParameterNames();

        // populate struct with gathered information
        local.info={
                "context-label" : getpagecontext().getCFMLFactory().getLabel(),
                "configFileLocation" : pageCFMLFactoryConfig.getConfigFile(),
                "servletInitParameters": [:]
                };

        // if available, iterate enum of InitParamNames and get the values

        cfloop( collection="#servletInitParamNames#" item="item" ){

            structInsert( local.info["ServletInitParameters"] , item, local.servletConfig.getInitParameter( item.toString() ) );
        };


        return local.info;
    }

    
    public string function outputAsJson( struct data required) localmode=true  {
        cfcontent( reset = "true" );
        cfheader( name="content-type", value="application/json");
  	    echo( serializeJSON( arguments.data ) );
  	    cfabort;  
    }

    
    /**
	 * get languages of resource files available in working folder 
	 */
	public array function getLanguagesAvailableInWorkingData( ) localmode=true {
        result=[];
        result= listToArray( StructKeyList( getFullWorkingData() ) );
        if( !result.isEmpty() ){
            result.delete("en");
            result.prepend('en');
        }
        return result;
    }


    
    /**
	 * returns a hardcoded lettercode list of available lang resources available at
     * at: https://raw.githubusercontent.com/lucee/Lucee/6.0/core/src/main/cfml/context/admin/resources/language/
	 */
	
    public array function getAvailableLanguagesInLuceeGitSource() {
        
        return [ "de","en","nl","ch-be","es" ];
    }

   

   

    /**
	 * Loads the default English xml file and updates the inner data by RegEx-Replacements
     * in order to keep comments and order of the original English default file as it is.
	 */
    public void function createUpdateWorkingLanguageResourceFile( string languageCode required,  struct formObject ) localmode=true {

        //make sure an english version exists
        if( !fileExists( this.workingDir & "en.xml") ){ 
            if( !fileExists(  this.workingDir & "en.xml") ){ 
                pullLangResourcesFromGithubToWorkingDirectory( "en" );
            }
           
        }
        
        dataXML= getWorkingDataForLanguageByLettercode( "en" );
        
        // languageTagName=getAvailableJavaLocalesAsStruct(); // not used?
        StructUpdate( dataXML[ "xmlRoot" ][ "XmlAttributes" ], "key", arguments.languageCode );
        StructUpdate( dataXML[ "xmlRoot" ][ "XmlAttributes" ], "label", getAvailableJavaLocalesAsStruct()[ arguments.languageCode] );
        
        // Read original content from english file
        masterXMLFileContent=fileRead( this.workingDir & "en.xml" );
        
        // Strip Comment
        if( arguments.languageCode!="en" ){ 
            masterXMLFileContent=replaceNoCase( masterXMLFileContent, "<!-- this file contains the English/default language definition for the Admin March-2013 !-->","" )
        }

        // get the data content of the file
        refindArray= masterXMLFileContent.refind("(?m)<language .*?>(.*)?</language>?",1,true, "all");
        if( refindArray[1]["len"][1] gt 0 ){
            dataKeysXMLCode=refindArray[1]["match"][2];
        }else{
            // original has no data, set content as empty string
            dataKeysXMLCode="";
        }

        // iterate formobject and replace the data
        if( structKeyExists( arguments, "formObject") ){
            KeyNames= arguments.formObject.fieldnames;
            for( name in local.KeyNames ){

                keyName=replaceNoCase( name, "~", ".", "All" );
                keyNameAsRegex=replaceNoCase( name, "~", "\.", "All" );
                regex="(?m)<data key=""" & keyNameAsRegex & """.*?>.*?</data>";
                replaceStringWith=getXMLCodeSnippet( keyName, form[ name ] ); 
                dataKeysXMLCode=reReplaceNoCase( dataKeysXMLCode, regex, replaceStringWith );
       
                }
        }

        
        savecontent variable="xmlCode"{ 
            echo( "<?xml version=""1.0"" encoding=""UTF-8""?>" & chr(10) & 
                "    <!-- File generated by Lucee Admin Language Editor " & this.version & " (Please visit: https://github.com/andreasRu/lucee-admin-language-editor) -->" & chr(10) & 
                "        <language key=""" & encodeXML( dataXML.XmlRoot.XmlAttributes.key ) & """ label=""" & encodeXML( dataXML.XmlRoot.XmlAttributes.label ) & """>" & chr(10) & 
                                    dataKeysXMLCode & chr(10) & 
                "        </language>"
            )
        }

        fileWrite( this.workingDir & "#sanitizeFilename( arguments.languageCode )#.xml",  xmlCode, "utf-8" );
        
        pullResourceFileToWebAdmin( arguments.languageCode );
        
    }

    
    
    public any function downloadFileXML( string languageCode required ) localmode=true {
    
        if( fileExists( this.workingDir & sanitizeFilename( arguments.languageCode ) & ".xml") ){
            cfheader( 
                name="Content-Disposition", 
                value="attachment; filename=#sanitizeFilename( arguments.languageCode )#.xml"
            );
            cfcontent( 
                type = "text/xml", 
                file = this.workingDir & sanitizeFilename( arguments.languageCode ) & ".xml",
                deleteFile = "no" 
            );
        }
        
    }

    

    /**
	 * returns XML data of an imported language resource file as a struct
	 */
	public struct function parseXMLDataToStruct( struct XMLData required ) localmode=true {
		parsedXMLResult=[:];
        parsedXMLResult["XmlRoot.XmlComment"]=arguments.XMLData.XmlRoot.XmlComment;
		parsedXMLResult["XmlRoot.XmlAttributes.key"]=arguments.XMLData.XmlRoot.XmlAttributes.key;
		parsedXMLResult["XmlRoot.XmlAttributes.label"]=arguments.XMLData.XmlRoot.XmlAttributes.label;
		parsedXMLResult["XmlRoot.XmlAttributes.KeyData"]={};
		loop array="#arguments.XMLData.XmlRoot.XmlChildren#" index="itemChildrenKey" {

		 	keyName=itemChildrenKey["XmlAttributes"]["key"];
		 	parsedXMLResult["XmlRoot.XmlAttributes.KeyData"][ keyName ]=itemChildrenKey.XmlText;

		}

		return parsedXMLResult;
	}

	
	/**
	 * returns as struct of all available 2-letter codes of the underlying java.util with the referring Language DisplayName (target language)
	 */
	public struct function getAvailableJavaLocalesAsStruct() localmode=true {

		// Get Locale List
		JavaLocale = CreateObject("java", "java.util.Locale");
		availableJavaLocalesArray=JavaLocale.getAvailableLocales();
        //dump( JavaLocale );
		//dump( availableJavaLocalesArray );

        // initialize an ordered struct with shorthand [:]
       
		availableJavaLocalesStruct ={};
        cfloop( array= "#availableJavaLocalesArray#" item="itemLocale" ){
            //echo( dump( [ itemLocale.toLanguageTag(), itemLocale.getDisplayName(), itemLocale.getISO3Language() ] ) );
			if( len( itemLocale.toLanguageTag() ) == 2 )  {
				displayNameTargetLanguage=itemLocale.info();
				    availableJavaLocalesStruct[itemLocale.toLanguageTag()] = UcFirst( displayNameTargetLanguage["display"]["language"] );
				}	 
		}
        // sort by locale;
        result=[:];
        availableJavaLocalesSortedArray=structSort(availableJavaLocalesStruct);
        for( localeLanguage in availableJavaLocalesSortedArray){
            result.insert( localeLanguage, availableJavaLocalesStruct[ localeLanguage ] );
        }
        
        return result;

	}


    /**
	 * copies all known language resource files from Lucees github source to working directory
	 */
	public void function pullLangResourcesFromGithubToWorkingDirectory( string lang required ) localmode=true {

        for ( language in listToArray( arguments.lang ) ) { 
            fileCopy(   source="#this.luceeSourceUrl#/core/src/main/cfml/context/admin/resources/language/#language#.xml", 
            destination=this.workingDir & "#language#.xml" );
        }

        if( !fileExists(  this.workingDir & "en.xml" ) ){ 
            fileCopy( 
            source="#this.luceeSourceUrl#/core/src/main/cfml/context/admin/resources/language/en.xml", 
            destination= this.workingDir & "en.xml" );
        }
    }

    

    
    public void function pullResourceFileToWebAdmin( string language required ) localmode=true {

        adminResourceLanguagePath= this.adminResourcePath & "/resources/language"
        if( fileExists(  this.workingDir & "#sanitizeFilename( arguments.language )#.xml") ){ 

            fileCopy( 
                source=this.workingDir & "#sanitizeFilename( arguments.language )#.xml", 
                destination="#adminResourceLanguagePath#/#sanitizeFilename( arguments.language )#.xml" 
            );

        }
        
    }


    
    public string function sanitizeFilename( string filename required ) localmode=true {
        return reReplaceNoCase( arguments.filename, "[^a-zA-Z0-9\-]", "", "ALL" );
    }

    
   
   public array function getAvailableLangLocalesInWorkingDir() localmode=true {

        cfdirectory( directory=this.workingDir, action="list", name="filequery", filter="*.xml");
        result=[];
        for ( file in filequery ) { 
            result.append( listFirst( file.name, "." ) );
        }
        return result;

   }




    /**
	* Clean working directory
	*/
    public void function cleanWorkingDir( string lang="" ) localmode=true {
        
        if( isEmpty( arguments.lang ) ){

           langFilesToDelete=getAvailableLangLocalesInWorkingDir();
        
        }else{
           
            langFilesToDelete=[ arguments.lang ];
        }

        for ( language in langFilesToDelete ) { 
           if( fileExists(  this.workingDir & "#sanitizeFilename( language )#.xml") ){ 
                fileDelete( this.workingDir & "#sanitizeFilename( language )#.xml" );
            }
            
        }

       
    }



    /**
	* Function to abstract 2 methods
	*/
    public void function cleanWorkingDirAndPullResources( lang ) {

        cleanWorkingDir( arguments.lang );
        pullLangResourcesFromGithubToWorkingDirectory( arguments.lang );
        
    }


   
    /**
	* returns XML data of a language resource file as a struct
	*/
	public struct function getWorkingDataForLanguageByLettercode( string languageISOLetterCode required ) localmode=true {

        myXML=[:];
        xmlString = fileread( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.xml", "UTF-8" );
        myXML = xmlParse( xmlString );
        // dump(myXML);
        // abort;
         return myXML;
     
    }


    /**
	* returns the github advanced source search URL in Lucee admin source for a specific property
	*/
	public string function getGithubSourceSearchURL( string adminProperty required ) localmode=true {

         return "https://github.com/search?q=#encodeForHTMLAttribute( encodeForURL( arguments.adminProperty ) )#+repo%3Alucee%2FLucee+path%3A%2Fcore%2Fsrc%2Fmain%2Fcfml%2Fcontext%2Fadmin%2F&type=Code&ref=advsearch&l=&l=";
     
    }



    
    /**
	 * iterate all available language resource files  in the working directory return the referenced XML data as a struct
	 */
	public struct function getFullWorkingData() localmode=true {

        availableWorkingLanguages=getAvailableLangLocalesInWorkingDir();
                
        result={};
        
        for ( langName in availableWorkingLanguages ) { 
            
            result[ langName ] = getWorkingDataForLanguageByLettercode( langName );
            result[ langName ] = parseXMLDataToStruct( result[ langName ] );
            
        }

        return result;

    }


    /**
	* returns the data struct switched in such a manner that languages can be iterated to be shown in table
    * columns and not in table rows
	*/
	public struct function parseDataForTableOutput( struct data required ) localmode=true {
        result={};
        if( !structIsEmpty( arguments.data ) ){ 
            for( adminkeyName in arguments.data["en"]["XmlRoot.XmlAttributes.KeyData"] ){ 
                result[ adminkeyName ][ "en" ]= arguments.data["en"]["XmlRoot.XmlAttributes.KeyData"][ adminkeyName ];
                for( langCollection in arguments.data ){ 
                    if( langCollection!="en"){
                        result[ adminkeyName ][ langCollection ] = arguments.data[ langCollection ]["XmlRoot.XmlAttributes.KeyData"][ adminkeyName ]?:"";
                    } 
                } 
            }       
        } 

        return  result;
       
    }
}