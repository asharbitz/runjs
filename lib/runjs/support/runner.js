(function(program) {

  'use strict';

  var isArray = Array.isArray || function(obj) {
    return Object.prototype.toString.call(obj) === '[object Array]';
  };

  function run(program) {
    try {
      return [program(), true];
    } catch (error) {
      return [copyError(error), false];
    }
  }

  function copyError(error) {
    var copy;
    if (error && typeof error === 'object' && ! isArray(error)) {
      copy = {};
      for (var key in error) {
        if (error.hasOwnProperty(key)) {
          copy[key] = stringifyProof(error[key]);
        }
      }
      copy.name    = stringifyProof(error.name);
      copy.message = stringifyProof(error.message);
      copy.stack   = stringifyProof(shortenStack(error.stack));
    } else {
      copy = stringifyProof(error);
    }
    return copy;
  }

  function stringifyProof(value) {
    try {
      JSON.stringify(value);
      return value;
    } catch (error) {
      return '' + value;
    }
  }

  function shortenStack(stack) {
    // SpiderMonkey includes the whole program in the stack trace
    if (typeof stack === 'string' && stack.length > 2000) {
      stack = stack.slice(0, 500) + ' ... ' + stack.slice(-500);
    }
    return stack;
  }

  function stringify(result) {
    try {
      return JSON.stringify(result);
    } catch (error) {
      result = [copyError(error), false];
      return JSON.stringify(result);
    }
  }

  function write(result) {
    if (typeof print === 'function') {
      print(result);
    } else if (typeof console === 'object') {
      console.log(result);
    } else if (typeof WScript === 'object') {
      // WScript.Echo does not handle unicode on Windows 8
      WScript.StdOut.Write(result);
    } else {
      return result;
    }
  }

  return write(stringify(run(program)));

})(function() {  // The program argument
%s
});
