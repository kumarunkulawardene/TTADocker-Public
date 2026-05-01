filter timestamp {"$(Get-Date -Format G): $_"}
Write-output "Delete Program Cache" | timestamp
# Delete Program Cache

Get-ChildItem -LiteralPath 'C:\ProgramData\Package Cache\'  -Recurse | 
Select -ExpandProperty FullName | 
sort length -Descending | 
	ForEach-Object {
		try {
				#  -ErrorAction Ignore is being used to suppress known issue in Docker on Windows Server 2016 with deletion
				Remove-Item -path $_ -force -ErrorAction Ignore;
			}
		catch { }
	}
filter timestamp {"$(Get-Date -Format G): $_"}
Write-output "Program Cache deletion completed" | timestamp	