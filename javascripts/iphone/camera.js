/*
Camera.prototype.getPicture = function(successCallback, errorCallback, options) {
    var opts = {};
    if ("source" in options)
        opts.source = options.source;
    else
        opts.source = "camera";
    if ("destination" in options)
        opts.destination = options.destination;
    if ("jpegQuality" in options)
        opts.jpegQuality = options.jpegQuality;

    PhoneGap.exec(
        'Image.openImagePicker',
        PhoneGap.registerCallback(successCallback),
        PhoneGap.registerCallback(errorCallback),
        opts
    );
};
*/
// Gets the function name of a Function object, else uses "alert" if anonymous
function GetFunctionName(fn)
{
  if (fn) {
      var m = fn.toString().match(/^\s*function\s+([^\s\(]+)/);
      return m ? m[1] : "alert";
  } else {
    return null;
  }
}
/**
 * 
 * @param {Function} successCallback
 * @param {Function} errorCallback
 * @param {Object} options
 */
Camera.prototype.getPicture = function(successCallback, errorCallback, options) {
	PhoneGap.exec("Camera.getPicture", GetFunctionName(successCallback), GetFunctionName(errorCallback), options);
}
