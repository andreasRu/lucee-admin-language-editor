component {

	// abort if user_agent is empty
	if( !isRunningLocal() ) {
		if( cgi.http_user_agent is "" ) {
			cfheader( statuscode = "403", statustext = "Forbidden" );
			echo( "<html><body>Not Available</body></html>" );
			abort;
		}

		// abort if unallowed scanner/bot or whatever
		cfloop( list = "masscan-ng~360Spider~80legs~Abonti~admant~AhrefsBot~archive-at.com~Baiduspider~BLEXBot~BUbiNG~domaincrawler~EMail Exractor~Exabot~ELNSB50~Grapeshot~genieo~help.zum~IstellaBot~jobdigger~linguee~MJ12bot~majestic~megasuche~megaindex~searchmetrics~SEOkicks~Semrush~SeznamBot~Sogou~Sleuth~sistrix~sitebot~siteexplorer~sixka~SiteSucker~Sosospider~voilabot~WBSearchBot~website-datenbank~waybackarchive~Wotbox~YandexBot~spbot~Cliqzbot~Java/~Pingoscope~Vagabondo~CB/Nutch~BUbiNG~SixKaBot~Synapse~python~", index = "banned_useragent_item", delimiters = "~" ) {
			if( findNoCase( banned_useragent_item, cgi.http_user_agent ) ) {
				cfheader( statuscode = "403", statustext = "Forbidden" );
				echo( "<html><body>Not Available</body></html>" );
				abort;
			}
		}
	}

	this.appversion = "2.0.5";
	this.name = "adminTranslator#server.lucee.version#-#this.appversion#";
	this.clientmanagement = "no";
	this.scriptprotect = "all";
	this.applicationtimeout = "#createTimespan( 1, 0, 0, 0 )#";
	this.web.charset = "utf-8";
	this.basePath = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings[ "/components" ] = this.basePath & "components";
	this.mappings[ "/ajaxApi" ] = this.basePath & "ajaxApi";



	if(
		getHTTPRequestData( false ).headers.accept.findnocase( "*/*" )
		&& structKeyExists( cookie, "isUser" )
	) {
		this.sessionmanagement = "yes";
		this.sessionStorage = "memory";
		this.sessiontimeout = "#createTimespan( 0, 0, 30, 0 )#";
		this.setclientcookies = "yes";
		this.setdomaincookies = "no";
		cfcookie(
			name = "cfid",
			value = "#session.cfid#",
			httpOnly = "true",
			preserveCase = "true"
		);

		cfcookie(
			name = "cftoken",
			value = "#session.cftoken#",
			httpOnly = "true",
			preserveCase = "true"
		);
	} else {
		this.sessionmanagement = "no";
		this.setclientcookies = "no";
		this.setdomaincookies = "no";
	}



	public boolean function OnRequestStart() {
		if( getHTTPRequestData( false ).headers.accept.findnocase( "*/*" ) ) {
			cfcookie(
				name = "isUser",
				value = "1",
				httpOnly = "true",
				preserveCase = "true"
			);
		}




		return true;
	}


	public boolean function OnApplicationStart() {
		application[ "appversion" ] = this.appversion;
		application[ "appTitleName" ] = "Lucee Admin Language Editor " & this.appversion;
		application[ "maxWorkingSizeMB" ] = 50;
		application[ "maxFileCountInWorkingDir" ] = 2;

		return true;
	}



	public boolean function OnSessionStart() {
		if( !getHTTPRequestData( false ).headers.accept.findnocase( "*/*" ) ) {
			cfheader( statuscode = "403", statustext = "Forbidden" );
			echo( "<html><body>Not Available</body></html>" );
			abort;
		}


		if( !isRunningLocal() ) {
			sessionRotate();
			session.tmpDirectoryPath = dateTimeFormat( now(), "yyyy-mm-dd-HH-nn-ss-l" ) & "-" & hash( now(), "md5" ) & "/";

			// cleanup from old temp files
			tmpLangEditorService = new components.LangEditorService()
			tmpLangEditorService.cleanTempDirs();
		}

		location( "/", "false", "302" );

		return true;
	}


	public boolean function OnSessionEnd() {
		ladminEdit = new components.LangEditorService();
		if( !directoryExists( ladminEdit.workingDir ) ) {
			directoryCreate( ladminEdit.workingDir );
		}
	}


	public boolean function isRunningLocal() localmode = true {
		if( cgi.http_host == "127.0.0.1:8080" ) {
			result = true;
		} else {
			result = false;
		}

		return result;
	}





	public void function onError( required any exception, required string eventname ) {
		if( arguments.exception.type == "missinginclude" ) {
			cfheader( statuscode = "404", statustext = "PAGE NOT FOUND" );
			echo( "404 Page Not Found" );
			abort;
		} else {
			content reset="true";
			cfheader( statuscode = "500", statustext = "Internal Server Error" );
			echo( "An internal Server Error has occured. 500 Error.<hr>" );

			if( isRunningLocal() || true ) {
				echo( "Message: <b>" & replaceNoCase(
					arguments.exception.message,
					expandPath( ".." ),
					"",
					"ALL"
				) & "</b><br><br>" );


				echo( "Type of Exception: <b>" & encodeForHTML( arguments.exception.type ) & "</b><br><br>" );


				for( TagContextError in arguments.exception.TagContext ) {
					echo( "<i>" & TagContextError.codePrintHTML & "</i><br>" );
					echo( "Template: <b>" & replaceNoCase(
						TagContextError.template,
						expandPath( ".." ),
						"",
						"ALL"
					) & "</b><br><br>" );
				}
			}
		}
	}

}
