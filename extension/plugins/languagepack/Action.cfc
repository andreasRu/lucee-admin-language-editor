component hint = "LanguagePack" extends = "lucee.admin.plugin.Plugin" {

	/**
	 * Initialize Plugin
	 */
	public function init( struct lang, struct app ) {
		
		
		
		// define server contexts and web server context, also with singlemode
		if( isNull( request.singlemode ) ) {
			this.serverContextPath = expandPath( "{lucee-server}/context/context" );
			this.webContextPath = expandPath( "{lucee-web}/context" );
		} else {
			this.serverContextPath = expandPath( "{lucee-server}/context" );
			if( request.adminType == "server" ) {
				this.webContextPath = expandPath( "{lucee-server}/context/" );
			} else {
				this.webContextPath = expandPath( "{lucee-web}/context/" );
			}
		}

		

		// copy original text.cfm from lucee admin extension to be able to use it as the swticher
		if( !fileExists( this.webContextPath & "/admin/resources/text.cfm" ) ) {
			cfzip(
				action = "unzip",
				destination = this.webContextPath & "/admin/",
				entrypath = "resources/text.cfm"
				file = this.serverContextPath & "/lucee-admin.lar"
			);
		}

		// make sure the language files get created in web context, if needed.
		if( !directoryExists( "../resources/language" ) ) {
			directoryCopy( "../languagepack/language", this.webContextPath & "/admin/resources/language" );
		}

		// make sure the language files get created in server context, if needed.
		if( !directoryExists( "../resources/language" ) ) {
			directoryCopy( "../languagepack/language", this.serverContextPath & "/admin/resources/language" );
		}
		

		app.availableLanguages = getAvailableLanguages();
		
		
	}

	public function getAvailableLanguages() localmode = true {
		result = [ : ];
		availableLangRessources = getAvailableLanguagesFromResourceFiles();
		for( language in availableLangRessources ) {
			jsonString = fileRead( this.serverContextPath & "/admin/resources/language/" & language & ".json", "UTF-8" );
			availableLanguages = deserializeJSON( jsonString );
			result.insert( language, availableLanguages[ "label" ] );
		}
		return result;
	}




	private array function getAvailableLanguagesFromResourceFiles() {
		local.langResourcePath = this.serverContextPath & "/admin/resources/language";
		cfdirectory(
			directory = local.langResourcePath,
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


	public function overview( struct lang, struct app, struct req ) {
	}

}
