UIControls.prototype.createTabBar = function() {
    PhoneGap.exec("UIControls.createTabBar");
};

UIControls.prototype.showTabBar = function(options) {
    if (!options) options = {};
    PhoneGap.exec("UIControls.showTabBar", options);
};

UIControls.prototype.hideTabBar = function(animate) {
    if (animate == undefined || animate == null)
        animate = true;
    PhoneGap.exec("UIControls.hideTabBar", { animate: animate });
};

UIControls.prototype.createTabBarItem = function(name, label, image, options) {
    var tag = this.tabBarTag++;
    if (options && 'onSelect' in options && typeof(options['onSelect']) == 'function') {
        this.tabBarCallbacks[tag] = options.onSelect;
        delete options.onSelect;
    }
    PhoneGap.exec("UIControls.createTabBarItem", name, label, image, tag, options);
};

UIControls.prototype.updateTabBarItem = function(name, options) {
    if (!options) options = {};
    PhoneGap.exec("UIControls.updateTabBarItem", name, options);
};

UIControls.prototype.showTabBarItems = function() {
    var parameters = [ "UIControls.showTabBarItems" ];
    for (var i = 0; i < arguments.length; i++) {
        parameters.push(arguments[i]);
    }
    PhoneGap.exec.apply(this, parameters);
};

UIControls.prototype.selectTabBarItem = function(tab) {
    PhoneGap.exec("UIControls.selectTabBarItem", tab);
};

UIControls.prototype.createNavBar = function() {
    PhoneGap.exec("UIControls.createNavBar");
};

UIControls.prototype.setNavBar = function(title, rightButton, options) {
    var nav_opts = {};
    if (typeof(options) != 'object')
        options = {};
    if ('animate' in options)
        nav_opts.animate = options.animate;
    if ('onShow' in options)
        nav_opts.onShow = PhoneGap.registerCallback(options.onShow);
    if ('onHide' in options)
        nav_opts.onHide = PhoneGap.registerCallback(options.onHide);
    if ('onButton' in options)
        nav_opts.onButton = PhoneGap.registerCallback(options.onButton);

    PhoneGap.exec("UIControls.setNavBar", title, rightButton, nav_opts);
};
