```cd downloads```

```powershell -ExecutionPolicy Bypass -File block.ps1```

```powershell -ExecutionPolicy Bypass -File remove.ps1```

Vscode ```winget install Microsoft.VisualStudioCode```
<br/><br/>
Sublime
```winget install -e --id SublimeHQ.SublimeText.4```

<br/><br/>
CodeBlocks with MingW
```winget install -e --id CodeBlocks.CodeBlocks.MinGW```


<br/><br/>

First write ```powewrshell```

```
$MinGWPath = "C:\Program Files\CodeBlocks\MinGW\bin"
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $MinGWPath, "Machine")
```

<br/><br/>

First write ```powewrshell```

Python
```winget install -e --id Python.Python.3.13```

```
$PythonPath = "$env:LOCALAPPDATA\Programs\Python\Python313"
$PythonScripts = "$env:LOCALAPPDATA\Programs\Python\Python313\Scripts"
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + $PythonPath + ";" + $PythonScripts, "Machine")
```
