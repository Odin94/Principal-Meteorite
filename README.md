
## Story

A comet was on collision course with earth and would have wiped out our civilization, so the UEC (United Earth Corp.) tried to blow it up before it hit us. They almost succeeded. 

They managed to change it's trajectory so it would miss earth, but the explosion also split off several meteorites that are on track for impact. The first one of them, the *Principal Meteorite* has already reached earth. It has the size of the Burj Khalifa and obliterated an entire city on impact. But what's even worse: It's alive!

You are Sam Erin, famous bounty hunter and explorer, sent to into the maw of the beast to investigate. What will you find inside?


## Setup
* Open with Godot game engine (tested with v3.5 on Windows)


## Development
* When adding new enemies:
    * Make sure to set collision layer and mask
    * Make sure to wire the signals

* When adding a new level:
    * Make sure to include HUD & ParallaxBackground
    * Wire player health_changed to HUD
    * Adjust tilemap size to 16/16 and scale 2
    * Configure doors to link to the right next scene
    * Name doors / spawn points such that they will be matched (See Door.gd/Globals.gd/Player.gd _ready function) 

* When adding upgrades: Make sure to give them a unique name since save/load tracks them with it

## Planned features
* Quick end animation / screen

* Add reward after beating first boss (aside from +3 jumps)
* Make boss growl louder

* Quick intro when starting a new game
* 2nd boss fight  (TODO: Add more health to phase 3)
* Add missing audio
    * Boss sounds
    * Boss Background music
    * Muted sound when entering boss room (maybe heartbeat?)
    * Enemy sounds
    * Better walking sound?

## Credits
* Player sprite: [ronny14](https://www.youtube.com/user/pizzaguy14)
* Living tissue platforms, squid+crab+jumper enemy, bullet sprites: [Luis Zuno](https://www.patreon.com/ansimuz)
* Virus boss & bullets: [Kuuly](https://kuuly.itch.io)
* Font: Open Sans
* Space image: [Alex Andrews](https://www.pexels.com/photo/photo-of-deep-sky-object-816608/)
* Sounds:
    * Jumping, boss-1-scream, heartbeats [mixkit.co](https://mixkit.co/free-sound-effects)
    * Shooting, hurt-sounds, death-sounds, health-pickup made with [sfxr](https://sfxr.me)
    * Death scream by [AmeAngelOfSin](https://freesound.org/people/AmeAngelofSin/sounds/168814/)
    * Mini-Virus spawn sound by [alko_Changing on Pixabay](https://pixabay.com/sound-effects/deep-strange-whoosh-183845/)
    * Rumbling sound by [Pixabay](https://pixabay.com/sound-effects/earth-rumble-6953/)