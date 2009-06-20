/**
 * This class expses a variety of modal dialogs that can be presented to the user for them 
 * to make a choice or selection.
 * @constructor
 */
function Dialog() {
}

/**
 * Create a modal dialog presenting the user with a series of buttons, asking them to make a choice.
 *
 * The list of buttons can contain either a plain string, an object representing more information about the
 * button, or a mix of both.  If an object is used, then the following properties are expected:
 *   - \c label The label of the button
 *   - \c [type] The type of button, one of "default", "cancel", or "destroy". Only one each of "cancel" and
 *   "destroy" can be specified.
 *   - \c onClick A function to be called when this button is clicked.
 *
 * Additionally, the \c onClick property on the options parameter can be specified to have a function called when
 * any button is clicked.  In all \c onClick functions on this method though, the following parameters are passed
 * to the function:
 *   - \c index The index, or number, of the button, starting at 1
 *   - \c label The text label of the button
 *   - \c type  The type of button specified
 *
 * @param {String} title title or description of the button dialog
 * @param {String|Object} buttons... the list of buttons to add to the dialog, starting from bottom to top.
 * @param {Object} [options] options to pass to the dialog:
 *   - \c onClick function to call when any button is clicked
 *   - \c style   indicates the style of the dialog; one of (automatic | default | translucent | opaque)
 *   - \c showFrom controls where the dialog opens from; one of (default | tabbar | navigationbar)
 */
Dialog.prototype.openButtonDialog = function(title) {};

PhoneGap.addConstructor(function() {
    window.dialog = new Dialog();
});
