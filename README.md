Onkyo Remote App for MacOSX menu bar.
This App is able to redirect MacOSX sounds to your Onkyo receiver using "icecast" & "darkice" deamon
You need to install a dedicated driver such as the one from AirBeamTV http://bit.ly/2lTqyDQ
You can use any other driver, but then you need to change the configuration and script files contained in this App (in Content/Resources/castSW/ directory).
Then you need to edit content of the "OnkyoRemote.ini" file contained in this App (in Content/Resources/ directory), at least to specify the correct IP address of your Onkyo equipment.
You can also create your own commands for any specific Onkyo equipment

OnkyoRemote configuration file

Set the parameters according to your configuration

[OnkyoClient]
address = 192.168.1.14 ; set IP address of your Onkyo equipment
port = 60128 ; set IP port of your Onkyo equipment (default is 60128)
timeout = 5
[PowerButton]
nameOn = ON ; give name for Power On button
nameOff = OFF ; give name for Power Off button
commandOn = !1PWR01
commandOff = !1PWR00
[LocalButton]
name = LOCAL ; Give the name of the local radio
command = icecast,,!1SLI28,,!1NPR04,,!1NTCPLAY ; if icecast set favorite internet radio to your mac ipaddress : 8000/OnkyoRemote, eg. http://your_ip:8000/OnkyRemote, then activate network on onkyo, then pause 1sec, then set favorite internet radio (to your mac))
[Volume]
maxVol = 40 ; Set maximum Volume (max 80)
defaultVol = 20 ; Set default Volume to 20
command = !1MVL%002X
[Button1]
name = TV ; Give the name of the button
command = !1SLI01 ; activate the specified source
menu = 0 ; if zero then button does not show any submenu
[Button2]
name = RADIOS ; Give the name of the button
command = N/A ; Not Applicable when menu is not zero
menu = 2 ; specify the number of items in submenu
menu_name_01 = FIP
menu_command_01 = !1SLI28,,,!1NPR02,,,!1NTCPLAY ; activate network on onkyo and set favorite internet radio id
menu_name_02 = BFM
menu_command_02 = !1SLI28,,,!1NPR03,,,!1NTCPLAY ; activate network on onkyo and set favorite internet radio id
[Button3]
name = SETTINGS ; Give the name of the button
command = N/A ; Not Applicable when menu is not zero
menu = 10 ; specify the number of items in submenu
menu_name_01 = Speaker_A_On
menu_command_01 = !1SPA01
menu_name_02 = Speaker_A_Off
menu_command_02 = !1SPA00
menu_name_03 = Speaker_B_On
menu_command_03 = !1SPB01
menu_name_04 = Speaker_B_Off
menu_command_04 = !1SPB00
menu_name_05 = Set_Stereo
menu_command_05 = !1LMD00
menu_name_06 = Set_Direct
menu_command_06 = !1LMD01
menu_name_07 = Set_Surround
menu_command_07 = !1LMD02
menu_name_08 = Music_optimizer_On
menu_command_08 = !1MOT01
menu_name_09 = Music_optimizer_Off
menu_command_09 = !1MOT00
menu_name_10 = Exit
menu_command_10 = exit
