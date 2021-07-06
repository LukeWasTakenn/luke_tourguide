# luke_tourguide
FiveM mod for the ESX framework

Hey, this is my second big release. I think it's a lot better than the first one in every single aspect.
I present you the Tour Guide job for the ESX framework!

When you get the job and clock in, you can choose a route, the routes are very easy to make and configure inside the Config.lua file.

When you choose a route, the script will first take you to pick up the tourists at the Depot (default) and then it will follow the coordinates provided depending on the route you chose sequantially.

Similarly when the route is over, the script is going to take you back to the Depot (default) so you can drop off the tourists that you picked up. After that it is going to ask you whether you want to do another route or go back and return the vehicle.

When you add a route following the template I provided inside there, it is going to be automatically added to the menus so you don't need to worry about that (You still need to restart the script if you're doing it live though).

The payment is based on the number of stops you have in your route, you can, of course, configure this amount.

For this release I used <a href='https://forum.cfx.re/t/release-warmenu-lua-menu-framework/41249'>WarMenu</a> (made by Warxander) for the menu system and <a href='https://forum.cfx.re/t/release-pogress-bar-progress-bar-standalone-smooth-animation/838951'>pogressBar</a> (made by Poggu) for the progress bars.

The script is open-source so feel free to edit it to your own liking, but please don't claim it as yours.

<a href='https://youtu.be/eQoh1UdnHio'>Video Preview</a>.

Please feel free to leave your feedback.

<h2>How To Install</h2>

1. Download the script, unpack it, remove the -master from the folder name and place it inside of your Resources folder.

3. Download pogressBar made by Poggu <a href='https://github.com/SWRP-PUBLIC/pogressBar/archive/master.zip'>here</a>. Unpack it, remove -master from the folder name and place it inside of your Resources folder.
4. Download WarMenu made by Warxander <a href='https://github.com/warxander/warmenu/archive/master.zip'>here</a>. Unpack it, remove -master from the folder name and place it inside of your Resources folder.
5. Import the .sql file from my resource into your database.
6. Start the scripts in your server.cfg file, make sure you are starting warmenu before pogressBar and pogressBar before luke_tourguide.
