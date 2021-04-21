
<cfscript>
	public struct function parseXMLDataToStruct( 
			
		struct XMLData required ){
			
		local.parsedXMLResult["XmlRoot.XmlComment"]=arguments.XMLData.XmlRoot.XmlComment;
		local.parsedXMLResult["XmlRoot.XmlAttributes.key"]=arguments.XMLData.XmlRoot.XmlAttributes.key;
		local.parsedXMLResult["XmlRoot.XmlAttributes.label"]=arguments.XMLData.XmlRoot.XmlAttributes.label;
		
		loop from="1" to="#arrayLen( arguments.XMLData.XmlRoot.XmlChildren )#" index="i" {

		 	local.keyName=arguments.XMLData["XmlRoot"]["XmlChildren"][i]["XmlAttributes"]["key"];
		 	local.parsedXMLResult[ local.keyName ]=arguments.XMLData.XmlRoot.XmlChildren[i].XmlText;

		}

		return local.parsedXMLResult;

	}

	public query function getAvailableJavaLocalesAsQuery(){

		// Get Locale List
		local.JavaLocale = CreateObject("java", "java.util.Locale");
		local.availableJavaLocalesArray=JavaLocale.getAvailableLocales();
		local.availableJavaLocalesQuery = queryNew("languagecode,displayname");
		cfloop( from="1" to="#arraylen(availableJavaLocalesArray)#" index="i" ){
			if( len( availableJavaLocalesArray[i].toLanguageTag() ) == 2 ){
					queryAddRow(availableJavaLocalesQuery,{languagecode=availableJavaLocalesArray[i].toLanguageTag() ,displayname=availableJavaLocalesArray[i].getDisplayname()});
				}	 
		}
		```
		<cfquery dbtype="query" name="local.result">
			SELECT languagecode, displayname
			FROM availableJavaLocalesQuery
			ORDER by languagecode
		</cfquery>
		```	
		return local.result;

	}


</cfscript>



