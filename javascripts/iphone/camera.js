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
