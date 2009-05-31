File.prototype.listDirectoryContents = function(path, options) {
    if (typeof(options.onComplete) == 'function') {
        var callback = options.onComplete;
        options.onComplete = PhoneGap.registerCallback(function(result) {
            for (var i in result) {
                result[i].modified = new Date(result[i].modified);
                result[i].created = new Date(result[i].created);
                result[i].isDirectory = result[i].isDirectory == 'true';
            }
            callback(result);
        });
    }
    PhoneGap.exec("File.listDirectoryContents", path, options);
};
