/**
 * This class provides access to the device camera.
 * @constructor
 */
function Camera() {
	
}

/**
 * Gets a picture from the device's camera
 * @param {Function} successCallback
 * @param {Function} errorCallback
 * @param {Object} options
 */
Camera.prototype.getPicture = function(successCallback, errorCallback, options) {
	
}

PhoneGap.addConstructor(function() {
    if (typeof navigator.camera == "undefined") navigator.camera = new Camera();
});
