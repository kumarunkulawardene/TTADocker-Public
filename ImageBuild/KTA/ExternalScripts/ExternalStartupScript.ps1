filter timestamp {"$(Get-Date -Format G): $_"}
write-output "Hello from ExternalStartupScript" | timestamp