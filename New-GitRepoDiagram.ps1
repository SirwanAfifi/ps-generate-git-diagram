Function New-GitRepoDiagram {
    $commitIds = @()
    $branches = git branch | ForEach-Object {
        $default = $false
        $activeBranch = git symbolic-ref --short HEAD
        $currentBranch = ($_.Replace("* ", " ")).Trim()
        if ($currentBranch -eq $activeBranch) {
            $default = $true
        }
        @{
            name         = $currentBranch
            isMainBranch = $default
        } | ConvertTo-Json
    } | ConvertFrom-Json

    $defaultBranch = $branches | Where-Object { $_.isMainBranch -eq $true } | Select-Object -ExpandProperty name
    $mermaidFile = "%%{init: { 'gitGraph': {'mainBranchName': '$defaultBranch' } } }%%" + [Environment]::NewLine
    $mermaidFile += 'gitGraph' + [Environment]::NewLine

    foreach ($branch in ($branches | Sort-Object -Property isMainBranch -Descending)) {
        $name = $branch.name
        $notIncludeTheMainCommits = $name -ne $defaultBranch ? "--not $(git merge-base $defaultBranch $name)" : ""
        $logs = git log --pretty=format:'{"commit": "%h", "author": "%an", "message": "%s"}' --reverse $name | ConvertFrom-Json
        if ($name -ne $defaultBranch) {
            $mermaidFile += '   branch "$name"'.Replace('$name', $name) + [Environment]::NewLine
        }
        foreach ($log in $logs) {
            $commit = $log.commit
            if ($commitIds -contains $commit) {
                continue
            }
            $commitToAdd = '   commit id: "$commit"'.Replace('$commit', $commit) + [Environment]::NewLine
            $mermaidFile += $commitToAdd
            $commitIds += $commit
        }
        if ($name -ne $defaultBranch) {
            $mermaidFile += '   checkout main' + [Environment]::NewLine
        }
    }
    Write-Host $mermaidFile
}

New-GitRepoDiagram