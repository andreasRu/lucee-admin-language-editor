
<cfscript>
	/**
	 * returns XML data of an imported language resource file as a struct
	 */
	public struct function parseXMLDataToStruct( 
		struct XMLData required ){
			
		local.parsedXMLResult["XmlRoot.XmlComment"]=arguments.XMLData.XmlRoot.XmlComment;
		local.parsedXMLResult["XmlRoot.XmlAttributes.key"]=arguments.XMLData.XmlRoot.XmlAttributes.key;
		local.parsedXMLResult["XmlRoot.XmlAttributes.label"]=arguments.XMLData.XmlRoot.XmlAttributes.label;
		local.parsedXMLResult["XmlRoot.XmlAttributes.KeyData"]=[:]
		loop array="#arguments.XMLData.XmlRoot.XmlChildren#" index="itemChildrenKey" {

		 	local.keyName=itemChildrenKey["XmlAttributes"]["key"];
		 	local.parsedXMLResult["XmlRoot.XmlAttributes.KeyData"][ local.keyName ]=itemChildrenKey.XmlText;

		}

		return local.parsedXMLResult;
	}

	
	/**
	 * returns as struct of all available 2-letter codes of the underlying java.util with the referring Language DisplayName (target language)
	 */
	public struct function getAvailableJavaLocalesAsStruct(){

		// Get Locale List
		local.JavaLocale = CreateObject("java", "java.util.Locale");
		local.availableJavaLocalesArray=JavaLocale.getAvailableLocales();
        //dump( local.JavaLocale );
		//dump( local.availableJavaLocalesArray );

        // initialize an ordered struct with shorthand [:]
       
		local.availableJavaLocalesStruct =[:];
		cfloop( array= "#availableJavaLocalesArray#" item="itemLocale" ){
            //echo( dump( [ itemLocale.toLanguageTag(), itemLocale.getDisplayName(), itemLocale.getISO3Language() ] ) );
			if( ( len( itemLocale.toLanguageTag() ) == 2 )
                || ( len( itemLocale.toLanguageTag() ) > 2 
                    && listLast( itemLocale.toLanguageTag(), "-" ) != "001" 
                    && listLast( itemLocale.toLanguageTag(), "-" ) != "CS"
                    && listLast( itemLocale.toLanguageTag(), "-" ) != "150"
                    && listLast( itemLocale.toLanguageTag(), "-" ) != "XK"
                    && listLast( itemLocale.toLanguageTag(), "-" ) != "EA"
                    && listLast( itemLocale.toLanguageTag(), "-" ) != "DG"
                    && listLast( itemLocale.toLanguageTag(), "-" ) != "419"
                    && listLast( itemLocale.toLanguageTag(), "-" ) != "IC" 
                    )
                )  {
				local.displayNameTargetLanguage=itemLocale.info();
				local.availableJavaLocalesStruct[itemLocale.toLanguageTag()] = UcFirst( local.displayNameTargetLanguage["display"]["language"] );
				}	 
		}
		
		return local.availableJavaLocalesStruct;

	}

</cfscript>



