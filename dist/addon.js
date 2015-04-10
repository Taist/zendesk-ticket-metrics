function init(){var require=(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
module.exports = 'Hello world (test mixed sources in the project)'

},{}],2:[function(require,module,exports){
module.exports = function(api) {
  return api.log('Hello world! ' + require('./greetingsText'));
};

},{"./greetingsText":1}],"addon":[function(require,module,exports){
var addonEntry;

addonEntry = {
  start: function(_taistApi, entryPoint) {
    _taistApi.log('Addon started');
    require('./greetings/hello')(_taistApi);
    _taistApi.companyData.set('key', 'value ' + new Date, function() {
      return console.log('company data saved');
    });
    return _taistApi.companyData.get('key', function(a, b) {
      return console.log('received from the server', a, b);
    });
  }
};

module.exports = addonEntry;

},{"./greetings/hello":2}]},{},[]);
;return require("addon")}
//Just a sample of concat task
