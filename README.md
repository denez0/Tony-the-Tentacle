# Tony the Tentacle

#### Video Demo: https://www.youtube.com/watch?v=MYXQRostH4Y

#### Description:

> the game is about a robopocalypse where robots behave strangely!

- as stated in the first line of code.

The game 'Tony the Tentacle' is written in [Lua](https://www.lua.org/), using the [LÖVE](https://love2d.org/) framework. This particular choice was made after watching a CS50 seminar.
It tells a story of Tony (a white moving rectangle), who can kill robots with a touch of his extending tentacle.
The robots are broken (mentally, because they still move) and try to take over the world. They are friendly half the time, but the other half they try to disintegrate you (you can tell them apart by the color of their eyes).

You have sound effects, music, different backgrounds, physics, an interesting ending, score counter, intro, camera, all intertwined in roughly 300 lines of code.

main.lua is the essence of the game
moving.lua sets up the 'Moving' class of objects (i.e. the functions of initializing, updating the coordinates of and drawing the 'Moving' objects). Creating this class cut the number of lines drastically, which I'm especially proud of
conf.lua configurates the window in which the game is played
audio/, images/ and libraries/, as the names imply, contain 3rd-party sources
.vscode/ has a file which sets up the vscode Lua extension

I tried to make the code as readable as possible, with few repeating parts (DRY = Don't Repeat Yourself), valuing conciseness and using few third sources. It was hard to code it, especially the intro and collisions, but was totally worth it in the end. I keeped the default (small) size of the window, because it's a small (indie) game. I learned a lot along the way, and after some time I finally understood what I had written :). Sheepollution and Challacade are the best LÖVE introductions I found.
I planned to name each robot differently using a csv file of a 100 common names, but am not sure if that would be interesting from the UI/UX perspective.
There were also considerations of a final boss or even multiple levels, but the coding proved more exhausting than expected, so I went with having scaled robots after a victory, which happens when the score is 10; and different backgrounds intead of levels.
The coding part took me roughly 1 month, the video recording and markdown writing 10 times more.

#### Full description of the main.lua file:

First, it loads the data which is preserved on dying: continuos music, the tutorial and credits booleans.
Then, it loads the data (with the love.load() function) which is reloaded every time you die:
The world (physics), graphics, objects and files accessed \*

- I'm not sure it's effective to make some of these reloaded **each** time, but the performance is good enough, so I didn't change it

function love.update(dt) \* dt stands for delta time and makes time intervals consistent
shows the credits for 4 seconds and the tutorial until 'p' is pressed, if not shown already
creates an enemy every 2 to 6 seconds
defines movement as a temporary force application => sliding some time, before the friction wins; jumping as an impulse; Esc, p, and q (as pointed out in the game) to close the game, pause the music and restart the game after winning, accordingly
blocks crossings of the map borders
defines tentacle movement, so that it sticks to the player
uses the camera to follow Tony
makes enemies move towards the player
handles kills (of and by robots)
changes the look of robots (gif: red <-> green eyes) and makes them (pseudo) jump

function love.draw()
renders the credits, tutorial, victory text, score counter, all the objects, background
following the camera

additional functions:
create and retrieve inde(x/ci)es of enemies
create [tables](<https://www.google.com/search?q=table+lua&oq=table+lua&gs_lcrp=EgZjaHJvbWUyBggAEEUYOdIBCDIyMTlqMGo3qAIAsAIA&sourceid=chrome&ie=UTF-8#:~:text=Tables%20are%20the%20main%20(in%20fact%2C%20the%20only)%20data%20structuring%20mechanism%20in%20Lua>), in which files of the same type are loaded (instead of adding sfx1.ogg, sfx2.ogg .. manually)
defines what to do on victory

#### The Easter eggs:

Robots grow bigger (in the code: from suboptimuses they become Optimuses Prime) and change to peaceful ones once you win. The song 'I just did a bad thing' by Bill Wurtz plays.
You can change colors for fun in the moving.lua file.
Kills/ deaths get printed in the console, if you open the game in lovec.exe

#### Copyright owners:

- [SSYGEN](https://github.com/a327ex): windfield, the physics library
- [rxi](https://github.com/rxi): classic, the Object library
- [Matthias Richter](https://github.com/vrld): the camera library
- [upklyak](https://www.freepik.com/author/upklyak), [Freepik](https://www.freepik.com/): pictures and the logo
- [mixkit](https://mixkit.co/): sound effects
- [009 Sound System](https://www.youtube.com/channel/UCIY4UtKdPp5ArYEc4FJZYpA): the main song = [Dreamscape (Remastered)](https://www.youtube.com/watch?v=uOqfs0ls92s)
- [Bill Wurtz](https://www.youtube.com/@billwurtz): winsong = [i just did a bad thing](https://www.youtube.com/watch?v=O2yPnnDfqpw)

#### How to install and play

Full instructions may be found here:
https://love2d.org/wiki/Game_Distribution

Windows:
https://www.youtube.com/watch?v=h7II1fiaWKA

Here's a good explanation as well:
https://github.com/Dpbm/SnakeGame?tab=readme-ov-file#---how-to-run-
