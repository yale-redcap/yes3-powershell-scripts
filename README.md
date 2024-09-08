# Powershell support

The YES3 documentation repos include support for a set of Windows PowerShell "cmdlets" that can help manage Git processes. The YES3 Powershell cmdlets act like Powershell commands.

The cmdlets will work in any IDE that supports PowerShell terminals, including VSCode and Writerside (and other JetBrains IDEs). Use of these cmdlets is optional. The author wrote them for his own use.

The YES3 Powershell scripts are stored in the public GitHub repository <a href="https://github.com/yale-redcap/yes3-powershell-scripts" target="_blank">https://github.com/yale-redcap/yes3-powershell-scripts</a>

## The YES3 Powershell scripts

There are two YES3 PowerShell scripts, as described in the following table.

### session-install.ps1 

source: <a href="https://github.com/yale-redcap/yes3-powershell-scripts/blob/main/session-install.ps1" target="_blank">https://github.com/yale-redcap/yes3-powershell-scripts/blob/main/session-install.ps1</a>

The script ```session-install.ps1```, when executed from a PowerShell terminal, will install the YES3 cmdlets into the user's PowerShell profile. This script is distributed in the root directory of every YES3 documentation repo. 

> geek note: A GitHub workflow in the YES3 PowerShell repository will update ```session-install.ps1``` in each YES3 documentation repo whenever an update is pushed, ensuring that the latest version is available.

### session-module.psm1

source: <a href="https://github.com/yale-redcap/yes3-powershell-scripts/blob/main/session-module.psm1" target="_blank">https://github.com/yale-redcap/yes3-powershell-scripts/blob/main/session-module.psm1</a>

The script ```session-module.ps1``` is a PowerShell module script that defines the session cmdlets.

#### The session cmdlets

|cmdlet| action                    | notes                                                                                                                                                                                                                                                                                                                                          |
|---|---------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|Start-Session| starts an editing session | Checks out and updates the main branch, then creates and checks out a session branch.                                                                                                                                                                                                                                                          |
|Complete-Session| Completes (ends) an editing session | Stages and commits all changes, pushes the session branch to the remote repository, switches back to the local main branch, updates the local main branch.                                                                                                                                                                                     |
|Undo-Session| Cancels an editing session| Removes the session branch, switches to the main branch, updates the main branch.                                                                                                                                                                                                                                                              |
|Get-SessionCommands|Displays the list of session cmdlets.|                                                                                                                                                                                                                                                                                                                                                |
|Get-DadJoke|Does what you think it does.|                                                                                                                                                                                                                                                                                                                                                |
|Update-GitBranch|Updates local main branch| If current branch is 'main' or 'master', will (1) fetch metadata, (2) check if local branch is out of sync with remote branch, (3) if not will reset local main/master branch to remote state. Note: this cmdlet is executed when PS terminal is opened, to prevent unintentional creation of a local session branch from a stale main/master. |.
