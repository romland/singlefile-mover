# Watch a folder and move created (HTML) files (Windows)
PowerShell script for moving downloaded `SingleFile` (Firefox add-on) documents to network storage,
making sure they are backed up instead of deleted when I on occasion clear my download folder.

## Configure
Make sure you change `$path` and `$global:destination` in `watch-and-move.ps1` to something that works for you.

## Startup
To start this when you log in to Windows, put `start-watch-and-move.cmd` in `%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\`

_Note_: Make sure you change the path to where `watch-and-move.ps1` is on your system.