<cfoutput>
	
	<cfset myXML={}>
	<cfset availableLanguagesArray=[]>
	
	<cfset adminLanguageResourcePath=expandPath("../") & ".CommandBoxContexts/WEB-INF/lucee-web/context/admin/resources/language/">
	
	<cfif isDefined("form.downloadLanguageXMLFile") and len(form.downloadLanguageXMLFile) is 2 and FileExists("#adminLanguageResourcePath##form.downloadLanguageXMLFile#.xml")>
		<cfcontent type = "text/txt" file = "#adminLanguageResourcePath##form.downloadLanguageXMLFile#.xml"
		deleteFile = "no">
		<cfabort>
	</cfif>

	<cfif not FileExists("#adminLanguageResourcePath#en.xml")>
		Web-Context couldn't be found!
		<cfabort>
	</cfif>
	
	Reading data from Lucees (#encodeForHtml(server.lucee.version)#) WEB Admininstrator at:<br>#encodeForHtml(adminLanguageResourcePath)#<hr>

	<!---cfset adminLanguageResourcePath="C:\lucee-dev\webapps\ROOT\WEB-INF\lucee\context\admin\resources\language"--->
	
	<cfif isDefined("form.createLanguageXMLFile")>
		<cfif len(form.createLanguageXMLFile) is 2 
			  and arrayContains( availableJavaLocalesArray, form.createLanguageXMLFile) >
			<cfif FileExists("#adminLanguageResourcePath##form.createLanguageXMLFile#.xml")>
					#encodeForHTML("#form.createLanguageXMLFile#.xml already exists. File creation not executed!")#
			<cfelse>
				CREATING FILE:
				<cffile action="read" file="#adminLanguageResourcePath#\en.xml" variable="xmlString">
				
				<cfset myXML[form.createLanguageXMLFile] =  xmlParse(xmlString)>
				<cfset xmlData[form.createLanguageXMLFile]= parseXMLDataToStruct( myXML[form.createLanguageXMLFile] )>

				<!---cfdump var="#xmlData#"--->
				<!---cfabort--->
				<cfsavecontent variable="xmlFileContent"><?xml version="1.0" encoding="UTF-8"?><language key="#form.createLanguageXMLFile#" label=""><cfloop struct="#xmlData[form.createLanguageXMLFile]#" item="i"><data key="#i#"><!---#encodeForXML(xmlData[form.createLanguageXMLFile][i])#---></data></cfloop></language></cfsavecontent>
				<cffile action="write" file="#adminLanguageResourcePath##form.createLanguageXMLFile#.xml" output="#xmlFileContent#">
				FILE CREATED AT YOUR WEBCONTEXT AT: #adminLanguageResourcePath##form.createLanguageXMLFile#.xml 
			</cfif>
		</cfif>
	</cfif>



	<!-- Read available language files from tde admin web context and parse XML Data--->
	<cfdirectory directory="#adminLanguageResourcePath#" action="list" name="languageResourceFiles">
	<cfloop query="languageResourceFiles">Language Resource File '#languageResourceFiles.name#' found<br></cfloop>
	
	<cfloop query="languageResourceFiles">
		<cfset language=listFirst(languageResourceFiles["name"],".")>
		<cffile action="read" file="#adminLanguageResourcePath#\#languageResourceFiles["name"]#" variable="xmlString">
		<cfset myXML[language] = xmlParse(xmlString)>
		<cfset ArrayAppend(availableLanguagesArray,language) >
	</cfloop>


	


	<!-- Save data to a struct witd tde original xml-key-names as struct keys --> 
	<cfloop from="1" to="#arrayLen( availableLanguagesArray )#" index="k" >
		<cfset xmlData[availableLanguagesArray[k]]= parseXMLDataToStruct( myXML[availableLanguagesArray[k]] )>
	</cfloop>

	
	<!-- dump data as table --->
	<table border="1">

		<tr>
			<!---th>XmlRoot.xmlName</th--->
			<th><!---XmlAttributes["key"]---></th>
			<!---th>XmlComment</th--->
			<th>XmlAttributes["label"]</th>
			<cfloop from="1" to="#arrayLen( myXML["en"]["XmlRoot"]["XmlChildren"] )#" index="i">
				<th style="vertical-align: top;">#htmleditformat(myXML["en"]["XmlRoot"]["XmlChildren"][i]["XmlAttributes"]["key"])#</th>
			</cfloop>
		</tr>
		<tr style="border-bottom: 1px solid green;background-color: green;">
			<!---th>XmlRoot.xmlName</th--->
			<td>#myXML["en"].XmlRoot.XmlAttributes.key#</td>
			<!---th>XmlComment</th--->
			<td>#htmleditformat(myXML["en"].XmlRoot.XmlAttributes.label)#</td>
			<cfloop from="1" to="#arrayLen( myXML["en"]["XmlRoot"]["XmlChildren"] )#" index="i">
				<td style="vertical-align: top;"><textarea rows="4" readonly>#htmleditformat(xmlData["en"][myXML["en"]["XmlRoot"]["XmlChildren"][i]["XmlAttributes"]["key"]])#</textarea></td>
			</cfloop>
		</tr>
		

		<cfloop from="1" to="#arrayLen( availableLanguagesArray )#" index="k" >
			<tr>
				<!---td style="vertical-align: top;">#myXML[availableLanguagesArray[k]]["XmlRoot"]["xmlName"]#</td--->
				<td style="vertical-align: top;">
					#myXML[availableLanguagesArray[k]].XmlRoot.XmlAttributes.key#
				<!---td><textarea rows="4">#htmleditformat(myXML[availableLanguagesArray[k]].XmlRoot.XmlComment)#</textarea></td--->
				<td><textarea rows="4" spellcheck="true" lang="#availableLanguagesArray[k]#">#htmleditformat(myXML[availableLanguagesArray[k]].XmlRoot.XmlAttributes.label)#</textarea></td>
				<cfloop from="1" to="#arrayLen( myXML["en"]["XmlRoot"]["XmlChildren"] )#" index="i">
					<cfset attributeName=myXML["en"]["XmlRoot"]["XmlChildren"][i]["XmlAttributes"]["key"]>
					<cfif isdefined("xmlData[availableLanguagesArray[k]][attributeName]") and xmlData[availableLanguagesArray[k]][attributeName] is not "">
					<td><textarea rows="4" spellcheck="true" lang="#availableLanguagesArray[k]#">#htmleditformat(xmlData[availableLanguagesArray[k]][attributeName])#</textarea></td>
					<cfelse>
					<td><textarea rows="4" spellcheck="true" lang="#availableLanguagesArray[k]#" style="background-color: yellow;"></textarea></td>
					</cfif>
				</cfloop>
			</tr>
		</cfloop>
	</table>


    <cfset availableJavaLocalesAsQuery = getAvailableJavaLocalesAsQuery()>

	<div style="margin-top:25px">Create an empty language xml resource file for:</div>
	<form action="/index.cfm" method="post" >
		<select name="createLanguageXMLFile" onChange="document.getElementById('formSendButton').style.display='block';">
			<option value="">Please select language</option>
			<cfloop query="availableJavaLocalesAsQuery">
		    	<cfif not arrayContains( availableLanguagesArray, availableJavaLocalesAsQuery.languagecode) >
		    		<option value="#availableJavaLocalesAsQuery.languagecode#">#availableJavaLocalesAsQuery.languagecode# ( #availableJavaLocalesAsQuery.displayname# )</option>
		        </cfif>
		    </cfloop>
   		</select>
   		<button id="formSendButton" onClick="this.form.submit(); this.disabled=true; this.innerText ='Sending...';" style="display:none;margin-top: 5px;">Create XML-File</button>
	</form>


	<div style="margin-top:25px">Download a xml resource file for:</div>
	<form action="/index.cfm" method="post" >
		<select name="downloadLanguageXMLFile" onChange="document.getElementById('formSendButtonDownload').style.display='block';">
			<option value="">Please select language</option>
			<cfloop from="1" to="#arraylen(availableLanguagesArray)#" index="i">
		    	<option value="#availableLanguagesArray[i]#">#availableLanguagesArray[i]#.xml</option>
		    </cfloop>
   		</select>
   		<button id="formSendButtonDownload" onClick="this.form.submit(); this.disabled=true; this.innerText ='Sending...';" style="display:none;margin-top: 5px;">Download XML-File</button>
	</form>

	

	
</cfoutput>





