import { myAjaxUtils } from "/js/myAjaxUtils.js";
    
    $( document )
        .ready( function () {

            const langUpdater = {

                /*************************
                 * Methods
                 **************************/
                myAjaxUtils: myAjaxUtils

            };

            
        window.langUpdater = langUpdater;

        } );
