# Read the JSON payload from stdin
$jsonpayload = [Console]::In.ReadLine()

# Convert JSON to a string
$json = ConvertFrom-Json $jsonpayload
$environment = $json.environment

if($environment -eq "Production"){
 $location="easteu"
}else{
 $location="westeu"
}

# Write output to stdout
Write-Output "{ ""location"" : ""$location""}"