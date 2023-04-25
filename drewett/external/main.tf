
data "external" "echo" {
    program = ["Powershell.exe", "./GetLocation.ps1"]
}

output "echo" {
  value = data.external.echo.result.location
}
