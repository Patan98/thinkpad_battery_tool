# thinkpad_battery_tool

![BANNER](https://github.com/Patan98/thinkpad_battery_tool/assets/159428129/351615ea-05e8-41e4-8083-7dfa10f5de36)

## Thinkpad battery tool
Simple bash script with zenity interface to manage battery information. <br />
Zenity is required for proper operation. <br />
Thinkpads up to the t580/t480 series can be configured with multiple removable batteries, this script helps with a minimal interface to keep track of battery health and receive notifications when the battery is dynamically changed. <br />
If the PC is charging the removable main battery can be changed with the PC switched on (T420/T430 etc.). <br />
The t430s models even have a hot-swap ultrabay battery (45N1041). <br />
There are also additional hot-swap slice batteries (40Y7625). <br />
To keep track of battery health and serial numbers you can launch the gui and get a report. <br />
As soon as a battery is inserted during use you will receive a notification that the battery has been inserted. <br />
If it is a new battery and is not yet in the database you will be asked if you want to add it to the database, and you will be asked to assign it a "nickname". <br />
If the battery is added as a primary battery it will be added to the top of the database. <br />
