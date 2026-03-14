extends Node

@warning_ignore("unused_signal")
signal GAME_ON_PAUSE

@warning_ignore("unused_signal")
signal TOUCHING_THE_FLAG(sprite)

@warning_ignore("unused_signal")
signal COLLECTING_COINS(sprite)

@warning_ignore("unused_signal")
signal OPEN_THE_CHEST(sprite)

@warning_ignore("unused_signal")
signal OPEN_THE_DOOR(sprite)

#region_button
enum BUTTON_PLAY {Play1, Play2, Play3}

@warning_ignore("unused_signal")
signal BUTTON_PLAY_PRESSED(button: BUTTON_PLAY)
#endregion
