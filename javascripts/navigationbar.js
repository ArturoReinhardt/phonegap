/**
 * This class exposes the current mobile phone's native implementation of
 * a navigation bar, or tab bar, control.  Instead of re-implementing
 * controls in HTML/CSS to look like the native controls, this class
 * exposes the actual controls to JavaScript.
 * @constructor
 */
function NavigationBar() {
}

/**
 * Create a navigation bar.
 */
NavigationBar.prototype.createNavBar = function() {};

/**
 * Sets a new navigationbar in the stack of options.  Automatically transitions to the new navbar, and
 * provides a "back" button to go back to the previous navbar setting.
 * @param {String} title the title to set within the navbar
 * @param {String} rightButton the label to use on the right button; if null, no button is shown
 * @param {Object} options one or more options
 *  - \c animate causes the new navbar to animate into view; (default: \c true)
 *  - \c onButton function callback that fires when the optional button is pressed
 *  - \c onShow function callback that fires when this navbar is in view
 *  - \c onHide function callback that fires when this navbar is no longer shown, either when a new navbar is added, or when a previous navbar is re-selected
 *  - \c onStartShow function callback that fires when this navbar starts to be shown
 *  - \c onStartHide function callback that fires when this navbar starts to hide
 */
NavigationBar.prototype.setToolBarTitle = function(title, rightButton, options) {};

PhoneGap.addConstructor(function() {
    window.navigationbar = new NavigationBar();
});
