<#
.SYNOPSIS
The scripts downloads the latest selected report from Workspace One Intelligence Reports.
.DESCRIPTION
The scripts downloads the latest selected report from Workspace One Intelligence Reports. You have to modify the variables set in the 'Variables' region: you can get the $authEndpoint and $authHeader data from the WS1 Intelligence service account, while you have to set $reportingUri and $reportingDownloadUri according to your tenant's region. You can easily get $reportGUID from the desired report webpage URL in Intelligence, it's the GUID after "/list/" and before "/overview". Finally, set the $reportName and $downloadFolder for your CSV report.
.EXAMPLE
Get-WS1Report.ps1 
Running the script will download your report in CSV format in the specified location, the report generation date will be included in the name of the file.
.NOTES
AUTHOR: Federico Lillacci - https://github.com/tsmagnum
#>

#region Variables - YOU HAVE TO MODIFY THIS SECTION!

#You can get authentication info creating a service account in Intelligence ( https://techzone.vmware.com/getting-started-workspace-one-intelligence-apis-workspace-one-operational-tutorial#_1107619 ). 

#Set the auth endpoint according to your tenant's region
$authEndpoint = 'https://auth.eu1.data.vmwservices.com/oauth/token?grant_type=client_credentials'

#The authorization header is the clientId:clientSecret in Base64 format.
$authHeader = @{
    'Content-Type' = 'application/json'
    'Authorization' = 'Basic pasteYourClientId:ClientSecretInBase64FormatHere'
}
#There's no need to modify the body
$body = @{
    "offset" = 0;
    "page_size" = 100;
}
#Choose a name for your report
$reportName = "Asset_Inventory_"
#Where to download the report, select an already existing folder
$downloadFolder = "C:\WS1\Reports\"

#You can easily get $reportGUID from the desired report webpage URL in Intelligence, it's the GUID after "/list/" and before "/overview"
#THIS REPORT HAS TO BE SHARED WITH YOUR SERVICE ACCOUNT IN INTELLIGENCE
$reportGUID = "a51cac58-b7db-48b4-82f5-c46ed82fc89e"

#Set these variables according to your tenant's region
$reportingUri = "https://api.eu1.data.vmwservices.com/v1/reports/"
$reportingDownloadUri = "https://api.eu1.data.vmwservices.com/v1/reports/tracking/"
#endregion

###### DO NOT MODIFY ANTYTHING BELOW THIS LINE ######
#####################################################

#Obtaining the access token
$accessToken = Invoke-RestMethod -Method Post -Uri $authEndpoint -Headers $authHeader -ContentType 'application/x-www-form-urlencoded'

#Building the authorization headers
$headers = @{}
$headers.Add("Authorization","$($accessToken.token_type) "+" "+"$($accessToken.access_token)")

#Getting the report download id
$dataUri = $reportingUri + $reportGUID + "/downloads/search"

$data = Invoke-RestMethod -Method Post -Headers $headers -Uri $dataUri -Body ($body | ConvertTo-Json) -ContentType "application/json"

$lastReport =  $data.data.results.GetValue(0)
$reportId = $lastReport.id

#Getting the report generation date and creating the download destination
$reportDate = $lastReport.created_at.Substring(0,16).Replace(':','-').Replace('T','_')
$reportFile = $downloadFolder + $reportName + $reportDate + ".csv"

#Creating the report download Uri using the reportId
$downloadUri = $reportingDownloadUri + $reportId + '/download'

#Downloading the report in the specified location
Invoke-RestMethod -Method Get -Headers $headers -Uri $downloadUri -OutFile $reportFile