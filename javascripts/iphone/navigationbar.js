NavigationBar.prototype.createNavBar = function() {
    PhoneGap.exec("NavigationBar.createNavBar");
};

NavigationBar.prototype.setNavBar = function(title, rightButton, options) {
    var nav_opts = {};
    if (typeof(options) != 'object')
        options = {};
    if ('animate' in options)
        nav_opts.animate = options.animate;
    var function_callbacks = ['onButton', 'onShow', 'onShowStart', 'onHide', 'onHideStart'];
    for (var i = 0; i < function_callbacks.length; i++) {
        var eventName = function_callbacks[i];
        if (eventName in options)
            nav_opts[eventName] = PhoneGap.registerCallback(options[eventName]);
    }

    PhoneGap.exec("NavigationBar.setNavBar", title, rightButton, nav_opts);
};
