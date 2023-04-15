<#
AnsiStyle {
    Undo = 0
    Bold = 1
    Italic = 3
    UnderLine 4
}
AnsiFgColor {
    Black = 30
    DarkRed = 31
    DarkGreen = 32
    DarkYellow = 33
    DarkBlue = 34
    DarkMagenta = 35
    DarkCyan = 36
    DarkWhite = 37
    Gray = 90
    Red = 91
    Green = 92
    Yellow = 93
    Blue = 94
    Magenta = 95
    Cyan = 96
    White = 97
}
#>

class PureLight {
    static hidden [string] ansiSeq([int]$style, [int]$fgColor) {
        return "$([char]0x1b)[{0};{1}m" -f $style, $fgColor
    }
    static hidden [timespan] timeSpan($value) {
        #return ($value -is [Int]) ? [timespan]::FromSeconds($value) : [timespan]$value
        if ($value -is [Int]) { return [timeSpan]::FromSeconds($value) }
        return [timeSpan]$value
    }
    hidden [char] $_promptChar = '>'
    hidden [string] $_promptColor = [PureLight]::ansiSeq(0, 95)  #Magenta
    hidden [string] $_errorColor = [PureLight]::ansiSeq(0, 91)  #Red
    hidden [string] $_pwdColor = [PureLight]::ansiSeq(0, 36)  #DarkCyan
    hidden [string] $_timeColor = [PureLight]::ansiSeq(0, 33)  #DarkYellow
    hidden [string] $_userColor = [PureLight]::ansiSeq(0, 90)  #Gray
    hidden [string]  $_userRootColor = [PureLight]::ansiSeq(0, 33)  #DarkYellow
    hidden [timespan] $_slowCommandTime = [timespan]::FromSeconds(5)
    hidden [scriptblock] $_prePrompt = { param ($user, $cwd, $slow) "`n${user} ${cwd} ${slow}`n" }
    
    [scriptblock] $userFormatter = { param ($user) if ($user -eq 'root') { '!ROOT' } else { $user } }
    [scriptblock] $pwdFormatter = { $args -replace "${HOME}", '~' }

    hidden [void] updatePSReadLine() {
        Set-PSReadLineOption -ExtraPromptLineCount $(($this._prePrompt.ToString().Split("``n").Length) - 1)
        Set-PSReadLineOption -ContinuationPrompt $("{0}{0}" -f $this._promptChar)
        Set-PSReadLineOption -Colors @{ ContinuationPrompt = $this._promptColor }
    }
    hidden [void] addColorProperty([string] $shortName) {
        $name = "${shortName}Color"
        Add-Member -InputObject $this -Name $name -MemberType ScriptProperty -Value {
            $this."_$name" + "*$([char]0x1b)[0m" # coloured asterisk for display purposes
        }.GetNewClosure() -SecondValue {
            param([Int]$style, [Int]$fgColor)
            $this."_$name" = [PureLight]::ansiSeq($style, $fgColor)
            $this.updatePSReadLine()
        }.GetNewClosure()
    }

    PureLight() {
        foreach ($pref in @('Pwd', 'Error', 'Prompt', 'Time', 'User', 'UserRoot')) {
            $this.addColorProperty($pref)
        }

        Add-Member -InputObject $this -Name SlowCommandTime -MemberType ScriptProperty -Value {
            $this._slowCommandTime
        } -SecondValue { $this._slowCommandTime = [PureLight]::timeSpan($args[0]) }

        Add-Member -InputObject $this -Name PrePrompt -MemberType ScriptProperty -Value {
            $this._prePrompt
        } -SecondValue {
            param([scriptblock] $value)
            $this._prePrompt = $value
            $this.updatePSReadLine()
        }

        Add-Member -InputObject $this -Name PromptChar -MemberType ScriptProperty -Value {
            $this._promptChar
        } -SecondValue {
            param([char] $value)
            $this._promptChar = $value
            $this.updatePSReadLine()
        }
    }
}

function initOptions() {
    $Global:pure = New-Object PureLight
    $Global:pure.updatePSReadLine()
}