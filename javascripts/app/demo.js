function Demo() {
    var dis = this;

    /*
    toolbar.addItem("Add", { label: "toolButton:Add", type: "button" });
    toolbar.addItem("spacer", { type: "space", flexible: true });
    toolbar.addItem("Remove", { label: "Remove", type: "button" });
    toolbar.setItems("Add", "spacer", "Remove");
    toolbar.show(true);
    */

    tabbar.createTabBar();

    tabbar.createTabBarItem("main", "Main", null, {
        onSelect: function() { dis.selectMainTab(); }
    });

    tabbar.createTabBarItem("contacts", "Contacts", null, {
        onSelect: function() { dis.selectContactsTab(); }
    });

    tabbar.createTabBarItem("accelerometer", "Accelerometer", null, {
        onSelect: function() { dis.selectAccelTab(); }
    });

    tabbar.createTabBarItem("geolocation", "Geolocation", null, {
        onSelect: function() { dis.selectLocationTab(); }
    });

    tabbar.showTabBar();
    tabbar.showTabBarItems("main", "accelerometer", "contacts", "geolocation");
    tabbar.selectTabBarItem("main");

    navigationbar.setNavBar("PhoneGap Demo", 'toolButton:Camera', {
        onButton: function() {
            var source = 'camera';
            if (navigator.device.platform.match(/Simulator/))
                source = 'library'; // the simulator's camera doesn't work

            navigator.camera.getPicture(
                function() {
                    var cameraPanel = document.getElementById('CameraPanel');
                    cameraPanel.innerHTML = '<img src="../phonegap_photo.png" width="300" align="center"/>';
                    app.openPanel(cameraPanel);
                    tabbar.selectTabBarItem(null);
                },
                function(msg) {
                    navigator.notification.alert('Error taking picture\n' + msg, 'Camera');
                },
                { source: source, destination: 'file:///phonegap_photo.png' }
            );
        }
    });

    try {
        this.populateDeviceInfo();
    } catch(e) {
        debug.error(e);
    }
}

Demo.prototype = {
    selectMainTab: function() {
        this.openPanel(document.getElementById('MainPanel'));
    },
    selectContactsTab: function() {
        this.openPanel(document.getElementById('ContactsPanel'));
    },
    selectAccelTab: function() {
        this.openPanel(document.getElementById('AccelPanel'));
    },
    selectLocationTab: function() {
        this.openPanel(document.getElementById('LocationPanel'));
    },

    populateDeviceInfo: function() {
      debug.log("deviceInfo");
      document.getElementById("platform").innerHTML   = device.platform;
      document.getElementById("version").innerHTML    = device.version;
      document.getElementById("devicename").innerHTML = device.name;
      document.getElementById("uuid").innerHTML       = device.uuid;
    },

    addContact: function(gui) {
        var sample_contact = { 'firstName': 'John', 'lastName' : 'Smith', 'phoneNumber': '555-5555' };

        if (gui) {
            navigator.ContactManager.newContact(sample_contact, null, { 'gui': true });
        } else {
            var firstName = prompt("Enter a first name", sample_contact.firstName);
            if (firstName) {
                var lastName = prompt("Enter a last name", sample_contact.lastName);
                if (lastName) {
                    var phoneNumber = prompt("Enter a phone number", sample_contact.phoneNumber);
                    if (phoneNumber) {
                        sample_contact = { 'firstName': firstName, 'lastName' : lastName, 'phoneNumber' : phoneNumber };
                        navigator.ContactManager.newContact(sample_contact, chooseContact_Return);
                    }
                }
            }
        }
    },

    getLocation: function() {
        debug.log("getLocation");
        navigator.geolocation.watchPosition(function(p) {
              document.getElementById("geo_lat").innerHTML = p.coords.latitude;
              document.getElementById("geo_long").innerHTML = p.coords.longitude;
              document.getElementById("geo_alt").innerHTML = p.coords.alt;
              document.getElementById("geo_course").innerHTML = p.coords.heading;
              document.getElementById("geo_speed").innerHTML = p.coords.speed;
              document.getElementById("geo_x_acc").innerHTML = p.coords.accuracy.horizontal;
              document.getElementById("geo_y_acc").innerHTML = p.coords.accuracy.vertical;
        }, false);

        navigator.notification.activityStart();
        var suc = function(p){
            debug.log(p);
            navigator.notification.alert(p.coords.latitude + " " + p.coords.longitude, "Your GeoLocation", "Thanks");
            navigator.notification.activityStop();
        };
        var fail = function(error){
	};
        navigator.geolocation.getCurrentPosition(suc,fail);
    },

    customAlert: function() {
      navigator.notification.alert("Custom alert", "Custom title", "Yup!", "Nope", { onClose: function(index, label) { debug.log("alert's onClick callback called on button " + index + " (" + label + ")") } });
    },
  
    beep: function() {
      debug.log("beep");
      navigator.notification.beep(2);
    },
  
    vibrate: function() {
      debug.log("vibrate");
      navigator.notification.vibrate(0);
    },

    openPanel: function(targetPanel) {
        var container = document.querySelector('body > ul.PanelContainer');
        if (!container || !targetPanel) return;

        if (!container.panelListenerAdded) {
            // add an event listener to clean up the other panels after the animation
            container.addEventListener('webkitTransitionEnd', (function(){ 
                return function() {
                    var panels = document.querySelectorAll('body > ul.PanelContainer > li');
                    for (var i = 0; i < panels.length; i++) {
                        var panel = panels[i];
                        // only hide the inactive panels
                        if (panel.className.match(/active/))
                            continue;
                        panel.className = 'hidden';
                    }
                };
            })(), false);
            container.panelListenerAdded = true;
        }

        var currentPanel = document.querySelector('body > ul.PanelContainer > li.active');
        if (targetPanel === currentPanel)
            return;

        container.className       = 'PanelContainer'; // disable animation
        currentPanel.className    = '';  // deactivate current panel
        currentPanel.style.zIndex = 0;
        setTimeout(function() {
            container.className = 'PanelContainer animated'; // reenable animation
            targetPanel.style.zIndex = 1;      // slide new panel into view
            targetPanel.className = 'active';
        }, 0);
    },

};

function preventBehavior(e) { 
    e.preventDefault(); 
};

PhoneGap.addConstructor(function(){
  document.addEventListener("touchmove", preventBehavior, false);
  window.app = new Demo();
});
