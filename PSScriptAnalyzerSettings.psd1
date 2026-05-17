@{
    ExcludeRules = @(
        # Bootstrap scripts download install code from upstream (Scoop, Chocolatey) and run it —
        # Invoke-Expression on the downloaded string is the documented install pattern.
        'PSAvoidUsingInvokeExpression',

        # Write-Host is used intentionally for human-readable status messages, not pipeline output.
        'PSAvoidUsingWriteHost'
    )
}
