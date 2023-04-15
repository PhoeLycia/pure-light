filter fmtColor($color) { $_ ? "${color}$_`e[0m" : '' }
#filter fmtColor($color) { if ($_) { "${color}$_$([char]0x1b)[0m" } else { '' } }

function global:prompt {
    [bool]$isError = !$?
    $userName = [System.Environment]::UserName

    $slowInfo = if ($pure.SlowCommandTime -gt 0 -and ($lastCmd = Get-History -Count 1)) {
        $diff = $lastCmd.EndExecutionTime - $lastCmd.StartExecutionTime
        if ($diff -gt $pure.SlowCommandTime) {
            '({0})' -f ('{0:hh\:mm\:ss\s}' -f $diff).TrimStart(':0') | fmtColor $pure._timeColor
        }
    }

    $promptColor = $isError ? $pure._errorColor : $pure._promptColor
    #$promptColor = if ($isError) { $pure._errorColor } else { $pure._promptColor }
    $userColor = ($userName -eq 'root') ? $pure._userRootColor : $pure._userColor
    #$userColor = if ($userName -eq 'root') { $pure._userRootColor } else { $pure._userColor }
    $user = &$pure.userFormatter $userName | fmtColor $userColor
    #$cwd = &$pure.pwdFormatter $($executionContext.SessionState.Path.CurrentLocation) | fmtColor $pure._pwdColor
    $cwd = &$pure.pwdFormatter $PWD.Path | fmtColor $pure._pwdColor

    (&$pure.PrePrompt $user, $cwd, $slowInfo) + ($pure.PromptChar | fmtColor $promptColor) + ' '
}
