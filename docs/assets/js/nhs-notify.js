// Quick poc for view full screen

window.addEventListener("load", () => {
  const fullScreenParamName = "fullscreen";
  const urlParams = new URLSearchParams(document.location.search);
  const param = urlParams.get(fullScreenParamName);
  if (param) {
    tempViewFullScreen();
  } else {
    setViewAtStart();
  }
});

const nhsNotify = nhsNotifyDefaults();

function nhsNotifyDefaults() {
  const defaults = {};
  defaults.storageName = "cb-checked";
  defaults.buttonName = "fullScreenButton";
  defaults.standard = "Standard";
  defaults.fullScreen = "Full Screen";
  return defaults;
}

function tempViewFullScreen() {
  viewFullScreen();
  const buttons = document.getElementsByName(nhsNotify.buttonName);
  buttons.forEach((item) => {
    item.style.display = "none";
  });
}

function viewFullScreen() {
  const sideBar = document.getElementsByClassName("side-bar")[0];
  const main = document.getElementsByClassName("main")[0];
  const pageInfo = document.getElementsByClassName("page-info")[0];
  sideBar.style.display = "none";
  main.style.maxWidth = "100%";
  main.style.marginLeft = "0px";
  if (pageInfo) pageInfo.style.display = "none";
}
function setFullScreen() {
  viewFullScreen();
  afterChange(nhsNotify.standard, nhsNotify.fullScreen);
}

function setStandard() {
  const sideBar = document.getElementsByClassName("side-bar")[0];
  const main = document.getElementsByClassName("main")[0];
  const pageInfo = document.getElementsByClassName("page-info")[0];
  sideBar.style.display = "";
  main.style.maxWidth = "";
  main.style.marginLeft = "";
  if (pageInfo) pageInfo.style.display = "";
  afterChange(nhsNotify.fullScreen, nhsNotify.standard);
}

function setViewAtStart() {
  const currentStatus = localStorage.getItem(nhsNotify.storageName);
  if (currentStatus == nhsNotify.fullScreen) makeChange(currentStatus);
}

function makeChange(newStatus) {
  if (newStatus == nhsNotify.fullScreen) {
    setFullScreen();
  } else {
    setStandard();
  }
}

function afterChange(currentStatus, newStatus) {
  const buttons = document.getElementsByName(nhsNotify.buttonName);
  localStorage.setItem(nhsNotify.storageName, newStatus);

  buttons.forEach((item) => {
    item.textContent = currentStatus + " View";
  });
}

function fullScreenToggle() {
  const { standard, fullScreen, storageName } = nhsNotify;
  let currentStatus = localStorage.getItem(storageName);

  if (
    currentStatus == "false" ||
    currentStatus == "undefined" ||
    currentStatus == null
  ) {
    currentStatus = standard;
  }

  const newStatus = currentStatus == standard ? fullScreen : standard;

  makeChange(newStatus);
}
