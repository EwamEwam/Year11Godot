extends Node

#Dictionaries containing most of the text data in the game. Something Something autoload so everything in the game can access it
var weapon_descriptions :Dictionary = {
"1" = "Crafts the Revovler. Costs 2 Hp to shoot, has a firerate of 2 seconds and deals 8 base damage. Can pierce up to 2 enemies.",
"2" = "Crafts the Shotgun. Costs 4 Hp to shoot, has a firerate of 1.35 seconds and shoots a spread of 6 bullets that each deal 4 damage.",
"3" = "Crafts the SMG, Costs 1 Hp to shoot, has a fireate of 0.25 seconds and deals 3 base damage. Has a bit of inaccuracy."
} 

var weapon_names: Dictionary = {
"1" = "Revolver",
"2" = "Shotgun",
"3" = "SMG",
"4" = "Maxed"
}

var Signs: Dictionary = {
"1" = "Hello, this text is a placeholder/test. Please ignore me and enjoy your day. - Jeremy",
"2" = "Welcome to Beat Blast, A top down shooter where you shoot pieces of your heart. (Press Z again to close)",
"3" = "This is just the tutorial but the game gets much harder as you play on. Make sure to have good aim to save on health.",
"4" = "Hidden in levels are collectables and permanent upgrades, this here is a health capsule. It increases you max HP by 10. Each level has one.",
"5" = "Areas cut out of the main path and protected by many enemies often indicate treasure, find what's on the other side.",
"6" = "Crates and pots contain loot, Crates often contain hearts to restore health while pots contain gems, the game's currency.",
"7" = "While enemies are the main damage source, they are also the main source of loot like hearts to restore health and gems to buy upgrades and items in the store!",
"8" = "Some enemies have unique behaviour, for example this small slime doesn't do damage but instead gives the player the slimed status effect.",
"9" = "Alongside signs, other hints and notes can be found on paper sheets around the world.",
"10" = "Hello Bobby, it is me, Jeremy. I have stolen your chest as well your liver and plan to not give it back, Do you want revenge, then find all 3 gems keys and bring them to my castle! - Jeremy",
"11" = "Turn right if you think you're ready for a challenge (It's best not to)",
"12" = "These are doors! Hidden in levels are also buttons, find the button to open the door.",
"13" = "These are buttons, they open doors. Shoot them or punch them to press them.",
"14" = "Hint. Punch small and weak enemies instead of slowly shooting them one by one, it saves time and health.",
"15" = "I know you didn't mean to",
"16" = "Welcome to Poopcheek Desert! The enemies here are now tougher and the level is now slighty longer.",
"17" = "Hello Bobby. I have hidden the key behind these three doors, do you think you can open it. - Jeremy",
"18" = "it pains me too",
"19" = "Welcome to TuYung Volcano! The enemies are even tougher here.",
"20" = "Hello Bobby, it looks as though you have found all the keys, nevertherless, you will not survive even a single second in my castle. - Jeremy.",
"21" = "why... why did they do it",
"22" = "Hello Bobby, it seems you have found your way into my castle. That's why I have stolen a bunch of creatures and made them my soldiers! Good Luck!",
"23" = "Hello Bobby, you're only halfway there. Turn back. Please.",
"24" = "Hello Bobby, it seems as though you have made your way to the end of the castle, I'm in the next room, I'll be waiting to see you.",
"25" = "Thank you Bobby, but your Jeremy is in another castle. AKA I ran out of time to develop a final boss. Sorry.",
"26" = "But I'm not going to leave you without an ending though, so instead, here's a ticket saying You Win on it! You've earnt it",
"27" = "maybe it was meant to be this way"
}

var notes: Dictionary = {
"1" = "Game made in Godot Engine",
"2" = "NOTE!
Press ESCAPE during gameplay to pause the game or in level select to go back to menu and reset all data.",
"3" = "Disclaimer!
The guns in the game are nothing like their real life counterparts.",
"4" = "After an almost lethal encounter with Jeremy, He has left you in a devastating state, Stealing your chest and liver and leaving your heart exposed.",
"5" = "With only a handgun with no ammo to defend you, you must use pieces of your heart as bullets to kill enemies, find Jeremy and exact your revenge.",
"6" = "After I made this game, now I Love Sausage"
}
