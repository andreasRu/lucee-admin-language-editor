component {

	this.appversion = "2.0.1";
	this.name = "adminTranslator#server.lucee.version#-#this.appversion#";
	this.clientmanagement = "no";
	this.scriptprotect = "all";
	this.sessionmanagement = "yes";
	this.sessionStorage = "memory";
	this.sessiontimeout = "#createTimespan( 0, 0, 30, 0 )#";
	this.setclientcookies = "no";
	this.setdomaincookies = "no";
	this.applicationtimeout = "#createTimespan( 1, 0, 0, 0 )#";
	this.web.charset = "utf-8";
	this.basePath = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings[ "/components" ] = this.basePath & "components";
	this.mappings[ "/ajaxApi" ] = this.basePath & "ajaxApi";




	public boolean function OnApplicationStart() {
		application[ "appversion" ] = this.appversion;
		application[ "appTitleName" ] = "Lucee Admin Language Editor " & this.appversion;


		// get contributors from github
		cfhttp(
			method = "GET",
			charset = "utf-8",
			url = " https://api.github.com/repos/andreasRu/lucee-admin-language-editor/contributors",
			result = "result"
		);

		application[ "contributors" ] = deserializeJSON( result.filecontent );

		return true;
	}




	public boolean function OnSessionStart() {

		sessionRotate();

		cfcookie ( 
			name="cftoken",
			value="#session.cftoken#",
			httpOnly="true",
			preserveCase="true"
		);

		cfcookie ( 
			name="cfid",
			value="#session.cfid#",
			httpOnly="true",
			preserveCase="true"
		);


		if( !cgi.http_host == "127.0.0.1:8080" ) {
			// create a temporary directoryname
			session.tmpDirectoryPath = dateTimeFormat( now(), "yyyy-mm-dd-hh-nn-ss-l" ) & "-" & hash( now(), "md5" ) & "/";
		} else {
			session.tmpDirectoryPath = "";
		}

		return true;
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

			if( cgi.http_host == "127.0.0.1:8080" ) {
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
