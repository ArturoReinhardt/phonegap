Toolbar.prototype._show = function(isAnimated) {
    PhoneGap.exec("Toolbar.show", { animated: isAnimated });
};
Toolbar.prototype._hide = function(isAnimated) {
    PhoneGap.exec("Toolbar.hide", { animated: isAnimated });
};

Toolbar.prototype._addItem = function(id) {
    PhoneGap.exec("Toolbar.addItem", id, this.items[id]);
};
Toolbar.prototype._updateItem = function(id) {
    PhoneGap.exec("Toolbar.updateItem", id, this.items[id]);
};
Toolbar.prototype._removeItem = function(id) {
    PhoneGap.exec("Toolbar.removeItem", id, this.items[id]);
};

Toolbar.prototype.setItems = function() {
    var args = [ "Toolbar.setItems" ];
    var c = arguments.length;
    this.visibleItems = [];
    for (var i = 0; i < c; i++) {
        if (typeof(arguments[i]) == 'string')
            this.visibleItems.push(arguments[i]);
        args.push(arguments[i]);
    }
    PhoneGap.exec.apply(null, args);
};
