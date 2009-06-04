function deviceInfo(){
  debug.log("deviceInfo");
  document.getElementById("platform").innerHTML   = device.platform;
  document.getElementById("version").innerHTML    = device.version;
  document.getElementById("devicename").innerHTML = device.name;
  document.getElementById("uuid").innerHTML       = device.uuid;
}

function getLocation() {
  debug.log("getLocation");
  navigator.notification.activityStart();
  var suc = function(p){
    debug.log(p.latitude + " " + p.longitude);
    navigator.notification.alert(p.latitude + " " + p.longitude, "Your GeoLocation", "Thanks");
    navigator.notification.activityStop();
  };
  var fail = function(){};
  navigator.geolocation.getCurrentPosition(suc,fail);
}

function customAlert(){
  navigator.notification.alert("Custom alert", "Custom title", "Yup!", "Nope", { onClose: function(index, label) { debug.log("alert's onClick callback called on button " + index + " (" + label + ")") } });
}

function beep(){
  debug.log("beep");
  navigator.notification.beep(2);
}

function vibrate(){
  debug.log("vibrate");
  navigator.notification.vibrate(0);
}

function getContactsPrompt(){
  debug.log("getContactsPrompt");
      
            var pageSize = prompt("Page size", 10);
            if (pageSize) {
                    var pageNumber = prompt("Page number", 1);
                    if (pageNumber) {
                            getContacts(parseInt(pageSize), parseInt(pageNumber));
                    }
            }
}

function getContacts(pageSize, pageNumber){
  debug.log("getContacts");
  var fail = function(){};
      var options = null;
      
      if (pageSize && pageNumber)
            options = { 'pageSize': pageSize, 'pageNumber': pageNumber };
      
  navigator.ContactManager.allContacts(getContacts_Return, fail, options);
}
    
    function getContacts_Return(contactsArray)
    {
            var names = "";
            
            for (var i = 0; i < contactsArray.length; i++) {
                    var con = new Contact();
                    con.firstName = contactsArray[i].firstName;
                    con.lastName = contactsArray[i].lastName;
                    con.phoneNumber = contactsArray[i].phoneNumber;
                    con.address = contactsArray[i].address;	
                    names += con.displayName();
                    
                    if (i+1 != contactsArray.length)
                            names += ",";
            }
            
            alert(names);
    }
    
    function contactsCount(){
  debug.log("contactCount");
  navigator.ContactManager.contactsCount(showContactsCount);
}
    
    function showContactsCount(count){
            alert("Number of contacts: " + count);
    }

    function addContact(gui){
            var sample_contact = { 'firstName': 'John', 'lastName' : 'Smith' };
    
            if (gui) {
                    navigator.ContactManager.newContact(sample_contact, null, { 'gui': true });
            } else {
                    var firstName = prompt("Enter a first name", sample_contact.firstName);
                    if (firstName) {
                            var lastName = prompt("Enter a last name", sample_contact.lastName);
                            if (lastName) {
                                    sample_contact = { 'firstName': firstName, 'lastName' : lastName };
                                    navigator.ContactManager.newContact(sample_contact);
                            }
                    }
            }
    }

function watchAccel() {
  debug.log("watchAccel");
  var suc = function(a){
    document.getElementById('x').innerHTML = roundNumber(a.x);
    document.getElementById('y').innerHTML = roundNumber(a.y);
    document.getElementById('z').innerHTML = roundNumber(a.z);
  };
  var fail = function(){};
  var opt = {};
  opt.frequency = 100;
  timer = navigator.accelerometer.watchAcceleration(suc,fail,opt);
}
  
function roundNumber(num) {
  var dec = 3;
  var result = Math.round(num*Math.pow(10,dec))/Math.pow(10,dec);
  return result;
}

function setupToolbars() {
   tabbar.createTabBar();

   var toprated = 0;
   tabbar.createTabBarItem("toprated", "Top Rated", "tabButton:TopRated", {
       onSelect: function() {
           navigator.notification.alert("Top Rated selected");
           tabbar.updateTabBarItem("toprated", { badge: ++toprated });
       }
   });

   var recents = 0;
   tabbar.createTabBarItem("recents", "Recents", null, {
       onSelect: function() {
           navigator.notification.alert("Recents selected");
           tabbar.updateTabBarItem("recents", { badge: ++recents });
       }
   });

   var history = 0;
   tabbar.createTabBarItem("history", "History", "icon.png", {
       onSelect: function() {
           navigator.notification.alert("History selected");
           tabbar.updateTabBarItem("history", { badge: ++history });
       }
   });

   tabbar.createTabBarItem("search", "Search", "tabButton:Search");
   tabbar.createTabBarItem("downloads", "Downloads", "tabButton:Downloads");

   tabbar.showTabBar();
   tabbar.showTabBarItems("toprated", "recents", "history");
}

function preventBehavior(e) { 
  e.preventDefault(); 
};

PhoneGap.addConstructor(function(){
  document.addEventListener("touchmove", preventBehavior, false);
  setupToolbars();
  navigationbar.setNavBar('My Title', 'Go Right', {
    onButton: function() {
      navigationbar.setNavBar('Another title', 'toolButton:Trash', {
        onShowStart: function() {
          debug.log("New navbar item starting to show");
        },
        onShow: function() {
          debug.log("New navbar item shown");
        },
        onHideStart: function() {
          debug.log("New navbar item starting to go away");
        },
        onHide: function() {
          debug.log("New navbar item has gone away");
        }
      });
    }
  });

  deviceInfo();
  document.addEventListener('startOrientationChange', function(e) { debug.log("Orientation changing to " + e.orientation); }, false);
  document.addEventListener('stopOrientationChange', function(e) { debug.log("Orientation changed from " + e.orientation); }, false);
  document.addEventListener('alertClosed', function(e) { debug.log("Alert box closed when user clicked button " + e.buttonIndex + " having title " + e.buttonLabel); }, false);
  /*
  dialog.openButtonDialog(
      'This is my title',
      'Foo',
      { label: 'Bar' },
      { label: 'Baz', type: 'destroy', onClick: function() { debug.log("Destroy called") }},
      { style: 'translucent' }
  );
  navigator.file.listDirectoryContents("www", {
    onComplete: function(result) {
        /* Do something with the files */
    }
  });
  navigator.camera.getPicture(
      function(url) {
            debug.log("Saved picture: " + url);
      },
      function(status) {
            debug.log("Error saving picture: " + status);
      },
      {
            source: 'library',
            destination: 'file:///image.jpg',
            jpegQuality: 1.0
      }
  );
  */
});
