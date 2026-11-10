# Setting up the 2026 app

To set up the app in the folder ``` scoutapps/2026 ``` onto your scouting tablet, follow the instructions below.

## Materials

* USB Thumbdrive
* USB Type-A to Type-C Converter
* Scouting Tablet(s)
* Personal Wi-Fi Network (Optional but preferable for those using school Wi-Fi)
* Internet access or Google Play Store on the **tablet**

## Setup

On your scouting tablet, install File Manager through Google Play Store, either through the app or through [this link](https://play.google.com/store/apps/details?id=com.alphainventor.filemanager&hl=en_US). It should be this one:
![filemanagerplus](../assets/filemanagerplus.png)

Also through Google Play Store, install the Simple HTTP Server app through the Play Store app or through [this link](https://play.google.com/store/apps/details?id=com.phlox.simpleserver&hl=en_US). It should be this one:
![simplehttp](../assets/simplehttp.png)

On your computer, copy over the folder ` scoutapps\2026\ScoutApp.Browser\bin\Release\net8.0-browser\publish\wwwroot ` to the USB thumbdrive that you obtained earlier. You can recognize that it is the right folder if you see that it contains ` index.html `:
![wwwroot](../assets/wwwroot.png)

If needed, use the USB type-a to type-c converter to connect the thumbdrive to the tablet. It should give you a popup saying:

<img src="../assets/USBConverterPopup.jpeg" width="40%">

Select "OK", then go back into File Manager +, go to the thumbdrive, and you should get a popup like this:

<img src="../assets/permission.jpeg" width="40%">

Select "OK", then on the next screen, Select the wwwroot folder, and then Select "USE THIS FOLDER":

<img src="../assets/usethisfolder1.jpeg" width="40%"> <img src="../assets/usethisfolder2.jpeg" width="40%">

Select "ALLOW", then as it moves back over to File Manager +, Select and hold the wwwroot folder, copy it, and Select "Paste" in the bottom right of the screen.

<img src="../assets/allowfileaccess.jpeg" width="40%"> <img src="../assets/selectwwwrootfolder.jpeg" width="40%"> <img src="../assets/selectdownload.jpeg" width="40%"> <img src="../assets/paste.jpeg" width="40%">

Open the Simple HTTP Server, and in the top left, Select the dropdown, Select "Downloads", Select the wwwroot folder, and then Select the "SELECT THIS FOLDER" button at the bottom of the screen.

<img src="../assets/simplehttp1.jpeg" width="40%"> <img src="../assets/simplehttp2.jpeg" width="40%"> <img src="../assets/simplehttp3.jpeg" width="40%"> <img src="../assets/simplehttp4.jpeg" width="40%">

Double check that the "Root folder" says /scorage/emulated/0/Download/wwwroot, then Select the "START" button in the center of the screen, then Select on the URL and Select the "Navigate" button to open it in the browser.

<img src="../assets/simplehttp5.jpeg" width="40%"> <img src="../assets/simplehttp6.jpeg" width="40%"> <img src="../assets/simplehttp7.jpeg" width="40%">

If you have followed these instructions correctly then the app should work successfully in the browser! Enjoy scouting for FRC 2026 Rebuilt, presented by Haas!

<img src="../assets/appinbrowser.jpeg" width="40%">
