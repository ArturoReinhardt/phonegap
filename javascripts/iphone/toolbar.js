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
    var args = [];
    if (arguments.length == 1 && typeof arguments[0] == 'object')
        args = arguments[0];
    else
        args = arguments;

    this.visibleItems = args;
    args.unshift("Toolbar.setItems");
    PhoneGap.exec.apply(null, args);
};
