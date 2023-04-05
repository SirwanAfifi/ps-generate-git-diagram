# Generating Git diagram using Mermaid

This is a simple example of how to generate a Git diagram using Mermaid.

## Usage

```ps
pwsh -f ./New-GitRepoDiagram.ps1
```

You can then copy the output from the console and paste it into the [Mermaid Live Editor](https://mermaid-js.github.io/mermaid-live-editor/).

PS: I wrote this little script to generate the git repository:

```ps
Function New-RandomRepo {
    Function RandomFiles($branch = "main") {
        1..3 | ForEach-Object {
            New-Item -ItemType File -Name "file_$($_).txt"
            Set-Content -Path "file_$($_).txt" -Value "This is file $($_) on branch $branch"
            git add .
            git commit -m "Commit $($_) on branch $branch"
        }
    }
    Set-Location ~/Desktop
    New-Item -ItemType Directory "random_git_repo"
    Set-Location "random_git_repo"
    git init -b main
    Write-Output "This is the main branch" | Set-Content -Path "main.txt"
    git add .
    git commit -m "Initial commit"
    1..3 | ForEach-Object {
        git checkout -b "branch_$($_)"
        RandomFiles "branch_$($_)"
        git checkout main
    }
}

```