<cfoutput>
	
	<cfset myXML=[:]>
	<cfset availableLanguagesArray=[]>
	<cfset availableJavaLocalesAsStruct = getAvailableJavaLocalesAsStruct()>
	<cfset availableJavaLocalesArray = StructKeyArray( availableJavaLocalesAsStruct )>
	<cfset arraySort( availableJavaLocalesArray , "textnocase", "asc")>
	<cfset adminLanguageResourcePath=expandPath("../") & ".CommandBoxContexts/WEB-INF/lucee-web/context/admin/resources/language/">
	
	
	
	<!--- Download a xml ressource file --->
	<cfif isDefined( "form.downloadLanguageXMLFile" )>
		<cfif len( form.downloadLanguageXMLFile ) is 2 
			and reFind( "[A-Za-z]+", form.downloadLanguageXMLFile )
			and FileExists("#adminLanguageResourcePath##form.downloadLanguageXMLFile#.xml")>

				<cfheader 	name="Content-Disposition" 
							value="attachment; 
							filename=#form.downloadLanguageXMLFile#.xml">
				<cfcontent 	type = "text/xml" 
							file = "#adminLanguageResourcePath##form.downloadLanguageXMLFile#.xml"
							deleteFile = "no">
				<cfabort>

		<cfelse>

			No such file available!
	
		</cfif>
		<cfabort>
	</cfif>


	<!--- Import default English en.xml as XML, parse it to a struct and populate arrays--->
	<cfif FileExists("#adminLanguageResourcePath#en.xml")>
		<cffile action="read" file="#adminLanguageResourcePath#en.xml" variable="xmlString">
		<cfset myXML["en"] = xmlParse(xmlString)>
		<cfset xmlData[ "en" ]= parseXMLDataToStruct( myXML[ "en" ] )>
		<cfset ArrayAppend(availableLanguagesArray,"en") >
		<cfset allDefaultDataKeysFromEnglishAsArray= StructKeyArray( xmlData["en"]["XmlRoot.XmlAttributes.KeyData"])>
		<cfset arraySort( allDefaultDataKeysFromEnglishAsArray , "textnocase", "asc")>
	<cfelse>
		Web-Context couldn't be found!
		<cfabort>
	</cfif>
	
	Reading data from Lucees (#encodeForHtml(server.lucee.version)#) WEB Admininstrator at:<br>#encodeForHtml(adminLanguageResourcePath)#<hr>

	<!--- Generate a new default language xml file with the help of default en.xml file for available keys --->
	<cfif isDefined("form.createLanguageXMLFile")>
		<cfset createFileLanguageCode= listFirst( form.createLanguageXMLFile, ";" )>
		<cfset createFileLanguageDisplayname= listLast( form.createLanguageXMLFile, ";" )>
		<cfif len( createFileLanguageCode ) is 2 or true
			  and arrayContains( availableJavaLocalesArray, createFileLanguageCode) >
			<cfif FileExists("#adminLanguageResourcePath##createFileLanguageCode#.xml")>
				<div style="color:red;border:1px solid red;padding:5px;">
					Resource file #encodeForHTML("#createFileLanguageCode#")#.xml for language "#encodeForHtml(createFileLanguageDisplayname)#" already exists. File creation skipped!
				</div>
			<cfelse>
				
				<div style="color:green;border:1px solid green;padding:5px;">
					
					Generating resource file "#encodeForHTML( createFileLanguageCode )#.xml" for 
					language "#encodeForHtml(createFileLanguageDisplayname)#" at 
					#adminLanguageResourcePath##createFileLanguageCode#.xml
					
					<cffile action="read" file="#adminLanguageResourcePath#\en.xml" variable="xmlString">
					
					<cfset myXML[createFileLanguageCode] =  xmlParse(xmlString)>
					<cfset xmlData[createFileLanguageCode]= parseXMLDataToStruct( myXML[createFileLanguageCode] )>

					<cfsavecontent variable="xmlFileContent"><!---
					---><?xml version="1.0" encoding="UTF-8"?>
<!--- 				--->		<language key="#encodeForXml(createFileLanguageCode)#" label="#encodeForXMLAttribute( createFileLanguageDisplayname )#">
<!--- 				--->			<cfloop array="#allDefaultDataKeysFromEnglishAsArray#" item="itemDataKey" ><!---
					--->					<data key="#encodeForXMLAttribute( itemDataKey )#"></data>
<!--- 				--->			</cfloop>
<!--- 				--->		</language></cfsavecontent>
					
					<cffile	action="write" file="#adminLanguageResourcePath##createFileLanguageCode#.xml" output="#xmlFileContent#">
					
				</div>

			</cfif>
		</cfif>
	</cfif>



	<!--- Read/import available language files from de admin web context and parse as XML Data --->
	<cfdirectory directory="#adminLanguageResourcePath#" action="list" name="languageResourceFiles">
	<div>
		Language resource files found: 
		<cfloop query="languageResourceFiles">
			<cfif languageResourceFiles["name"] != "en.xml">
				<cfset language=listFirst(languageResourceFiles["name"],".")>
				<cffile action="read" file="#adminLanguageResourcePath#\#languageResourceFiles["name"]#" variable="xmlString">
				<cfset myXML[language] = xmlParse(xmlString)>
				<cfset ArrayAppend(availableLanguagesArray,language) >
				'#languageResourceFiles.name#',
			</cfif>
		</cfloop>
	</div>

	
	<!-- Parse the xml data to a struct with the original xml-langauge-key --> 
	<cfloop array="#availableLanguagesArray#" item="itemLanguage" >
		<cfset xmlData[ itemLanguage ]= parseXMLDataToStruct( myXML[ itemLanguage ] )>
	</cfloop>

    <div style="margin-top:25px;">Create an empty language xml resource file for:</div>
	<form action="/index.cfm" method="post">
		<select name="createLanguageXMLFile" onChange="document.getElementById('formSendButton').style.display='block';">
			<option value="">Please select language</option>
			<cfloop array="#availableJavaLocalesArray#" item="languageKey">
		    	<cfif not arrayContains( availableLanguagesArray, languageKey) >
		    		<option value="#encodeForHtmlAttribute( languageKey & ";" & availableJavaLocalesAsStruct[ languageKey ] )#">#encodeForHTML( languageKey )# - #encodeForHTML( "#availableJavaLocalesAsStruct[ languageKey ]#" )#</option>
		        </cfif>
		    </cfloop>
   		</select>
   		<button id="formSendButton" onClick="this.form.submit(); this.disabled=true; this.innerText ='Sending...';" style="display:none;margin-top: 5px;">Create XML-File</button>
	</form>

	
	<div style="margin-top:25px">Download a xml resource file for:</div>
	<form action="/index.cfm" method="post" target="_blank" >
		<select name="downloadLanguageXMLFile" onChange="document.getElementById('formSendButtonDownload').style.display='block';">
			<option value="">Please select language</option>
			<cfloop array="#availableLanguagesArray#" item="languageKey">
		    	<option value="#encodeForHtmlAttribute( languageKey )#">#languageKey#.xml - #encodeForHTML( "#availableJavaLocalesAsStruct[ languageKey ]#" )#</option>
		    </cfloop>
   		</select>
   		<button id="formSendButtonDownload" onClick="this.form.submit();this.style.display='none';" style="display:none;margin-top: 5px;">Download XML-File</button>
	</form>

	
    <style>
        body, table {font-family: Tahoma;}
        .langEditor  tr { display: block; float: left; height:10rem; }
        .langEditor  th, .langEditor td { display: block; height:10rem; }
        .langEditor  th { text-align: left;}
        .langEditor button {display:block;}
        .langEditor textarea { height:100%; width:100%;}
    </style>
	
	<table class="langEditor" border="1">
		<tr>
			<th></th>
			<th>XmlAttributes["label"]/save</th>
			<cfloop array="#allDefaultDataKeysFromEnglishAsArray#" item="itemDataKey">
				<th style="vertical-align: top;">#htmleditformat( itemDataKey )#  </th>
			</cfloop>
			
		</tr>
		<tr style="border-bottom: 1px solid green;background-color: green;">
			<td>#htmleditformat(xmlData["en"]["XmlRoot.XmlAttributes.key"])#</td>
			<td>#htmleditformat(xmlData["en"]["XmlRoot.XmlAttributes.label"])#</td>
			<cfloop array="#allDefaultDataKeysFromEnglishAsArray#" item="itemDataKey">
				<td><textarea rows="4" spellcheck="true" lang="#encodeForhtml(xmlData["en"]["XmlRoot.XmlAttributes.key"])#" >#xmlData["en"]["XmlRoot.XmlAttributes.KeyData"][ itemDataKey ]#</textarea></td>
			</cfloop>
		</tr>

		<cfloop array="#availableLanguagesArray#" item="itemLanguageKey" >
			<cfif itemLanguageKey is not "en">
                <tr id="#itemLanguageKey#">
                    <td>#htmleditformat( xmlData[ itemLanguageKey ][ "XmlRoot.XmlAttributes.key" ] )# <button onClick="alert('save triggered for #encodeForHTMLAttribute( encodeForJavascript( itemLanguageKey ))#');">Save "#itemLanguageKey#.xml"</button>   </td>
                    <td>#htmleditformat( xmlData[ itemLanguageKey ][ "XmlRoot.XmlAttributes.label" ] )#</td>
                    <cfloop array="#allDefaultDataKeysFromEnglishAsArray#" item="itemDataKey" >
						<cfif StructKeyExists( xmlData[ itemLanguageKey ]["XmlRoot.XmlAttributes.KeyData"], itemDataKey ) 
							and xmlData[ itemLanguageKey ]["XmlRoot.XmlAttributes.KeyData"][ itemDataKey ] is not "">
							<td><textarea name="#itemDataKey#" rows="4" 
											spellcheck="true" 
											lang="#xmlData[ itemLanguageKey ]["XmlRoot.XmlAttributes.key"]#">#xmlData[ itemLanguageKey ]["XmlRoot.XmlAttributes.KeyData"][ itemDataKey ]#</textarea></td>
						<cfelse>
							<td><textarea name="#itemDataKey#" rows="4" 
											spellcheck="true" 
											style="background-color: yellow"
											lang="#xmlData[ itemLanguageKey ]["XmlRoot.XmlAttributes.key"]#"></textarea></td>
						</cfif>
                    </cfloop>
			    </tr>
            </cfif>
		</cfloop>
	</table>

	
</cfoutput>





