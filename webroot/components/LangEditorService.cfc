/**********************************************************
 *  LangEditorService.cfc:
 *  A component used for creating and editing the language
 *  resource JSON files used in the Lucee admininistrator.
 *  License: MIT License
 *  (c)2023 C. Andreas Rüger
 *  https://github.com/andreasRu/lucee-admin-language-editor
 ************************************************************/

component {

	public struct function init() {
		this.version = application.appversion;
		this.luceeLangResourceUrl = "https://raw.githubusercontent.com/lucee/Lucee/6.0/core/src/main/cfml/context/admin/resources/language/";
		this.adminLangResourceUrl = "https://raw.githubusercontent.com/andreasRu/lucee-admin-language-editor/master/languageReleases/";

		this.workingBase = "/workingDir/";

		if( !cgi.http_host == "127.0.0.1:8080" && isDefined( "session.tmpDirectoryPath" ) ) {
			this.workingDir = getTempDirectory() & this.workingBase & session.tmpDirectoryPath;
		} else {
			this.workingDir = this.workingBase;
		}


		this.runningOnlineProductionMode = ( cgi.http_host == "127.0.0.1:8080" ) ? false : true;
		this.applicationSettings = getApplicationSettings();
		this.isSingleContext = ( structKeyExists( this.applicationSettings, "singleContext" ) && this.applicationSettings.singleContext ) ? true : false;


		if( !this.runningOnlineProductionMode && server.lucee.version gt "6" ) {
			if( this.isSingleContext ) {
				this.adminResourcePath = getServerWebContextInfoAsStruct()[ "servletInitParameters" ][ "lucee-server-directory" ] & "/lucee-server/context/context/admin";
				this.adminServerContextPath = getServerWebContextInfoAsStruct()[ "servletInitParameters" ][ "lucee-server-directory" ] & "/lucee-server/context";
				this.loadedAdminFiles = deploySwitcherFilesToLuceeAdmin();
			} else {
				this.adminResourcePath = getServerWebContextInfoAsStruct()[ "servletInitParameters" ][ "lucee-web-directory" ] & "/context/admin";
				this.adminServerContextPath = getServerWebContextInfoAsStruct()[ "servletInitParameters" ][ "lucee-server-directory" ] & "/lucee-server/context";
				this.loadedAdminFiles = deploySwitcherFilesToLuceeAdmin();
			}
		}

		return this;
	}


	public void function cleanTempDirs() {
		if( this.runningOnlineProductionMode ) {
			cfdirectory(
				directory = getTempDirectory() & this.workingBase,
				action = "list",
				name = "filequery",
				recurse = "false"
			);

			for( row in filequery ) {
				if( row.dateLastModified < dateAdd( "h", -3, now() ) ) {
					directoryDelete( getTempDirectory() & this.workingBase & row.name, true );
				}
			}
		}
		return;
	}

	public void function createWorkingDirectoryIfNotExists() {
		if( !directoryExists( this.workingDir ) ) {
			directoryCreate( this.workingDir );
		}
	}


	/*********
	 *
	 *  Create a languageSwitcher for fast access loading the language file in the logged in Admin
	 *
	 *********/
	public struct function deploySwitcherFilesToLuceeAdmin() localmode = true {
		if( this.runningOnlineProductionMode ) {
			abort;
		}

		result = {};
		result[ "languagesPulledToAdmin" ] = {};
		languagesArray = getLanguagesAvailableInWorkingData();

		// this is done on each init, but only if languageSwitcher has not been deployed already
		if( !fileExists( this.adminResourcePath & "/languageSwitcher.cfm" ) ) {
			fileCopy( source = expandPath( "./../" ) & "adminDeploy/languageSwitcher.cfm", destination = this.adminResourcePath & "/languageSwitcher.cfm" );

			if( !directoryExists( this.adminResourcePath & "/resources" ) ) {
				directoryCreate( this.adminResourcePath & "/resources" );
			}

			createPasswordFile();

			fileCopy( source = expandPath( "./../" ) & "adminDeploy/password.txt", destination = this.adminServerContextPath & "/password.txt" );
		}


		// make sure the lang directory exists

		if( len( languagesArray ) && !directoryExists( this.adminResourcePath & "/resources/language" ) ) {
			directoryCreate( this.adminResourcePath & "/resources/language" );
		}


		for( language in languagesArray ) {
			fileCopy( source = this.workingDir & "#sanitizeFilename( language )#.json", destination = this.adminResourcePath & "/resources/language/#sanitizeFilename( language )#.json" );
			result[ "languagesPulledToAdmin" ][ language ] = this.adminResourcePath & "/resources/language/#sanitizeFilename( language )#.json";
		}

		result[ "langSwitcherInjectedLocation" ] = this.adminResourcePath & "/languageSwitcher.cfm";
		result[ "adminPasswordTxtLocation" ] = this.adminServerContextPath & "/password.txt";


		return result;
	}

	public string function getChatGPTPrompt( lang ) {
		loadedData = [ : ];
		propertiesToTransate = [];
		loadedData = mapStructToDotPathVariable( getWorkingDataForLanguageByLettercode( "en" ).data );
		loadedLangDataToTranslate = mapStructToDotPathVariable( getWorkingDataForLanguageByLettercode( arguments.lang ).data );

		for( property in loadedData ) {
			topKey = listFirst( property, "." );
			if( !structKeyExists( loadedLangDataToTranslate, property ) && structKeyExists( loadedData, property ) && loadedData[ property ] != "" ) {
				structInsert( loadedLangDataToTranslate, property, loadedData[ property ] );

				if( !propertiesToTransate.contains( topKey ) ) {
					propertiesToTransate.append( topKey );
				}
			}

			if( structKeyExists( loadedLangDataToTranslate, property ) && loadedLangDataToTranslate[ property ] == "" && structKeyExists( loadedData, property ) && loadedData[ property ] != "" ) {
				structUpdate( loadedLangDataToTranslate, property, loadedData[ property ] );
				if( !propertiesToTransate.contains( topKey ) ) {
					propertiesToTransate.append( topKey );
				}
			}
		}

		// removeunused properties
		for( property in loadedLangDataToTranslate ) {
			topKey = listFirst( property, "." );
			if( !propertiesToTransate.contains( topKey ) ) {
				structDelete( loadedLangDataToTranslate, "#property#" );
			}
		}

		structKeyTranslate( loadedLangDataToTranslate );
		tmp = sortNestedStruct( loadedLangDataToTranslate );
		loadedLangDataToTranslate = tmp;
		// create chatgptPrompt;
		result = "";
		language = getAvailableJavaLocalesAsStruct()[ arguments.lang ];
		// removeunused properties
		for( property in loadedLangDataToTranslate ) {
			tmpPrompt = "Translate the following JSON from English to " & language & " and print the JSON as code:" & chr( 10 );
			tmpPrompt = tmpPrompt & chr( 10 ) & chr( 10 ) & serializeJSON( { "#property#": loadedLangDataToTranslate[ property ] } );
			result = result & tmpPrompt & chr( 10 ) & chr( 10 ) & chr( 10 ) & chr( 10 ) & chr( 10 ) & "////////////////////////// NEW CHATGPT-PROMPT //////////////////////////" & chr( 10 ) & chr( 10 ) & chr( 10 );
		}

		if( isEmpty( result ) ) {
			result = "Seems like there is nothing that needs to be translate for '#encodeForHTML( arguments.lang )#'";
		}
		return result;
	}


	public void function createPasswordFile() localmode = true {
		if( !fileExists( expandPath( "./../" ) & "adminDeploy/password.txt" ) ) {
			allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890"
			randomStr = "";
			for( i = 1; i < 10; i++ ) {
				randomStr = randomStr & mid( allowedChars, randRange( 1, len( allowedChars ) ), 1 );
			}
			fileWrite( expandPath( "./../" ) & "adminDeploy/password.txt", randomStr, "utf-8" );
		}
	}


	public string function getPasswordFromPasswordTXT() localmode = true {
		if( fileExists( expandPath( "./../" ) & "adminDeploy/password.txt" ) ) {
			result = fileRead( expandPath( "./../" ) & "adminDeploy/password.txt", "utf-8" );
		} else {
			result = ""
		}
		return result;
	}


	public string function getJSONCodeSnippet( required string dataPropertyName, required string dataPropertyValue ) localmode = true {
		result = "";

		if( arguments.dataPropertyValue != "" ) {
			dataAsStruct = [ : ];
			dataAsStruct = { "#dataPropertyName#": dataPropertyValue };
			structKeyTranslate( dataAsStruct );

			result = "Property Path: """ & replaceNoCase( dataPropertyName, ".", " => ", "ALL" ) & """";
			result = result & chr( 10 ) & chr( 10 ) & serializeToPrettyJson( dataAsStruct );
		} else {
			result = "";
		}

		return result;
	}


	public string function getFullJSON( required string lang ) localmode = true {
		return serializeToPrettyJson( getWorkingDataForLanguageByLettercode( lang ) );
	}

	public string function cleanIdentationJSON( required string Json ) {
		result = arguments.Json;
		result = replaceNoCase(
			result,
			"#chr( 10 )#                """,
			"#chr( 10 )#								""",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#              """,
			"#chr( 10 )#							""",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#            """,
			"#chr( 10 )#						""",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#          """,
			"#chr( 10 )#					""",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#        """,
			"#chr( 10 )#				""",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#      """,
			"#chr( 10 )#			""",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#    """,
			"#chr( 10 )#		""",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#  """,
			"#chr( 10 )#	""",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#                }",
			"#chr( 10 )#								}",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#              }",
			"#chr( 10 )#							}",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#            }",
			"#chr( 10 )#						}",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#          }",
			"#chr( 10 )#					}",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#        }",
			"#chr( 10 )#				}",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#      }",
			"#chr( 10 )#			}",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#    }",
			"#chr( 10 )#		}",
			"ALL"
		);
		result = replaceNoCase(
			result,
			"#chr( 10 )#  }",
			"#chr( 10 )#	}",
			"ALL"
		);
		return result;
	}

	public void function saveJSON( required string languageCode, required string JsonObject ) localmode = true {
		dataJSON = deserializeJSON( arguments.JsonObject );
		structUpdate( dataJSON, "key", arguments.languageCode );
		structUpdate( dataJSON, "label", getAvailableJavaLocalesAsStruct()[ arguments.languageCode ] );
		fileWrite( this.workingDir & "#sanitizeFilename( arguments.languageCode )#.json", serializeToPrettyJson( dataJSON ), "utf-8" );
	}



	/**
	 * returns a struct with the server/web context information that is bound to this template.
	 */
	public struct function getServerWebContextInfoAsStruct() localmode = true {
		// get pageContext/CFMLFactoryConfig of actual template
		local.pageContext = getPageContext();
		local.pageCFMLFactory = local.pageContext.getCFMLFactory();
		local.pageCFMLFactoryConfig = local.pageCFMLFactory.getConfig();

		// get the Servlets configuration and initial Parameters (e.g. set in Tomcats conf/web.json)
		local.servletConfig = getPageContext().getServletConfig();
		local.servletInitParamNames = servletConfig.getInitParameterNames();

		// populate struct with gathered information
		local.info = { "context-label": getPageContext().getCFMLFactory().getLabel(), "configFileLocation": pageCFMLFactoryConfig.getConfigFile(), "servletInitParameters": [ : ] };

		// if available, iterate enum of InitParamNames and get the values

		cfloop( collection = "#servletInitParamNames#", item = "item" ) {
			structInsert( local.info[ "ServletInitParameters" ], item, local.servletConfig.getInitParameter( item.toString() ) );
		};


		return local.info;
	}


	public string function outputAsJson( struct data required ) localmode = true {
		cfcontent( reset = "true" );
		cfheader( name = "content-type", value = "application/json" );
		echo( serializeJSON( arguments.data ) );
		cfabort;
	}


	/**
	 * get languages of resource files available in working folder
	 */
	public array function getLanguagesAvailableInWorkingData() localmode = true {
		result = [];
		result = listToArray( structKeyList( getFullWorkingData() ) );
		if( !result.isEmpty() ) {
			result.delete( "en" );
			result.prepend( "en" );
		}
		return result;
	}



	/**
	 * returns a hardcoded lettercode list of available lang resources available at
	 * at: https://raw.githubusercontent.com/lucee/Lucee/6.0/core/src/main/cfml/context/admin/resources/language/
	 */

	public struct function getAvailableLanguagesInGitSource() {
		return { "lucee": [ "en", "de", "es" ], "langEditor": [ "en", "de", "es", "pt", "fr" ] };
	}


	/**
	 * Sorts a struct recursively
	 */
	public struct function sortNestedStruct( struct datastruct ) localmode = true {
		// define sorted struct
		sortedStruct = [ : ];

		// Get the keys of the struct and sort them
		keys = structKeyArray( arguments.datastruct ).sort( "textnocase" );

		// Iterate over the sorted keys
		for( var key in keys ) {
			value = arguments.datastruct[ key ];

			// If the value is a nested struct, recursively sort it
			if( isStruct( value ) ) {
				value = sortNestedStruct( value );
			}

			// Add the key-value pair to the sorted struct
			sortedStruct[ key ] = value;
		}

		return sortedStruct;
	}



	public numeric function getWorkingSpaceInMB() localmode = true {
		cfdirectory(
			directory = this.workingDir,
			action = "list",
			name = "filequery",
			recurse = "true"
		);

		result = 0;
		for( file in filequery ) {
			result = result + file.size;
		}

		return int( result / 1000000 );
	}





	/**
	 * Updates/Saves the data to an ordered formatted JSON
	 * */
	public void function createUpdateWorkingLanguageResourceFile( string languageCode required, struct formObject ) localmode = true {
		createWorkingDirectoryIfNotExists();

		// Pull source file if still not available
		if( !fileExists( this.workingDir & "en.json" ) ) {
			fileCopy( source = "#this.luceeLangResourceUrl#en.json", destination = this.workingDir & "en.json" );
		}

		// define variables
		dataJSON = [ : ];
		tmpStructuredData = [ : ];

		// add language header
		structInsert( dataJSON, "key", arguments.languageCode );
		structInsert( dataJSON, "label", getAvailableJavaLocalesAsStruct()[ arguments.languageCode ] );
		structInsert( dataJSON, "data", [ : ] );

		// iterate formobject and replace the data
		if( structKeyExists( arguments, "formObject" ) ) {
			// get a sprted list of all form keys
			KeyNames = arguments.formObject.fieldnames.listToArray( "," ).sort( "textnocase" );


			// iterate keys of form object
			for( keyname in KeyNames ) {
				property = replaceNoCase( keyname, "~", ".", "all" );
				// english version of JSON needs to be always complete, even with empty strings
				if(
					arguments.languageCode == "en"
					|| ( arguments.languageCode != "en" && form[ keyname ] != "" )
				) {
					structAppend( dataJSON.data, { "#property#": form[ keyname ] } );
				}
			}
		}

		// translate path keynames to a deep struct
		structKeyTranslate( dataJSON.data );

		// sort the struct
		tmpStructuredData = sortNestedStruct( dataJSON.data );
		dataJSON.data = tmpStructuredData;

		fileWrite( this.workingDir & "#sanitizeFilename( arguments.languageCode )#.json", serializeToPrettyJson( dataJSON ), "utf-8" );

		if( !this.runningOnlineProductionMode && server.lucee.version gt "6" ) {
			pullResourceFileToWebAdmin( arguments.languageCode );
		}
	}

	/**
	 * Serializes a CFML struct to a JSON output as an alternative to native cfml serialization
	 * for usage of a JSON formatter
	 * */
	public string function serializeToPrettyJson( struct dataStruct ) {
		// prettify JSON
		prettifier = createObject( "java", "com.google.gson.GsonBuilder", "/../libs/gson-2.10.1.jar" ).init().setPrettyPrinting().create();
		return cleanIdentationJSON( prettifier.toJson( arguments.datastruct ) );
	}


	/**
	 * Creates a file download for downloading the resource file
	 * */
	public any function downloadFileJSON( string languageCode required ) localmode = true {
		if( fileExists( this.workingDir & sanitizeFilename( arguments.languageCode ) & ".json" ) ) {
			cfheader( name = "Content-Disposition", value = "attachment; filename=#sanitizeFilename( arguments.languageCode )#.json" );
			cfcontent( type = "text/json", file = this.workingDir & sanitizeFilename( arguments.languageCode ) & ".json", deleteFile = "no" );
		}
	}



	/**
	 * returns as struct of all available 2-letter codes of the underlying java.util with the referring Language DisplayName (target language)
	 */
	public struct function getAvailableJavaLocalesAsStruct() localmode = true {
		// Get Locale List
		JavaLocale = createObject( "java", "java.util.Locale" );
		availableJavaLocalesArray = JavaLocale.getAvailableLocales();
		// dump( JavaLocale );
		// dump( availableJavaLocalesArray );

		// initialize an ordered struct with shorthand [:]

		availableJavaLocalesStruct = {};
		cfloop( array = "#availableJavaLocalesArray#", item = "itemLocale" ) {
			// echo( dump( [ itemLocale.toLanguageTag(), itemLocale.getDisplayName(), itemLocale.getISO3Language() ] ) );
			if( len( itemLocale.toLanguageTag() ) == 2 ) {
				displayNameTargetLanguage = itemLocale.info();
				availableJavaLocalesStruct[ itemLocale.toLanguageTag() ] = ucFirst( displayNameTargetLanguage[ "display" ][ "language" ] );
			}
		}
		// sort by locale;
		result = [ : ];
		availableJavaLocalesSortedArray = structSort( availableJavaLocalesStruct );
		for( localeLanguage in availableJavaLocalesSortedArray ) {
			result.insert( localeLanguage, availableJavaLocalesStruct[ localeLanguage ] );
		}

		return result;
	}


	/**
	 * copies all known language resource files from Lucees github source to working directory
	 */
	public void function pullLangResourcesFromGithubToWorkingDirectory( string lang required ) localmode = true {
		createWorkingDirectoryIfNotExists();


		for( language in listToArray( arguments.lang ) ) {
			fileCopy( source = "#this.adminLangResourceUrl##language#.json", destination = this.workingDir & "#language#.json" );
		}

		if( !fileExists( this.workingDir & "en.json" ) ) {
			fileCopy( source = "#this.luceeLangResourceUrl#en.json", destination = this.workingDir & "en.json" );
		}
	}

	/**
	 * Pulls the files for a WYSIWYG view into the Lucee Administrator
	 */

	public void function abortIfInProduction() {
		if( !this.runningOnlineProductionMode ) {
			abort;
		}
		return;
	}

	/**
	 * Pulls the files for a WYSIWYG view into the Lucee Administrator
	 */

	public void function pullResourceFileToWebAdmin( string language required ) localmode = true {
		abortIfInProduction();


		adminResourceLanguagePath = this.adminResourcePath & "/resources/language"

		if( fileExists( this.workingDir & "#sanitizeFilename( arguments.language )#.json" ) ) {
			fileCopy( source = this.workingDir & "#sanitizeFilename( arguments.language )#.json", destination = "#adminResourceLanguagePath#/#sanitizeFilename( arguments.language )#.json" );
		}
	}


	// make sure the filename is sanitzed by allowing only alphanumeric characters
	public string function sanitizeFilename( string filename required ) localmode = true {
		return reReplaceNoCase(
			arguments.filename,
			"[^a-zA-Z0-9\-]",
			"",
			"ALL"
		);
	}



	/**
	 * Returns an array of all available languages in the working directory
	 */
	public array function getAvailableLangLocalesInWorkingDir() localmode = true {
		cfdirectory(
			directory = this.workingDir,
			action = "list",
			name = "filequery",
			filter = "*.json"
		);

		result = [];
		for( file in filequery ) {
			result.append( listFirst( file.name, "." ) );
		}
		return result;
	}




	/**
	 * Clean/reinit working directory
	 */
	public void function cleanWorkingDir( string lang = "" ) localmode = true {
		createWorkingDirectoryIfNotExists();

		if( isEmpty( arguments.lang ) ) {
			langFilesToDelete = getAvailableLangLocalesInWorkingDir();
		} else {
			langFilesToDelete = [ arguments.lang ];
		}

		for( language in langFilesToDelete ) {
			if( fileExists( this.workingDir & "#sanitizeFilename( language )#.json" ) ) {
				fileDelete( this.workingDir & "#sanitizeFilename( language )#.json" );
			}
		}
	}


	public boolean function createProperty( string propertyName required ) localmode = true {
		result = false;
		loadedData = [ : ];
		loadedData = mapStructToDotPathVariable( getWorkingDataForLanguageByLettercode( "en" ).data );

		propertyHasConflict = false;
		propertyPaths = listToArray( trim( arguments.propertyName ), "." );

		// create an array of possible keys. E.g. if "admin.search.desc" is added,
		// the following keys must be checked for existance, so no overwriting will take place:
		// "admin", "admin.search", "admin.search.desc",
		keysToCheckConflict = arrayReduce(
			propertyPaths,
			function(prev, item, index, theArray) {
				for( i = 1; i <= index; i++ ) {
					if( i == 1 ) {
						prev = prev & theArray[ i ];
					} else {
						prev = prev & "." & theArray[ i ];
					}
				}

				return prev & ",";
			},
			""
		).listtoarray();

		for( item in keysToCheckConflict ) {
			if( structKeyExists( loadedData, item ) ) {
				propertyHasConflict = true;
			}
		}

		// check if the added property is a parent of any existing property.
		listOfKeyPaths = "," & structKeyArray( loadedData ).toList();
		if( findNoCase( arguments.propertyName & ".", listOfKeyPaths ) ) {
			propertyHasConflict = true;
		}

		if( !propertyHasConflict ) {
			structInsert( loadedData, arguments.propertyName, "" );
			structKeyTranslate( loadedData );
			dataJSON = [ : ];
			dataJSON[ "key" ] = "en";
			dataJSON[ "label" ] = "English";
			dataJSON[ "data" ] = sortNestedStruct( loadedData );
			fileWrite( this.workingDir & "en.json", serializeToPrettyJson( dataJSON ), "utf-8" );
			result = true;
		} else {
			result = false;
		}

		return result;
	}

	/**
	 * Function to abstract 2 methos
	 */
	public void function cleanWorkingDirAndPullResources( lang ) localmode = true {
		cleanWorkingDir( arguments.lang );
		pullLangResourcesFromGithubToWorkingDirectory( arguments.lang );
	}



	/**
	 * parses JSON/XML (.json/.xml) data from a language resource file to a cfml struct
	 */
	public struct function getWorkingDataForLanguageByLettercode( string languageISOLetterCode required ) localmode = true {
		myJson = [ : ];

		if( fileExists( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.json" ) ) {
			jsonString = fileRead( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.json", "UTF-8" );
		} else if( fileExists( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.xml" ) ) {
			myXML = [ : ];
			xmlString = fileRead( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.xml", "UTF-8" );
			myXML = parseXMLDataToStruct( xmlParse( xmlString ) );
			structKeyTranslate( myXML[ "XmlRoot.XmlAttributes.keyData" ] );
			structInsert( myJson, "key", arguments.languageISOLetterCode );
			structInsert( myJson, "label", getAvailableJavaLocalesAsStruct()[ arguments.languageISOLetterCode ] );
			structInsert( myJson, "data", myXML[ "XmlRoot.XmlAttributes.keyData" ] );

			fileWrite( this.workingDir & "#sanitizeFilename( arguments.languageISOLetterCode )#.json", serializeJSON( myJson ), "utf-8" );

			// location( "/", "false", "302" );
			;
		}

		myJson = deserializeJSON( jsonString );

		return myJson;
	}


	/**
	 * returns the github advanced source search URL in Lucee admin source for a specific property
	 */
	public string function getGithubSourceSearchURL( string adminProperty required ) localmode = true {
		return "https://github.com/search?q=#encodeForHTMLAttribute( encodeForURL( arguments.adminProperty ) )#+repo%3Alucee%2FLucee+path%3A%2Fcore%2F&type=Code&ref=advsearch&l=&l=";
	}




	/**
	 * iterate all available language resource files  in the working directory return the referenced JSON data as a struct
	 */
	public struct function getFullWorkingData() localmode = true {
		availableWorkingLanguages = getAvailableLangLocalesInWorkingDir();

		result = {};

		for( langName in availableWorkingLanguages ) {
			result[ langName ] = getWorkingDataForLanguageByLettercode( langName );
		}

		return result;
	}


	public struct function mapStructToDotPathVariable( struct data, prefix = "", propertyStruct = {} ) localmode = true {
		for( key in arguments.data ) {
			value = data[ key ];

			if( isStruct( value ) ) {
				mapStructToDotPathVariable( value, prefix & key & ".", propertyStruct );
			} else {
				propertyStruct.append( { "#prefix##key#": value } );
				// echo( "#prefix##key#: #value# <br>");
			}
		}


		return propertyStruct;
	}


	/**
	 * returns the data struct switched in such a manner that languages can be iterated to be shown in table
	 * columns and not in table rows
	 */
	public struct function parseDataForTableOutput( struct data required ) localmode = true {
		result = {};

		if( !structIsEmpty( arguments.data ) ) {
			for( language in arguments.data ) {
				result[ language ] = mapStructToDotPathVariable( arguments.data[ language ][ "data" ] );
			}
		}

		return result;
	}

}
