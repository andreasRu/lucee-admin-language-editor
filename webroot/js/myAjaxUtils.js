/**********************************************************
* myAjaxUtils: A little ajax module to do some form validation, 
* automated Ajax requests and content updates. Depends on jQuery.
* MIT License / (c)2023 C. Andreas Rüger https://github.com/andreasRu/ 
************************************************************/
import $ from 'jquery';

export const myAjaxUtils= {

    buildPayLoad: (
        ajaxURL,
        httpMethod,
        selectorFormFields,
        selectorContentResult,
        jqueryHTMLCommand ) => {
        let formMethod = httpMethod;
       

        $( '#loadingSpinner' ).show();
        
        

        if ( httpMethod == "POST" ) {
            //get all form data 
            let formData = new FormData();
            let itemsProcessed = 0;
            let $selector = $( selectorFormFields );

            $selector.each( ( index, obj ) => {
                console.log( 'adding Fields name:' + $(obj).attr('name') + ' value:' + $(obj).val() );
                itemsProcessed++;

                let type = $( obj )
                    .attr( 'type' );

                if ( type != "checkbox" || ( type = "checkbox" && $( obj )
                        .is( ':checked' ) ) ) {
                    formData.append( $( obj )
                        .attr( 'name' ), $( obj )
                        .val() );
                }

                
               

                /* if because of async calls, call only when finished */
                if ( itemsProcessed === $selector.length ) {

                    myAjaxUtils.sendAjaxCommand( ajaxURL, formMethod, formData )

                        .done( function ( result ) {

                           //console.log('#populateDatass');
                           //console.log( [result , ajaxURL, formMethod, formData ] );
                            myAjaxUtils.populateDOMWithContent( result, selectorContentResult, jqueryHTMLCommand);  
                
                        } );

                       
                }


            } );

        } else if ( httpMethod == "GET" ){
           
            myAjaxUtils.sendAjaxCommand( ajaxURL, formMethod, undefined )
                .done( function ( result ) {
                    
                    console.log('#######populateDatas GET');
                    myAjaxUtils.populateDOMWithContent( result, selectorContentResult, jqueryHTMLCommand);  
                   
                } );
        }

    },


    populateDOMWithContent: ( result, selectorContentResult, jqueryHTMLCommand) => {

        console.log('#### populated function populateDOMWithContent:');
        console.log(result, selectorContentResult, jqueryHTMLCommand );
        
        if ( jqueryHTMLCommand == "append" 
                && result.contentForHtmlOutput ) {
                
                    $( selectorContentResult )
                    .append( result.contentForHtmlOutput );
                    $( '#loadingSpinner' ).hide();
                    
                
            
        } else if ( jqueryHTMLCommand == "prepend"  
        && result.contentForHtmlOutput) {

        $( selectorContentResult )
        .prepend( result.contentForHtmlOutput );
        $( '#loadingSpinner' ).hide();
        

    } else if ( jqueryHTMLCommand == "replaceWith") {
            
        $( selectorContentResult )
        .replaceWith( result.contentForHtmlOutput );
        $( '#loadingSpinner' ).hide();
        

    } else if ( jqueryHTMLCommand == "reloadURL") {
                
        window.location.reload();
   
    } else if ( jqueryHTMLCommand == "reloadURLDelayed") {

        setTimeout(function(){ 
            window.location.reload();
        }, 2000);
        

    } else if ( result.contentForHtmlOutput ) {

                $( selectorContentResult )
                    .html( result.contentForHtmlOutput );
                    $( '#loadingSpinner' ).hide();
                    

    }

            /* populate Flying notification Bar if specified */
            if( result.notificationFlyingBarHTML ){
                $( '#ajaxPopulateNotificationFlyingBar div' ).html(  result.notificationFlyingBarHTML );
            }else if( result.ajaxPopulateNotificationFlyingBar ){
                $( '#ajaxPopulateNotificationFlyingBar div' ).html(  result.ajaxPopulateNotificationFlyingBar );
            }

         
                        
    },


    validateAndsendAjaxForm: (
        ajaxURL,
        selectorFormFields,
        selectorContentResult,
        jqueryHTMLCommand ) => {
        let itemsProcessed = 0;
        let $selector = $( selectorFormFields );
        alert( $selector.length );
        let allItemsOK = true;
        $('.formValidationErrorText').remove();
        
        $selector.each( ( index, obj ) => {

            itemsProcessed++;

            //set to normal outline
            $( obj )
                .css( {
                    'outline': ''
                } );

            // if element is obligatory test for check
            if ( $( obj )
                .attr( 'data-isObligatory' ) == 'true' ) {

                let type = $( obj )
                    .attr( 'type' );
                let tagname = $( obj )
                    .prop( "tagName" );

                
                //checkbox
                if ( tagname == 'INPUT' && type == "checkbox" && !$( obj )
                    .is( ':checked' ) ) {
                    $( obj )
                        .css( {
                            'outline' : 'var( --formValidationHintOutline )',
                            'background' : 'var(--formValidationHintBG)'
                        } );
                    if( $( obj ).attr( 'data-formValidationErrorMessage' ) ){
                        $( '<div class="formValidationErrorText">' + $( obj ).attr( 'data-formValidationErrorMessage' ) + '</div>' ).insertBefore( $( obj ) );
                    }
                    allItemsOK = false;
                }

                //textarea
                if ( tagname == 'TEXTAREA' && $( obj )
                    .val()
                    .trim() == '' ) {
                    $( obj )
                        .css( {
                            'outline' : 'var( --formValidationHintOutline )',
                            'background' : 'var(--formValidationHintBG)'
                        } );
                        if( $( obj ).attr( 'data-formValidationErrorMessage' ) ){
                            $( '<div class="formValidationErrorText">' + $( obj ).attr( 'data-formValidationErrorMessage' ) + '</div>' ).insertBefore( $( obj ) );
                        }
                    allItemsOK = false;
                }

                //inputs
                if ( tagname == 'INPUT' && $( obj )
                    .val()
                    .trim() == '' ) {
                    $( obj )
                        .css( {
                            'outline' : 'var( --formValidationHintOutline )',
                            'background' : 'var(--formValidationHintBG)'
                        } );
                        if( $( obj ).attr( 'data-formValidationErrorMessage' ) ){
                            $( '<div class="formValidationErrorText">' + $( obj ).attr( 'data-formValidationErrorMessage' ) + '</div>' ).insertBefore( $( obj ) );
                        }
                    allItemsOK = false;
                }

                //inputs
                if ( tagname == 'SELECT' && $( obj )
                    .val()
                    .trim() == '' ) {
                    $( obj )
                        .css( {
                            'outline' : 'var( --formValidationHintOutline )',
                            'background' : 'var(--formValidationHintBG)'
                        } );
                        if( $( obj ).attr( 'data-formValidationErrorMessage' ) ){
                            $( '<div class="formValidationErrorText">' + $( obj ).attr( 'data-formValidationErrorMessage' ) + '</div>' ).insertBefore( $( obj ) );
                        }
                    allItemsOK = false;
                }

                

                /* if because of async calls, call only when finished */
                if ( itemsProcessed === $selector.length ) {
                    if ( allItemsOK ) {
                       
                        $( '#loadingSpinner' ).show();
                       
                        myAjaxUtils.buildPayLoad(
                            ajaxURL,
                            'POST',
                            selectorFormFields,
                            selectorContentResult,
                            jqueryHTMLCommand );
                    
                    } else {
                       
                        
                        return false;
                       
                    }
                }
            }


        } );


    },

    
    sendAjaxCommand: ( ajaxURL, formMethod, formData ) => {

        return $.ajax( {
            url: ajaxURL,
            type: formMethod,
            data: formData,
            processData: false,
            contentType: false,
            success: function ( contentdata ) {
                // console.log('#######returned data');
                // console.log( contentdata );
                
                return contentdata;

            },
            error: function ( e ) {
                $( 'body' ).html( '<div>Error resulting from Ajaxcall at:<br> ' + ajaxURL +' </div>' + e.responseText );
                $( '#loadingSpinner' ).hide();
                console.log( e );
         
            }

        } );


 }


};

export default myAjaxUtils;