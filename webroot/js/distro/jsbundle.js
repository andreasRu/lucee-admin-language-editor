/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./webroot/js/app.js":
/*!***************************!*\
  !*** ./webroot/js/app.js ***!
  \***************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__)
/* harmony export */ });
/* harmony import */ var jquery__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! jquery */ "./node_modules/jquery/dist/jquery.js");
/* harmony import */ var jquery__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(jquery__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var floatthead__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! floatthead */ "./node_modules/floatthead/dist/jquery.floatThead.min.js");
/* harmony import */ var floatthead__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(floatthead__WEBPACK_IMPORTED_MODULE_1__);
/* harmony import */ var _langservice__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./langservice */ "./webroot/js/langservice.js");
/* harmony import */ var _myAjaxUtils__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./myAjaxUtils */ "./webroot/js/myAjaxUtils.js");





// Make imported modules available to window object of loaded document
window.jQuery = (jquery__WEBPACK_IMPORTED_MODULE_0___default());
window.$ = (jquery__WEBPACK_IMPORTED_MODULE_0___default());
window.langUpdater = _langservice__WEBPACK_IMPORTED_MODULE_2__["default"];
window.langUpdater.myAjaxUtils = _myAjaxUtils__WEBPACK_IMPORTED_MODULE_3__["default"];
window.floatthead = (floatthead__WEBPACK_IMPORTED_MODULE_1___default());
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = ({
  $: (jquery__WEBPACK_IMPORTED_MODULE_0___default()),
  floatthead: (floatthead__WEBPACK_IMPORTED_MODULE_1___default()),
  langUpdater: _langservice__WEBPACK_IMPORTED_MODULE_2__["default"]
});

/***/ }),

/***/ "./webroot/js/langservice.js":
/*!***********************************!*\
  !*** ./webroot/js/langservice.js ***!
  \***********************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__),
/* harmony export */   "langUpdater": () => (/* binding */ langUpdater)
/* harmony export */ });
/* harmony import */ var _myAjaxUtils__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./myAjaxUtils */ "./webroot/js/myAjaxUtils.js");

const langUpdater = {
  /*************************
   * Methods
   **************************/
  myAjaxUtils: _myAjaxUtils__WEBPACK_IMPORTED_MODULE_0__["default"],
  updatedWithoutSaving: [],
  setEditionAsUnsaved: function (language) {
    if (!window.langUpdater.updatedWithoutSaving.includes(language)) {
      window.langUpdater.updatedWithoutSaving.push(language);
    }
    console.log(window.langUpdater.updatedWithoutSaving);
  },
  copyToClipboard: function (value) {
    navigator.clipboard.writeText(value).then(function () {
      // console.log('successfull copying');
    }, function (err) {
      console.error(err);
    });
    alert('Copied \'' + value + '\' to clipboard.');
  }
};
window.langUpdater = langUpdater;
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = ({
  langUpdater
});

/***/ }),

/***/ "./webroot/js/myAjaxUtils.js":
/*!***********************************!*\
  !*** ./webroot/js/myAjaxUtils.js ***!
  \***********************************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   "default": () => (__WEBPACK_DEFAULT_EXPORT__),
/* harmony export */   "myAjaxUtils": () => (/* binding */ myAjaxUtils)
/* harmony export */ });
/* harmony import */ var jquery__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! jquery */ "./node_modules/jquery/dist/jquery.js");
/* harmony import */ var jquery__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(jquery__WEBPACK_IMPORTED_MODULE_0__);
/**********************************************************
* myAjaxUtils: A little ajax module to do some form validation, 
* automated Ajax requests and content updates. Depends on jQuery.
* MIT License / (c)2023 C. Andreas Rüger https://github.com/andreasRu/ 
************************************************************/

