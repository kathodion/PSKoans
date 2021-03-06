
Write-FormatCustomView -AsControl -Name Prompt.Preface -Action {
    Write-FormatViewExpression -Text @"
    Welcome, seeker of enlightenment.
    Let us observe your karma...
"@ -ForegroundColor 'PSKoans.Meditation.Text'

    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline
}

Write-FormatCustomView -AsControl -Name Prompt.Describe -Action {
    Write-FormatViewExpression -ScriptBlock {
        'Describing "{0}" has damaged your karma.' -f $_
    } -ForegroundColor 'PSKoans.Meditation.Error'

    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline
}

Write-FormatCustomView -AsControl -Name Prompt.Expectation -Action {
    Write-FormatViewExpression -Text @"
    You have not yet reached enlightenment.

    The answers you seek...
"@ -ForegroundColor 'PSKoans.Meditation.Text'

    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -Property Expectation -ForegroundColor 'PSKoans.Meditation.Error'

    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline
}

Write-FormatCustomView -AsControl -Name Prompt.Meditation -Action {
    Write-FormatViewExpression -Text @"
    Please meditate on the following code:
"@ -ForegroundColor 'PSKoans.Meditation.Text'

    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -ScriptBlock {
        @"
{0} It "{1}"
{2}
"@ -f [char]0xd7, $_.It, $_.Meditation
    } -ForegroundColor 'PSKoans.Meditation.Error'

    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline
}

Write-FormatCustomView -AsControl -Name Prompt.Koan -Action {
    Write-FormatViewExpression -ScriptBlock {
        & (Get-Module -Name PSKoans) {
            $ReplacementPattern = '$1    {0} ' -f [char]0x258c
            (Get-Random -InputObject $script:MeditationStrings) -replace '^|(\r?\n)', $ReplacementPattern
        }
    } -ForegroundColor 'PSKoans.Meditation.Emphasis'

    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline
}

Write-FormatCustomView -AsControl -Name Prompt.TopicList -Action {
    Write-FormatViewExpression -ScriptBlock {
        $TopicList = $_.Topics -replace '^', '        - ' -join [Environment]::NewLine
        $TopicOrTopics = if ($_.Count -gt 1) { 'topics' } else { 'topic' }
        $_.FormatString -f $TopicOrTopics, $TopicList
    } -ForegroundColor 'PSKoans.Meditation.Text'

    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline
}

Write-FormatCustomView -AsControl -Name Prompt.ProgressPreamble -Action {
    Write-FormatViewExpression -If { -not $_.Complete } -ScriptBlock {
        @"
    You examine the path beneath your feet...
"@
    } -ForegroundColor 'PSKoans.Meditation.Text'

    Write-FormatViewExpression -If { $_.Complete } -ScriptBlock {
        @"
    You cast your gaze back upon the path that you have walked...
"@
    }-ForegroundColor 'PSKoans.Meditation.Text'
}

Write-FormatCustomView -AsControl -Name Prompt.ProgressBar -Action {
    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -ScriptBlock {
        $ConsoleWidth = ($host.UI.RawUI.WindowSize.Width, $host.UI.RawUI.BufferSize.Width, 80).Where{ $_ -ge 30 }[0]
        $TopicProgressAmount = "{0}/{1}" -f $_.Completed, $_.Total
        $ProgressWidth = $ConsoleWidth * $_.Width - ($_.Name.Length + $TopicProgressAmount.Length + 7)

        [int] $PortionDone = ($_.Completed / $_.Total) * $ProgressWidth

        " [{3}]: [{0}{1}] {2}" -f @(
            "$([char]0x25a0)" * $PortionDone
            "$([char]0x2015)" * ($ProgressWidth - $PortionDone)
            $TopicProgressAmount
            $_.Name
        )
    } -ForegroundColor 'PSKoans.Meditation.Progress'
}

Write-FormatCustomView -AsControl -Name Prompt.End -Action {
    Write-FormatViewExpression -Newline
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -Text @"
Run 'Show-Karma -Meditate' to begin your meditations.
"@ -ForegroundColor 'PSKoans.Meditation.Text'
}

Write-FormatCustomView -AsControl -Name Prompt.Details -Action {
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -If {
        $_.Describe -and
        $_.Describe -ne $global:_Koan_Describe
    } -ScriptBlock {
        $global:_Koan_Describe = $_.Describe
        $Indent = " " * 4

        '{0}Describing {1}{2}' -f $Indent, $_.Describe, [Environment]::NewLine
    } -ForegroundColor 'PSKoans.Meditation.Text'

    Write-FormatViewExpression -If {
        $_.Context -and
        $_.Context -ne $global:_Koan_Context
    } -ScriptBlock {
        $global:_Koan_Context = $_.Context
        $IndentSpaces = 4
        if ($_.Context) { $IndentSpaces += 2 }
        $Indent = " " * $IndentSpaces

        '{0}{1}{2}' -f $Indent, $_.Context, [Environment]::NewLine
    } -ForegroundColor 'PSKoans.Meditation.Emphasis'

    Write-FormatViewExpression -If { $_.Passed } -ScriptBlock {
        $IndentSpaces = 4
        if ($_.Context) { $IndentSpaces += 4 } elseif ($_.Describe) { $Indent += 2 }
        $Indent = " " * $IndentSpaces

        '{0}[{1}] It {2}' -f $Indent, [char]0x25b8, $_.Name
    } -ForegroundColor 'PSKoans.Meditation.Passed'

    Write-FormatViewExpression -If { -not $_.Passed } -ScriptBlock {
        $IndentSpaces = 4
        if ($_.Context) { $IndentSpaces += 4 } elseif ($_.Describe) { $Indent += 2 }
        $Indent = " " * $IndentSpaces

        '{0}[{1}] It {2}' -f $Indent, [char]0xd7, $_.Name
    } -ForegroundColor 'PSKoans.Meditation.Error'
}
