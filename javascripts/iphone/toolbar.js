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

Toolbar.prototype.setItems = function(items, options) {
    this.visibleItems = items;
    var args = [ "Toolbar.setItems" ];
    for (var i = 0; i < items.length; i++) {
        args.push( items[i] ) ;
    }
    args.push(options);
    PhoneGap.exec.apply(null, args);
};
