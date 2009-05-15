PhoneGap.addConstructor(function(){
  document.addEventListener("touchmove", preventBehavior, false);
  setupToolbars();
  deviceInfo();
});

function deviceInfo(){
  debug.log("deviceInfo");
  document.getElementById("platform").innerHTML = device.model;
  document.getElementById("version").innerHTML = device.version;
  document.getElementById("uuid").innerHTML = device.uuid;
}

function getLocation() {
  debug.log("getLocation");
  navigator.notification.activityStart();
  var suc = function(p){
    debug.log(p.latitude + " " + p.longitude);
    navigator.notification.activityStop();
  };
  var fail = function(){};
  navigator.geolocation.getCurrentPosition(suc,fail);
}

function customAlert(){
  navigator.notification.alert("Custom alert", "Custom title", "Yup!");
}

function beep(){
  debug.log("beep");
  navigator.notification.beep(2);
}

function vibrate(){
  debug.log("vibrate");
  navigator.notification.vibrate(0);
}

function getContact(){
  debug.log("getContact");
  var suc = function(c){
    debug.log(c);
    alert("Contact 4: " + c.contacts[3].name);
  };
  var fail = function(){};
  navigator.ContactManager.get(suc, fail);
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
   uicontrols.createTabBar();

   var toprated = 0;
   uicontrols.createTabBarItem("toprated", "Top Rated", "tabButton:TopRated", {
       onSelect: function() {
           navigator.notification.alert("Top Rated selected");
           uicontrols.updateTabBarItem("toprated", { badge: ++toprated });
       }
   });

   var recents = 0;
   uicontrols.createTabBarItem("recents", "Recents", null, {
       onSelect: function() {
           navigator.notification.alert("Recents selected");
           uicontrols.updateTabBarItem("recents", { badge: ++recents });
       }
   });

   var history = 0;
   uicontrols.createTabBarItem("history", "History", "icon.png", {
       onSelect: function() {
           navigator.notification.alert("History selected");
           uicontrols.updateTabBarItem("history", { badge: ++history });
       }
   });

   var more = false;
   uicontrols.createTabBarItem("more", "More", "tabButton:More", {
       onSelect: function() {
           if (more) {
               uicontrols.showTabBarItems("search", "downloads", "more");
           } else {
               uicontrols.showTabBarItems("toprated", "recents", "history", "more");
           }
           uicontrols.selectTabBarItem(null);
           more = !more;
       }
   });

   try {
   uicontrols.createTabBarItem("search", "Search", "tabButton:Search");
   uicontrols.createTabBarItem("downloads", "Downloads", "tabButton:Downloads");
   } catch(e) { debug.log(e) }

   uicontrols.showTabBar();
   uicontrols.showTabBarItems("toprated", "recents", "history", "more");

   uicontrols.setToolBarTitle("PhoneGap Demo");
}

function preventBehavior(e) { 
  e.preventDefault(); 
};
