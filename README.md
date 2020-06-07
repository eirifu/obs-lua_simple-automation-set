# obs-lua_simple-automation-set
Simple automation and utility scripts that I incorporate in my livestreams with OBS Studio.

## Script Summaries

### Detailed Clock with 4 Timezones and the Date
- Used as a timestamp and a breakfast-show style clock, so you know when you should leave.

### Modified Countdown Timer without an hour digit
- Because countdown timers usually only go for a few minutes.

### Countdown Timer THEN Start Recording at 0
- The "Starting Soon" screen typically has next-to-no activity, which wastes recording space.
- To prevent accidental recording/privacy breaches, this only occurs IFF you are already streaming.

### Countdown Timer THEN Stop Recording at 0
- The "BRB" screen typically has next-to-no activity, which wastes recording space. Also helps with splitting your stream segments.
- To prevent accidental recording/privacy breaches, this only occurs IFF you are already streaming.

### Countdown Timer THEN Stop Streaming and Recording
- Made for the "End of Stream" scene.
- Because you might forget to press "stop", causing privacy problems.

### Countup Timer
- So the viewer knows exactly how long the stream has been stuck on the BRB screen.

### Emergency Volume Hotkey
- Switches the selected Desktop Audio source to a different volume. This is not a slider, but changes it to a preset dB value.
Games don't have a consistent maximum volume, so you may need to lower/raise the volume when switching games, starting a game for the first time, or you're stuck in a cutscene and it's not affected by game settings. In many of these cases, you are also unable to Alt-Tab to monitor and change the volume.
- From experience, most loud games can be fixed if the apparent volume is simply halved, which is why the hotkey is a switch.

### Visible/Invisible if Stream/Recording is Active
- Lets you have a really big "REC" on-screen if you're recording. You can also set one for streaming.