const myAjaxUtils = {
  buildPayLoad: (ajaxURL, httpMethod, selectorFormFields, selectorContentResult, jqueryHTMLCommand) => {
    let formMethod = httpMethod;
    jquery__WEBPACK_IMPORTED_MODULE_0___default()('#loadingSpinner').show();
    if (httpMethod == "POST") {
      //get all form data 
      let formData = new FormData();
      let itemsProcessed = 0;
      let $selector = jquery__WEBPACK_IMPORTED_MODULE_0___default()(selectorFormFields);
      $selector.each((index, obj) => {
        console.log('adding Fields name:' + jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('name') + ' value:' + jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).val());
        itemsProcessed++;
        let type = jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('type');
        if (type != "checkbox" || (type =  true && jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).is(':checked'))) {
          formData.append(jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('name'), jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).val());
        }

        /* if because of async calls, call only when finished */
        if (itemsProcessed === $selector.length) {
          myAjaxUtils.sendAjaxCommand(ajaxURL, formMethod, formData).done(function (result) {
            //console.log('#populateDatass');
            //console.log( [result , ajaxURL, formMethod, formData ] );
            myAjaxUtils.populateDOMWithContent(result, selectorContentResult, jqueryHTMLCommand);
          });
        }
      });
    } else if (httpMethod == "GET") {
      myAjaxUtils.sendAjaxCommand(ajaxURL, formMethod, undefined).done(function (result) {
        console.log('#######populateDatas GET');
        myAjaxUtils.populateDOMWithContent(result, selectorContentResult, jqueryHTMLCommand);
      });
    }
  },
  populateDOMWithContent: (result, selectorContentResult, jqueryHTMLCommand) => {
    console.log('#### populated function populateDOMWithContent:');
    console.log(result, selectorContentResult, jqueryHTMLCommand);
    if (jqueryHTMLCommand == "append" && result.contentForHtmlOutput) {
      jquery__WEBPACK_IMPORTED_MODULE_0___default()(selectorContentResult).append(result.contentForHtmlOutput);
      jquery__WEBPACK_IMPORTED_MODULE_0___default()('#loadingSpinner').hide();
    } else if (jqueryHTMLCommand == "prepend" && result.contentForHtmlOutput) {
      jquery__WEBPACK_IMPORTED_MODULE_0___default()(selectorContentResult).prepend(result.contentForHtmlOutput);
      jquery__WEBPACK_IMPORTED_MODULE_0___default()('#loadingSpinner').hide();
    } else if (jqueryHTMLCommand == "replaceWith") {
      jquery__WEBPACK_IMPORTED_MODULE_0___default()(selectorContentResult).replaceWith(result.contentForHtmlOutput);
      jquery__WEBPACK_IMPORTED_MODULE_0___default()('#loadingSpinner').hide();
    } else if (jqueryHTMLCommand == "reloadURL") {
      window.location.reload();
    } else if (jqueryHTMLCommand == "reloadURLDelayed") {
      setTimeout(function () {
        window.location.reload();
      }, 2000);
    } else if (result.contentForHtmlOutput) {
      jquery__WEBPACK_IMPORTED_MODULE_0___default()(selectorContentResult).html(result.contentForHtmlOutput);
      jquery__WEBPACK_IMPORTED_MODULE_0___default()('#loadingSpinner').hide();
    }

    /* populate Flying notification Bar if specified */
    if (result.notificationFlyingBarHTML) {
      jquery__WEBPACK_IMPORTED_MODULE_0___default()('#ajaxPopulateNotificationFlyingBar div').html(result.notificationFlyingBarHTML);
    } else if (result.ajaxPopulateNotificationFlyingBar) {
      jquery__WEBPACK_IMPORTED_MODULE_0___default()('#ajaxPopulateNotificationFlyingBar div').html(result.ajaxPopulateNotificationFlyingBar);
    }
  },
  validateAndsendAjaxForm: (ajaxURL, selectorFormFields, selectorContentResult, jqueryHTMLCommand) => {
    let itemsProcessed = 0;
    let $selector = jquery__WEBPACK_IMPORTED_MODULE_0___default()(selectorFormFields);
    alert($selector.length);
    let allItemsOK = true;
    jquery__WEBPACK_IMPORTED_MODULE_0___default()('.formValidationErrorText').remove();
    $selector.each((index, obj) => {
      itemsProcessed++;

      //set to normal outline
      jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).css({
        'outline': ''
      });

      // if element is obligatory test for check
      if (jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('data-isObligatory') == 'true') {
        let type = jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('type');
        let tagname = jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).prop("tagName");

        //checkbox
        if (tagname == 'INPUT' && type == "checkbox" && !jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).is(':checked')) {
          jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).css({
            'outline': 'var( --formValidationHintOutline )',
            'background': 'var(--formValidationHintBG)'
          });
          if (jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('data-formValidationErrorMessage')) {
            jquery__WEBPACK_IMPORTED_MODULE_0___default()('<div class="formValidationErrorText">' + jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('data-formValidationErrorMessage') + '</div>').insertBefore(jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj));
          }
          allItemsOK = false;
        }

        //textarea
        if (tagname == 'TEXTAREA' && jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).val().trim() == '') {
          jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).css({
            'outline': 'var( --formValidationHintOutline )',
            'background': 'var(--formValidationHintBG)'
          });
          if (jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('data-formValidationErrorMessage')) {
            jquery__WEBPACK_IMPORTED_MODULE_0___default()('<div class="formValidationErrorText">' + jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('data-formValidationErrorMessage') + '</div>').insertBefore(jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj));
          }
          allItemsOK = false;
        }

        //inputs
        if (tagname == 'INPUT' && jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).val().trim() == '') {
          jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).css({
            'outline': 'var( --formValidationHintOutline )',
            'background': 'var(--formValidationHintBG)'
          });
          if (jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('data-formValidationErrorMessage')) {
            jquery__WEBPACK_IMPORTED_MODULE_0___default()('<div class="formValidationErrorText">' + jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('data-formValidationErrorMessage') + '</div>').insertBefore(jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj));
          }
          allItemsOK = false;
        }

        //inputs
        if (tagname == 'SELECT' && jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).val().trim() == '') {
          jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).css({
            'outline': 'var( --formValidationHintOutline )',
            'background': 'var(--formValidationHintBG)'
          });
          if (jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('data-formValidationErrorMessage')) {
            jquery__WEBPACK_IMPORTED_MODULE_0___default()('<div class="formValidationErrorText">' + jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj).attr('data-formValidationErrorMessage') + '</div>').insertBefore(jquery__WEBPACK_IMPORTED_MODULE_0___default()(obj));
          }
          allItemsOK = false;
        }

        /* if because of async calls, call only when finished */
        if (itemsProcessed === $selector.length) {
          if (allItemsOK) {
            jquery__WEBPACK_IMPORTED_MODULE_0___default()('#loadingSpinner').show();
            myAjaxUtils.buildPayLoad(ajaxURL, 'POST', selectorFormFields, selectorContentResult, jqueryHTMLCommand);
          } else {
            return false;
          }
        }
      }
    });
  },
  sendAjaxCommand: (ajaxURL, formMethod, formData) => {
    return jquery__WEBPACK_IMPORTED_MODULE_0___default().ajax({
      url: ajaxURL,
      type: formMethod,
      data: formData,
      processData: false,
      contentType: false,
      success: function (contentdata) {
        // console.log('#######returned data');
        // console.log( contentdata );

        return contentdata;
      },
      error: function (e) {
        jquery__WEBPACK_IMPORTED_MODULE_0___default()('body').html('<div>Error resulting from Ajaxcall at:<br> ' + ajaxURL + ' </div>' + e.responseText);
        jquery__WEBPACK_IMPORTED_MODULE_0___default()('#loadingSpinner').hide();
        console.log(e);
      }
    });
  }
};
/* harmony default export */ const __WEBPACK_DEFAULT_EXPORT__ = (myAjaxUtils);

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The module cache
/******/ 	var __webpack_module_cache__ = {};
/******/ 	
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/ 		// Check if module is in cache
/******/ 		var cachedModule = __webpack_module_cache__[moduleId];
/******/ 		if (cachedModule !== undefined) {
/******/ 			return cachedModule.exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = __webpack_module_cache__[moduleId] = {
/******/ 			// no module.id needed
/******/ 			// no module.loaded needed
/******/ 			exports: {}
/******/ 		};
/******/ 	
/******/ 		// Execute the module function
/******/ 		__webpack_modules__[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/ 	
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/ 	
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = __webpack_modules__;
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/chunk loaded */
/******/ 	(() => {
/******/ 		var deferred = [];
/******/ 		__webpack_require__.O = (result, chunkIds, fn, priority) => {
/******/ 			if(chunkIds) {
/******/ 				priority = priority || 0;
/******/ 				for(var i = deferred.length; i > 0 && deferred[i - 1][2] > priority; i--) deferred[i] = deferred[i - 1];
/******/ 				deferred[i] = [chunkIds, fn, priority];
/******/ 				return;
/******/ 			}
/******/ 			var notFulfilled = Infinity;
/******/ 			for (var i = 0; i < deferred.length; i++) {
/******/ 				var [chunkIds, fn, priority] = deferred[i];
/******/ 				var fulfilled = true;
/******/ 				for (var j = 0; j < chunkIds.length; j++) {
/******/ 					if ((priority & 1 === 0 || notFulfilled >= priority) && Object.keys(__webpack_require__.O).every((key) => (__webpack_require__.O[key](chunkIds[j])))) {
/******/ 						chunkIds.splice(j--, 1);
/******/ 					} else {
/******/ 						fulfilled = false;
/******/ 						if(priority < notFulfilled) notFulfilled = priority;
/******/ 					}
/******/ 				}
/******/ 				if(fulfilled) {
/******/ 					deferred.splice(i--, 1)
/******/ 					var r = fn();
/******/ 					if (r !== undefined) result = r;
/******/ 				}
/******/ 			}
/******/ 			return result;
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/compat get default export */
/******/ 	(() => {
/******/ 		// getDefaultExport function for compatibility with non-harmony modules
/******/ 		__webpack_require__.n = (module) => {
/******/ 			var getter = module && module.__esModule ?
/******/ 				() => (module['default']) :
/******/ 				() => (module);
/******/ 			__webpack_require__.d(getter, { a: getter });
/******/ 			return getter;
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/define property getters */
/******/ 	(() => {
/******/ 		// define getter functions for harmony exports
/******/ 		__webpack_require__.d = (exports, definition) => {
/******/ 			for(var key in definition) {
/******/ 				if(__webpack_require__.o(definition, key) && !__webpack_require__.o(exports, key)) {
/******/ 					Object.defineProperty(exports, key, { enumerable: true, get: definition[key] });
/******/ 				}
/******/ 			}
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/hasOwnProperty shorthand */
/******/ 	(() => {
/******/ 		__webpack_require__.o = (obj, prop) => (Object.prototype.hasOwnProperty.call(obj, prop))
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/******/ 	/* webpack/runtime/jsonp chunk loading */
/******/ 	(() => {
/******/ 		// no baseURI
/******/ 		
/******/ 		// object to store loaded and loading chunks
/******/ 		// undefined = chunk not loaded, null = chunk preloaded/prefetched
/******/ 		// [resolve, reject, Promise] = chunk loading, 0 = chunk loaded
/******/ 		var installedChunks = {
/******/ 			"jsbundle": 0
/******/ 		};
/******/ 		
/******/ 		// no chunk on demand loading
/******/ 		
/******/ 		// no prefetching
/******/ 		
/******/ 		// no preloaded
/******/ 		
/******/ 		// no HMR
/******/ 		
/******/ 		// no HMR manifest
/******/ 		
/******/ 		__webpack_require__.O.j = (chunkId) => (installedChunks[chunkId] === 0);
/******/ 		
/******/ 		// install a JSONP callback for chunk loading
/******/ 		var webpackJsonpCallback = (parentChunkLoadingFunction, data) => {
/******/ 			var [chunkIds, moreModules, runtime] = data;
/******/ 			// add "moreModules" to the modules object,
/******/ 			// then flag all "chunkIds" as loaded and fire callback
/******/ 			var moduleId, chunkId, i = 0;
/******/ 			if(chunkIds.some((id) => (installedChunks[id] !== 0))) {
/******/ 				for(moduleId in moreModules) {
/******/ 					if(__webpack_require__.o(moreModules, moduleId)) {
/******/ 						__webpack_require__.m[moduleId] = moreModules[moduleId];
/******/ 					}
/******/ 				}
/******/ 				if(runtime) var result = runtime(__webpack_require__);
/******/ 			}
/******/ 			if(parentChunkLoadingFunction) parentChunkLoadingFunction(data);
/******/ 			for(;i < chunkIds.length; i++) {
/******/ 				chunkId = chunkIds[i];
/******/ 				if(__webpack_require__.o(installedChunks, chunkId) && installedChunks[chunkId]) {
/******/ 					installedChunks[chunkId][0]();
/******/ 				}
/******/ 				installedChunks[chunkId] = 0;
/******/ 			}
/******/ 			return __webpack_require__.O(result);
/******/ 		}
/******/ 		
/******/ 		var chunkLoadingGlobal = self["webpackChunklucee_admin_language_editor"] = self["webpackChunklucee_admin_language_editor"] || [];
/******/ 		chunkLoadingGlobal.forEach(webpackJsonpCallback.bind(null, 0));
/******/ 		chunkLoadingGlobal.push = webpackJsonpCallback.bind(null, chunkLoadingGlobal.push.bind(chunkLoadingGlobal));
/******/ 	})();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module depends on other loaded chunks and execution need to be delayed
/******/ 	var __webpack_exports__ = __webpack_require__.O(undefined, ["vendors"], () => (__webpack_require__("./webroot/js/app.js")))
/******/ 	__webpack_exports__ = __webpack_require__.O(__webpack_exports__);
/******/ 	
/******/ })()
;
//# sourceMappingURL=jsbundle.js.map?hash=461911900767ebadd354