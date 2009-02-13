function addEvent(obj, evType, fn, useCapture){
  if (obj.addEventListener){
    obj.addEventListener(evType, fn, useCapture);
    return true;
  } else if (obj.attachEvent){
    var r = obj.attachEvent("on"+evType, fn);
    return r;
  } else {
    alert("Handler could not be attached");
  }
}

var DEF_VAL   = "Search"; // Default Value
var isSafari  = ((parseInt(navigator.productSub)>=20020000)&&     // detecting WebCore
               (navigator.vendor.indexOf("Apple Computer")!=-1));

function replaceSearchField() {
  // Replaces normal input text field with safari's neat search field
  if (!document.getElementById) return;
  var searchForm  = document.getElementById('xearch');
  var searchField = document.getElementById('xearchInput');
  if (!searchField) return;
  if (isSafari) {
    searchForm.className = 'issafari';
    searchField.setAttribute('type', 'search');
    searchField.setAttribute('autosave', 'at.xircles.codehaus.org.search');
    searchField.setAttribute('results', '5');
    searchField.setAttribute('placeholder', DEF_VAL);
  } else {
    addEvent(searchField, 'focus', focusSearch, false);
    addEvent(searchField, 'blur',  blurSearch, false);
    if (searchField.value=='') searchField.value = DEF_VAL;
  }
  
}

function focusSearch() {
  // removes the initial value from the search field
  if (this.value==DEF_VAL) {
    this.value = '';
    this.setAttribute('class', 'focus');
  }
}

function blurSearch() {
  // assigns default value, if no value has been entered
  if (this.value=='') {
    this.value = DEF_VAL;
    this.removeAttribute('class', 'focus');
  }
}

addEvent(window, 'load', replaceSearchField, false);