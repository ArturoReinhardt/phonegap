Dialog.prototype.openButtonDialog = function(title) {
    var buttons = [];
    var options = {};
    for (var i = 1; i < arguments.length; i++) {
        var arg = arguments[i];
        if (typeof(arg) == 'string') {
            buttons.push(arg);
        } else if ("label" in arg) {
            buttons.push(arg.label);
            if ("onClick" in arg && typeof(arg.onClick) == 'function')
                options["onclick_" + i] = PhoneGap.registerCallback(arg.onClick);
            if ("type" in arg)
                options["type_" + i] = arg.type;
        } else if (i == arguments.length - 1) {
            if ("onClick" in arg && typeof(arg.onClick) == 'function')
                options.onclick = PhoneGap.registerCallback(arg.onClick);
            if ("style" in arg)
                options.style = arg.style;
            if ("showFrom" in arg)
                options.showFrom = arg.showFrom;
        }
    }

    var dialog_args = [ 'Dialog.openButtonDialog', title ];
    for (var i = 0; i < buttons.length; i++)
        dialog_args.push(buttons[i]);
    dialog_args.push(options);
    PhoneGap.exec.apply(null, dialog_args);
};
