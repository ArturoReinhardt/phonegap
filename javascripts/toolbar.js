function Toolbar() {
    this.items = {};
}

Toolbar.prototype.show = function(isAnimated) {};
Toolbar.prototype.hide = function(isAnimated) {};

Toolbar.prototype.addItem = function(id, options) {
    try {
    if (!id || this.items[id] != undefined) {
        debug.error("Toolbar.addItem " + id + " already added");
        return;
    }

    if (typeof(options) != 'object') {
        debug.error("Toolbar.addItem options are not valid");
        return;
    }

    if (options.type != 'button' && options.type != 'label' && options.type != 'space')
        options.type = 'button';

    if (options.onClick)
        options.onClick = PhoneGap.registerCallback(options.onClick);

    this.items[id] = options;
    this._addItem(id);
    } catch(e) { debug.error(e) }
};
Toolbar.prototype.updateItem = function(id, options) {
    if (!id || !this.items[id])
        return;
    var item = this.items[id];
    for (var i in options) {
        item[i] = options[i];
    }
    this._updateItem(id);
};
Toolbar.prototype.removeItem = function(id) {
    if (!id || !this.items[id])
        return;
    delete this.items[id];
};
Toolbar.prototype.setItems = function() {};

Toolbar.prototype._addItem = function(id) {};
Toolbar.prototype._updateItem = function(id) {};
Toolbar.prototype._removeItem = function(id) {};

PhoneGap.addConstructor(function() {
    window.toolbar = new Toolbar();
});
