
import $ from 'jquery';
import langUpdater from './langService';


// Make imported modules available to window object of loaded document
window.jQuery = $;
window.$ = $;
window.langUpdater = langUpdater;
export default { $, langUpdater};

