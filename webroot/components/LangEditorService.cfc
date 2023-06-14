/**********************************************************
*  LangEditorService.cfc: 
*  A component used for creating and editing the language 
*  resource JSON files used in the Lucee admininistrator. 
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
        this.adminResourcePath=getServerWebContextInfoAsStruct()["servletInitParameters"]["lucee-server-directory"] & "/lucee-server/context/context/admin";
        this.adminServerContextPath=getServerWebContextInfoAsStruct()["servletInitParameters"]["lucee-server-directory"] & "/lucee-server/context";
        this.loadedAdminFiles = deploySwitcherFilesToLuceeAdmin();

        return this;
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
        if ( !fileExists( this.adminResourcePath & "/languageSwitcher.cfm" ) 
             || !fileExists( this.adminResourcePath & "/admin_layout.cfm" ) 
             || !fileExists( this.adminResourcePath & "/resources/text.cfm" ) 
             ){

            fileCopy(   source= expandPath("./") & "adminDeploy/languageSwitcher.cfm", 
            destination=this.adminResourcePath & "/languageSwitcher.cfm" );

            fileCopy(   source= expandPath("./") & "adminDeploy/admin_layout.cfm", 
            destination=this.adminResourcePath & "/admin_layout.cfm" );

            directoryCreate(this.adminResourcePath & "/resources");
            directoryCreate(this.adminResourcePath & "/resources/language");
            
            fileCopy(   source= "https://raw.githubusercontent.com/lucee/Lucee/6.0/core/src/main/cfml/context/admin/resources/text.cfm", 
            destination=this.adminResourcePath & "/resources/text.cfm" );

            createPasswordFile();

            fileCopy(   source= expandPath("./") & "adminDeploy/password.txt", 
            destination=this.adminServerContextPath & "/password.txt" );
           
        }

        // this is done on each init, and on load
        for ( language in languagesArray ){

            fileCopy(   source= this.workingDir & "#sanitizeFilename( language )#.json", 
            destination=this.adminResourcePath & "/resources/language/#sanitizeFilename( language )#.json" );
            result[ "languagesPulledToAdmin" ][ language ]= this.adminResourcePath & "/resources/language/#sanitizeFilename( language )#.json";
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

    
    public string function getJSONCodeSnippet( required string dataPropertyName, required string dataPropertyValue  ) localmode=true {
           
            result="";
            
            if( arguments.dataPropertyValue != "" ){
                    dataAsStruct=[:];
                    dataAsStruct= { "#dataPropertyName#": dataPropertyValue  };
                    structkeytranslate( dataAsStruct );
                    result="Property Path: """ & replaceNoCase( dataPropertyName, ".", " => ", "ALL") & """";
                    result= result & chr(10) & chr(10) & serializeToPrettyJson( dataAsStruct ) ;
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

        //get the Servlets configuration and initial Parameters (e.g. set in Tomcats conf/web.json)
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
        
        return [ "de","en", "es" ];
       
    }


    
    public struct function convertXMLLanguageToJson( langName ) localmode=true {
        
        langNameData  = getWorkingDataForLanguageByLettercode( langName );

        dump( langNameData );
        abort;
    }


     /**
	 * Sorts a struct recursively 
	 */
    public struct function sortNestedStruct( struct datastruct ) localmode=true {
        
        // define sorted struct
        sortedStruct = [:];
        
        // Get the keys of the struct and sort them
        keys = structKeyArray( arguments.datastruct ).sort( "textnocase" );
        
        // Iterate over the sorted keys
        for (var key in keys) {
            
            value = arguments.datastruct[ key ];
            
            // If the value is a nested struct, recursively sort it
            if ( isStruct( value ) ) {
                value = sortNestedStruct( value );
            }
            
            // Add the key-value pair to the sorted struct
            sortedStruct[ key ] = value;
        }
        
        return sortedStruct;
    }

   

    /**
	 * Updates/Saves the data to an ordered formatted JSON
     * */
    public void function createUpdateWorkingLanguageResourceFile( string languageCode required,  struct formObject ) localmode=true {

        // define variables
        dataJSON= [:];
        tmpStructuredData=[:];

        // add language header
        StructInsert( dataJSON, "key", arguments.languageCode );
        StructInsert( dataJSON, "label", getAvailableJavaLocalesAsStruct()[ arguments.languageCode] );
        StructInsert( dataJSON, "data", [:]);

        // iterate formobject and replace the data
        if( structKeyExists( arguments, "formObject") ){
            
            // get a sprted list of all form keys
            KeyNames= arguments.formObject.fieldnames.listToArray(",").sort("textnocase");
           

            // iterate keys of form object
            for( keyname in KeyNames ){
                property=replaceNoCase( keyname, "~", ".", "all");
                    // english version of JSON needs to be always complete, even with empty strings
                    if(  arguments.languageCode=="en" 
                        || ( arguments.languageCode!="en" && form[ keyname ]!="" )){
                        StructAppend( dataJSON.data, { "#property#" : form[ keyname ] } );
                    }
                }
        }

        // translate path keynames to a deep struct 
        structkeytranslate( dataJSON.data );

        // sort the struct
        tmpStructuredData= sortNestedStruct( dataJSON.data );
        dataJSON.data=tmpStructuredData;
        
        
        fileWrite( this.workingDir & "#sanitizeFilename( arguments.languageCode )#.json",  serializeToPrettyJson( dataJSON ) , "utf-8" );
        pullResourceFileToWebAdmin( arguments.languageCode );
        
    }

    public string function serializeToPrettyJson( struct dataStruct ){

         // prettify JSON
         prettifier = createObject( "java", "com.google.gson.GsonBuilder", "/../libs/gson-2.10.1.jar" )
         .init()
         .setPrettyPrinting()
         .create();

        return prettifier.toJson( arguments.datastruct );
    }

    
    
    public any function downloadFileJSON( string languageCode required ) localmode=true {
    
        if( fileExists( this.workingDir & sanitizeFilename( arguments.languageCode ) & ".json") ){
            cfheader( 
                name="Content-Disposition", 
                value="attachment; filename=#sanitizeFilename( arguments.languageCode )#.json"
            );
            cfcontent( 
                type = "text/json", 
                file = this.workingDir & sanitizeFilename( arguments.languageCode ) & ".json",
                deleteFile = "no" 
            );
        }
        
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
            fileCopy(   source="#this.luceeSourceUrl#/core/src/main/cfml/context/admin/resources/language/#language#.json", 
            destination=this.workingDir & "#language#.json" );
        }

        if( !fileExists(  this.workingDir & "en.json" ) ){ 
            fileCopy( 
            source="#this.luceeSourceUrl#/core/src/main/cfml/context/admin/resources/language/en.json", 
            destination= this.workingDir & "en.json" );
        }
    }

    

    
    public void function pullResourceFileToWebAdmin( string language required ) localmode=true {

        adminResourceLanguagePath= this.adminResourcePath & "/resources/language"
        if( fileExists(  this.workingDir & "#sanitizeFilename( arguments.language )#.json") ){ 

            fileCopy( 
                source=this.workingDir & "#sanitizeFilename( arguments.language )#.json", 
                destination="#adminResourceLanguagePath#/#sanitizeFilename( arguments.language )#.json" 
            );

        }
        
    }


    
    public string function sanitizeFilename( string filename required ) localmode=true {
        return reReplaceNoCase( arguments.filename, "[^a-zA-Z0-9\-]", "", "ALL" );
    }

    
   
   public array function getAvailableLangLocalesInWorkingDir() localmode=true {

        cfdirectory( directory=this.workingDir, action="list", name="filequery", filter="*.json");
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
           if( fileExists(  this.workingDir & "#sanitizeFilename( language )#.json") ){ 
                fileDelete( this.workingDir & "#sanitizeFilename( language )#.json" );
            }
            
        }

       
    }



    /**
	* Function to abstract 2 methos
	*/
    public void function cleanWorkingDirAndPullResources( lang ) {

        cleanWorkingDir( arguments.lang );
        pullLangResourcesFromGithubToWorkingDirectory( arguments.lang );
        
    }


   
    /**
	* returns JSON data of a language resource file as a struct
	*/
	public struct function getWorkingDataForLanguageByLettercode( string languageISOLetterCode required ) localmode=true {
        myJson=[:];
        if( fileExists( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.json" ) ){
        
            jsonString = fileread( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.json", "UTF-8" );
        
        }else{

            myXML=[:];
            xmlString = fileread( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.xml", "UTF-8" );
            myXML = parseXMLDataToStruct( xmlParse( xmlString ) );
            structkeytranslate( myXML["XmlRoot.XmlAttributes.keyData"] );
            StructInsert( myJson, "key", arguments.languageISOLetterCode );
            StructInsert( myJson, "label", getAvailableJavaLocalesAsStruct()[ arguments.languageISOLetterCode] );
            StructInsert( myJson, "data", myXML["XmlRoot.XmlAttributes.keyData"]);
            fileWrite( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.json",  serializeJSON( myJson ) , "utf-8" );
            abort;
        
        }
        
        myJson = deserializeJson( jsonString );
        return myJson;
     
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
	* returns the github advanced source search URL in Lucee admin source for a specific property
	*/
	public string function getGithubSourceSearchURL( string adminProperty required ) localmode=true {

         return "https://github.com/search?q=#encodeForHTMLAttribute( encodeForURL( arguments.adminProperty ) )#+repo%3Alucee%2FLucee+path%3A%2Fcore%2F&type=Code&ref=advsearch&l=&l=";
     e
    }



    
    /**
	 * iterate all available language resource files  in the working directory return the referenced JSON data as a struct
	 */
	public struct function getFullWorkingData() localmode=true {

        availableWorkingLanguages=getAvailableLangLocalesInWorkingDir();
                
        result={};
        
        for ( langName in availableWorkingLanguages ) { 
            
            result[ langName ] = getWorkingDataForLanguageByLettercode( langName );
            
        }

        return result;

    }

    public struct function getMappedProperties( struct data, prefix = "", propertyStruct = {}) localmode=true {
        
        for( key in arguments.data ) {
          
            value = data[ key ];
            
            if ( isStruct( value ) ) {
                getMappedProperties( value, prefix & key & ".", propertyStruct );
            } else {
                propertyStruct.append( { "#prefix##key#":  value } );
          }
        }
        
        return propertyStruct;
      }


    /**
	* returns the data struct swtiched in such a manner that languages can be iterated to be shown in table
    * columnes and not in table rows
	*/
	public struct function parseDataForTableOutput( struct data required ) localmode=true {
        
        result={};
        
        if( !structIsEmpty( arguments.data ) ){

            for( langData in arguments.data ) {

                result[ langData ]=getMappedProperties( arguments.data[ langData ]["data"]);
            
            }
        }

        return  result;
       
    }
}