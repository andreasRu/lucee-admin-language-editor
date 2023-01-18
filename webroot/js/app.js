
import $ from 'jquery';
import floatthead from 'floatthead';
import langUpdater from './langservice';
import myAjaxUtils from './myAjaxUtils';


// Make imported modules available to window object of loaded document
window.jQuery = $;
window.$ = $;
window.langUpdater = langUpdater;
window.langUpdater.myAjaxUtils = myAjaxUtils;
window.floatthead = floatthead;

export default { $, floatthead, langUpdater};

