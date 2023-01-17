import { myAjaxUtils } from "/js/myAjaxUtils.js";
    
    $( document )
        .ready( function () {

            const langUpdater = {

                /*************************
                 * Methods
                 **************************/
                myAjaxUtils: myAjaxUtils,

                updatedWithoutSaving: [],

                setEditionAsUnsaved: function( language ){
                    if( !window.langUpdater.updatedWithoutSaving.includes( language )  ){
                        window.langUpdater.updatedWithoutSaving.push( language );
                    }
                    console.log( window.langUpdater.updatedWithoutSaving );

                },

                copyToClipboard: function( value ){
                    navigator.clipboard.writeText( value ).then(function() {
                       // console.log('successfull copying');
                      }, function(err) {
                        console.error(err);
                      });
                      alert( 'Copied \'' + value + '\' to clipboard.' );
                   

                }

                

            };

            
        window.langUpdater = langUpdater;

        } );
