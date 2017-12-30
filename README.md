Jared Conroy & Bobby Martin
Pacman Project
COMP-3070-01

HOW TO RUN THE GAME:
1.) Move the entire Pacman-Conroy_Martin folder to your C:\ drive
2.) Double click the batch file in the folder (Pacman.bat). This changes the console window to the correct dimensions to show all of the map
3.) (optional) Move the masm32 folder out of the Pacman-Conroy_Martin folder to your C:\ drive. this is necessary to compile and run the source code

Lines of code: 2954

Jared's Contributions:
- Created all graphics and splash screens
- implemented color
- implemented sound

Bobby's Contributions:
- all game functionality

KNOWN BUGS:
1. If you don't eat the cherry and you die, it disappears from the map but you can still eat it and hear the noise and get the points if you go over the spot where it spawns.
2. The waka sounds only work half the time on a real Windows machine (only one test case), but they are fully functional on the Windows partition of a Mac (also one test case).
3. If Pacman-Conroy_Martin\sounds is not in the correct directory, all sounds will be the Windows notification sound instead of what they should be.