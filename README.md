# thinkpad_battery_tool

![BANNER](https://github.com/Patan98/thinkpad_battery_tool/assets/159428129/2f3eaf0a-d588-4bfe-8373-e4f0c8f3f7d4)

## Thinkpad battery tool
Simple bash script with zenity interface and csv text as "database" to manage battery information. <br />
Zenity is required for proper operation. <br />

## Idea
Thinkpads UP TO the t580/t480 series can be configured with multiple removable batteries, this script helps with a minimal interface to keep track of battery health and receive notifications when the battery is dynamically changed. <br />
If the PC is charging the removable main battery can be changed with the PC switched on (T420/T430 etc.). <br />
Some models supports hot-swap ultrabay battery (like 45N1041). <br />
Some models supports hot-swap slice batteries (like 40Y7625). <br />

## Usage
To launch the script in the background and make it work, you can run the script with -m and let it run in monitor mode.  <br />
To launch the GUI you can run the script with -g argument and keep track of battery health and serial numbers. <br />
As soon as a battery is inserted during use you will receive a notification. <br />
If it is a new battery and is not yet in the database you will be asked if you want to add it to the database, and you will be asked to assign it a "nickname" (this also works if the battery is already plugged at system startup). <br />
If the battery is added as a primary battery it will be added to the top of the database. <br />
