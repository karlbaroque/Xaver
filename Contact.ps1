param [switch]($Post)

#Define Const
$Message = "$PSScriptRoot\Message.txt"
$Post = "$PSScriptRoot\Post.txt"
$GitErrorMessage = "Failed to Connect Git at"

if (-not (Test-Path $Message)) {New-Item -type File $Message}
if (-not (Test-Path $Post)) {New-Item -type File $Post}
if ((dir $Message).LastWriteTime.AddDays(7) -ge (Get-Date)) {
	Set-Content -Path $Message -Value "" -Force
}
if ((dir $Post).LastWriteTime.AddDays(7) -ge (Get-Date)) {
	Set-Content -Path $Post -Value "" -Force
}

#Load Assembly
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

#Post Function
function Post {
		$PostMessage = Get-Content $Post -Encoding UTF8
		$Bytes = [System.Text.Encoding]::Unicode.GetBytes($PostMessage)
		$EncodedText =[Convert]::ToBase64String($Bytes)
		$Date = Get-Date -UFormat '%Y/%m/%d-%H:%M:%S'
		try {
			git add D:\PowerShell\Xaver
			git commit -m "$Date"
			git remote add origin https://github.com/karlbaroque/Xaver.git
			git push -u origin master
			Write-Host "Message Posted"
		}
		catch {Write-Host "Message Post Failed"}
}

if ($Post) {
	Post
	return
}
#Try download content from GitHub
try {
	$r = (iwr https://raw.githubusercontent.com/karlbaroque/Xaver/master/post.txt).Content
	if ($r.Trim().Length -gt 0) {
		$DecodedText = $r -split "`r`n" | % {[System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($_))}
		$oResult = [System.Windows.Forms.Messagebox]::Show($(($DecodedText -join "`r`n").Trim()))
	}
	if ($oResult) {
		$Date = Get-Date -UFormat '%Y/%m/%d-%H:%M:%S'
		Set-Content -Path $Message -Value $($Date + "`r`n" + $DecodedText + "`r`n") -Force
	}
	Post
}
catch {
	$oResult = [System.Windows.Forms.Messagebox]::Show($GitErrorMessage)
	$Date = Get-Date -UFormat '%Y/%m/%d-%H:%M:%S'
	Set-Content -Path $Message -Value $($Date + "`r`n" + $GitErrorMessage + "`r`n") -Force
}

