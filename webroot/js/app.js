
import $ from 'jquery';
import floatthead from 'floatthead';
import langUpdater from './langService';


// Make imported modules available to window object of loaded document
window.jQuery = $;
window.$ = $;
window.langUpdater = langUpdater;
window.floatthead = floatthead;

console.log( window.langUpdater ); 

export default { $, floatthead, langUpdater};

