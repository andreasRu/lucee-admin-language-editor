 component hint="LanguagePack" extends="lucee.admin.plugin.Plugin" {

    /**
     * Initialize Plugin
     */
    public function init( struct lang, struct app ){

        this.webContextPath= expandPath("{lucee-web}/context");

        app.availableLanguages=getAvailableLanguages();

        // copy original text.cfm from lucee admin to be able to use it as the swticher
        if( !fileExists( this.webContextPath & "/admin/resources/text.cfm" )  ){
             cfzip ( action="unzip",
                destination= this.webContextPath & "/admin/",
                entrypath="resources/text.cfm"
                file= this.webContextPath & "/lucee-admin.lar");
        }
        
    
    }

    private function getAvailableLanguages( ) localmode=true { 

        result=[ : ];
        availableLangRessources= getAvailableLanguagesFromResourceFiles();
        for( language in availableLangRessources ){
              availableLanguages=parseXMLDataToStruct( getLanguageXMLDataByLettercode( language ) ) ;
              result.insert( language, availableLanguages[ "XmlRoot.XmlAttributes.label" ] );
        }
        return result;
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

    


     private array function getAvailableLanguagesFromResourceFiles(){
        
         local.langResourcePath= this.webContextPath & "/admin/resources/language";
         cfdirectory( directory=local.langResourcePath, action="list", name="filequery", filter="*.xml");
         result=[];
         for ( file in filequery ) { 
             result.append( listFirst( file.name, "." ) );
         }
         return result;
     }

    /**
	* returns XML data of a language resource file as a struct
	*/
	private struct function getLanguageXMLDataByLettercode( string languageISOLetterCode required ) localmode=true {
        langResourcePath= this.webContextPath & "/admin/resources/language";
        myXML=[:];
        xmlString = fileread( langResourcePath & "/#arguments.languageISOLetterCode#.xml", "UTF-8" );
        parsedXML=xmlParse( xmlString );
        result=parsedXML;
        return result;
     
    }

    
    public function overview( struct lang, struct app, struct req ){ }

 
 }
