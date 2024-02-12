Set-StrictMode -Version 2.0

# Directory and file-name pattern to monitor.
$path = "K:\Downloads" 
$fileFilter = '*.html'

$global:destination = '\\nas\home\saved-pages\'

Write-Verbose -vb "FileSystemWatcher is monitoring $path...."

try {
  # Create the file-system watcher instance.
  $watcher = New-Object -TypeName System.IO.FileSystemWatcher -ArgumentList $path, $fileFilter -Property @{
    IncludeSubdirectories = $false
    # NotifyFilter = ... # What attributes to monitor; by default: LastWrite, FileName, and DirectoryName - see https://learn.microsoft.com/en-us/dotnet/api/system.io.notifyfilters
  }

  # Register for (subscribe to) creation events:
  # Determine a unique event-source ID...
  [string] $sourceId = New-Guid
  # ... and register for the watcher's `Created` event with it.
  Register-ObjectEvent $watcher -EventName Created -SourceIdentifier $sourceId -Action {
    try {
        Start-Sleep -Seconds 5
        $eventPath = $Event.SourceEventArgs.FullPath
        Move-Item -Path ($eventPath) -Destination ($destination) -Force -Verbose
    } catch {
        Write-Host "An error occurred while moving file:"
        Write-Host $_
        Write-Host $_.ScriptStackTrace
    }
  }

  # Run indefinitely; use Ctrl-C to exit.
  while ($true) {

    # Wait (indefinitely) in blocking fashion for the next pending event.
    $event = Wait-Event -SourceIdentifier $sourceId
    # The event must be manually removed from the queue.
    $event | Remove-Event
    
    # $event is an object of type [System.Management.Automation.PSEventArgs], 
    # $event.SourceArgs contains the event argument as an [object[]] array.
    # The 2nd event argument received contains the event details:
    # an object with .ChangeType, .FullPath and .Name properties.
    $eventDetails = $event.SourceArgs[1]
    
    # !! Due to an apparent bug up to at least PS 7.2,
    # !! outputting a non-primitive object whose type does NOT
    # !! have associated formatting data BLOCKS PIPELINE INPUT,
    # !! UNLESS an object WITH formatting data was output first (e.g., Get-Item /)
    # !! WORKAROUND: Use Out-Host
    $eventDetails | Out-Host
  }
}
catch {
  Write-Host "An error occurred in mainloop:"
  Write-Host $_
  Write-Host $_.ScriptStackTrace
}
finally {
  Write-Verbose -vb 'Cleaning up...'
  Unregister-Event -SourceIdentifier $sourceId
  $watcher.Dispose() 
}