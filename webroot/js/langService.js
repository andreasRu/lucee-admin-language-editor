import  myAjaxUtils from "./myAjaxUtils";


export const  langUpdater = {

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
	
	window.langUpdater=langUpdater;

	export default  langUpdater;
