Onkyo Remote App for MacOSX menu bar.

![shot-onky](https://user-images.githubusercontent.com/36587077/36996223-8409cb9a-20b6-11e8-846d-71fe6d41314a.jpg)

This App is able to redirect MacOSX sounds to your Onkyo receiver using "icecast" & "darkice" deamons.

You need to install a dedicated audio driver to capture Mac sounds such as the one from AirBeamTV http://bit.ly/2lTqyDQ.
![shot-audiodriverinstall](https://user-images.githubusercontent.com/36587077/36996539-60277834-20b7-11e8-901e-f0f964d2253d.jpg)
Then you need to redirect your favorite radio to your imac ip address (the one running this app) for the first radio favorite (making sure that you did not change OnkyoConfig.ini in the [LocalButton] section with command = cast,,!1SLI28,,!1NPR01...). Setting path to http://your_imac_ip:8000/OnkyRemote in the Onkyo Web page.
![shot-cast1](https://user-images.githubusercontent.com/36587077/36996756-dc7aca80-20b7-11e8-9cfc-3ea32e1d560b.jpg)

Note that uou can use any other audio driver, but then you need to change the configuration and script files contained in this App (in Content/Resources/castSW/ directory).

To analyse in more details the corrent behaviour of this app, you can open the "console.app" application, filtering 'onky' messages, and/or also open local web page to monitor icecast and darkcast deamons behaviour, at 127.0.0.1:8000.
![shot-console](https://user-images.githubusercontent.com/36587077/36997242-4a96ca36-20b9-11e8-997b-aab39df68786.jpg)
![shot-cast2](https://user-images.githubusercontent.com/36587077/36997275-5de221ee-20b9-11e8-8dd1-4c489cf97dcb.jpg)

You can also edit content of the "OnkyoRemote.ini" file contained in this App container (in Content/Resources/ directory), to create your own commands for any specific Onkyo equipment.
![shot-showpackagecontents](https://user-images.githubusercontent.com/36587077/36996473-3b5cc4c8-20b7-11e8-839b-a06940ed8a94.jpg)

![shot-onkyoconfigini](https://user-images.githubusercontent.com/36587077/36996618-85776c3e-20b7-11e8-924f-d37d71eb564f.jpg)

For instance a modified "OnkyoRemote.ini" could allow you to change this application behaviour and associated commands
![shot-specific](https://user-images.githubusercontent.com/36587077/36997327-989c49b8-20b9-11e8-8be0-7e301ad55614.jpg)

A precompiled version is available in the "release" @ https://github.com/lebera/OnkyRemote/releases
