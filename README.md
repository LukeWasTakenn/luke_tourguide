# luke_tourguide
FiveM mod for the ESX framework

Hey, this is my second big release. I think it's a lot better than the first one in every single aspect.
I present you the Tour Guide job for the ESX framework!

When you get the job and clock in, you can choose a route, the routes are very easy to make and configure inside the Config.lua file.
When you choose a route, the script will first take you to pick up the tourists at the Depot (default) and then it will follow the coordinates provided depending on the route you chose sequantially.
Similarly when the route is over, the script is going to take you back to the Depot (default) so you can drop off the tourists that you picked up. After that it is going to ask you whether you want to do another route or go back and return the vehicle.
When you add a route following the template I provided inside there, it is going to be automatically added to the menus so you don't need to worry about that (You still need to restart the script if you're doing it live though).
The payment is based on the number of stops you have in your route, you can, of course, configure this amount.

For this release I used WarMenu (made by Warxander) for the menu system and pogressBar (made by Poggu) for the progress bars.

The script is open-source so feel free to edit it to your own liking, but please don't claim it as yours.

All the scripts I make are free of charge. But if you do decide you want to support me and the work I do you can buy the script at my Tebex store for any amount.
Any amount you give will go a long way of helping me make more scripts which are also going to be free of charge.

Huge thank you to Spykerco and lefouduquebec who contributed in my Chop Shop release, you're awesome!

Please feel free to leave your feedback.

How To Install

1. Download the script, unpack it, remove the -master from the folder name and place it inside of your Resources folder.
2. Download pogressBar made by Poggu here. Unpack it, remove -master from the folder name and place it inside of your Resources folder.
3. Download WarMenu made by Warxander here. Unpack it, remove -master from the folder name and place it inside of your Resources folder.
4. Import the .sql file from my resource into your database.
5. Start the scripts in your server.cfg file, make sure you are starting warmenu before pogressBar and pogressBar before luke_tourguide.








https://github.com/SWRP-PUBLIC/pogressBar/archive/master.zip
https://github.com/warxander/warmenu/archive/master.zip