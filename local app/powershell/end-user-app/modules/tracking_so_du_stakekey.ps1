## code check 1 lần số dư toàn bộ tài sản trong ví.
## code check 1 lần toàn bộ tài sản có trong 1 địa chỉ thì đổi URL khác
## Thực thi qua power-shell windows
$url1 = 'https://api.koios.rest/api/v1/account_info'
$url2 = 'https://api.koios.rest/api/v1/account_assets'
$headers = @{
    'Accept' = 'application/json'
    'Content-Type' = 'application/json'
}
$payload = @{
    '_stake_addresses' = @("stake1....") ## thay vào bằng địa chỉ stake của bạn
}
$data1 = Invoke-RestMethod -Uri $url1 -Method Post -Headers $headers -Body ($payload | ConvertTo-Json)
$data2 = Invoke-RestMethod -Uri $url2 -Method Post -Headers $headers -Body ($payload | ConvertTo-Json)
$adabal = [math]::Round([float]$data1[0].total_balance * 1e-6, 2)
$asset_info = @()
$checked_time1 = Get-Date -Format 'HH:mm dd-MM-yyyy'
foreach ($item in $data2) {
    $assetName = $item.asset_name
    $assetNameASCII = ""
    for ($i = 0; $i -lt $assetName.Length; $i += 2) {
        $assetNameASCII += [System.Convert]::ToChar([System.Convert]::ToUInt32($assetName.Substring($i, 2), 16))
    }
    $quantity = [float]$item.quantity
    $decimal = $item.decimals
    if ($decimal -gt 0) {
        $quantity = $quantity * [math]::Pow(10, -$decimal)
    }
    $asset_info += ,@($assetNameASCII, $quantity)
}
if ($asset_info) {
    $message = "Thông tin sếp cần đây nhé 😄`n`nSố dư ADA: $adabal`₳`n`nDanh sách Token:`n`n"
    $message += ($asset_info | ForEach-Object { "$($_[0]) - $($_[1]):," }) -join "`n"
    $message += "`n`nChecked time $checked_time1`n`nHãy stake vào VIET pool nhé sếp 🙇 /pool"
    Write-Output "$message"
} else {
    $message1 = "Thông tin sếp cần đây nhé 😄`n`nSố dư ADA: $adabal`₳`n`nToken: không có`n`nChecked time $checked_time1`n`nHãy stake vào VIET pool nhé sếp 🙇 /pool"
    Write-Output "$message1" ## sếp ấn Enter đi nhé
}
