Corona-Dropbox3
===============

Dropbox REST API sample code for Corona SDK

Hey Folks,
This is sample code that will allow you to download text files to your app in Corona or upload text files from your app. Since this code is based on the REST API, it's possible it could be use for other web services besides Dropbox- however, it will only work with other web services that allow the use of PLAINTEXT.

This sample code is based on the advice provided here:
https://www.dropbox.com/developers/blog/20

This code will allow you to get request token, authorize via webPopup, get and store access token and get or put text files. You need to register with Dropbox as a developer, create an app and add your consumer key and consumer secret to the dropbox.lua file. The PUT feature does require Network 2.0, so you'll need a fairly recent daily build. So, make sure you are using at least: CoronaSDK 2013.1072

To use the file as is, you need to rename it to main.lua and then update a few of the variables at the top including consumer key, consumer secret and myFile. I may turn the file into a module, but if you would like to do it and post it here in the code exchange, that would be great too!

If you're developing for Android on Windows, you will need to run the app from a device (webpopups don't work in Windows simulator). Also, you will need to have the device attached by USB and use the terminal to monitor results. You can use the following command to see what Corona is up to on the device:
adb logcat Corona:V *:S

Let me know if you have questions.

For those of you that have been waiting for Corona SDK Dropbox capability, 
I can save you dozens of hours of time.

Please consider making a donation if you find that this to be useful:
<a href='http://www.pledgie.com/campaigns/18967'><img alt='Click here to lend your support to: Corona SDK Dropbox Sample Code and make a donation at www.pledgie.com !' src='http://www.pledgie.com/campaigns/18967.png?skin_name=chrome' border='0' /></a>
