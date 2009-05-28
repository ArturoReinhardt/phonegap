TabBar.prototype.createTabBar = function() {
    PhoneGap.exec("TabBar.createTabBar");
};

TabBar.prototype.showTabBar = function(options) {
    if (!options) options = {};
    PhoneGap.exec("TabBar.showTabBar", options);
};

TabBar.prototype.hideTabBar = function(animate) {
    if (animate == undefined || animate == null)
        animate = true;
    PhoneGap.exec("TabBar.hideTabBar", { animate: animate });
};

TabBar.prototype.createTabBarItem = function(name, label, image, options) {
    var tag = this.tabBarTag++;
    if (options && 'onSelect' in options && typeof(options['onSelect']) == 'function') {
        this.tabBarCallbacks[tag] = options.onSelect;
        delete options.onSelect;
    }
    PhoneGap.exec("TabBar.createTabBarItem", name, label, image, tag, options);
};

TabBar.prototype.updateTabBarItem = function(name, options) {
    if (!options) options = {};
    PhoneGap.exec("TabBar.updateTabBarItem", name, options);
};

TabBar.prototype.showTabBarItems = function() {
    var parameters = [ "TabBar.showTabBarItems" ];
    for (var i = 0; i < arguments.length; i++) {
        parameters.push(arguments[i]);
    }
    PhoneGap.exec.apply(this, parameters);
};

TabBar.prototype.selectTabBarItem = function(tab) {
    PhoneGap.exec("TabBar.selectTabBarItem", tab);
};
