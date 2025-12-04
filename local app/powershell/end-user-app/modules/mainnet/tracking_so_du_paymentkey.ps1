# Cardano Wallet Balance Tracking Script
# Monitors payment key balance changes and sends notifications via Telegram & Email
# Requires: Koios API access, SMTP/Email setup

# Configuration
$Config = @{
    KoiosApiUrl = "https://api.koios.rest/api/v1"
    PaymentAddress = "addr1..."  # Your Cardano payment address
    StakeAddress = "stake1..."   # Your stake address
    TelegramBotToken = "YOUR_BOT_TOKEN"
    TelegramChatId = "YOUR_CHAT_ID"
    RecipientEmail = "your.email@example.com"
    HistoryFile = ".\wallet_tracking\balance_history.csv"
    OutputDir = ".\wallet_tracking"
}

# Ensure output directory exists
if (-not (Test-Path $Config.OutputDir)) {
    New-Item -ItemType Directory -Path $Config.OutputDir -Force | Out-Null
}

<#
.SYNOPSIS
Gets the current ADA balance from a payment address using Koios API
#>
function Get-ADOBalance {
    param([string]$PaymentAddress)
    
    try {
        $headers = @{
            "Accept" = "application/json"
            "Content-Type" = "application/json"
        }
        
        $body = @{
            "_payment_addresses" = @($PaymentAddress)
        } | ConvertTo-Json
        
        $response = Invoke-RestMethod `
            -Uri "$($Config.KoiosApiUrl)/address_info" `
            -Method Post `
            -Headers $headers `
            -Body $body `
            -ErrorAction Stop
        
        if ($response -and $response.Count -gt 0) {
            $balance = [math]::Round([double]$response[0].balance / 1e6, 2)
            return $balance
        }
        return $null
    }
    catch {
        Write-Error "Error fetching balance: $_"
        return $null
    }
}

<#
.SYNOPSIS
Gets account information and native assets from stake address
#>
function Get-AccountInfo {
    param([string]$StakeAddress)
    
    try {
        $headers = @{
            "Accept" = "application/json"
            "Content-Type" = "application/json"
        }
        
        $payload = @{
            "_stake_addresses" = @($StakeAddress)
        } | ConvertTo-Json
        
        # Get account info
        $response1 = Invoke-RestMethod `
            -Uri "$($Config.KoiosApiUrl)/account_info" `
            -Method Post `
            -Headers $headers `
            -Body $payload `
            -ErrorAction Stop
        
        # Get account assets
        $response2 = Invoke-RestMethod `
            -Uri "$($Config.KoiosApiUrl)/account_assets" `
            -Method Post `
            -Headers $headers `
            -Body $payload `
            -ErrorAction Stop
        
        $result = @{
            TotalBalance = if ($response1 -and $response1.Count -gt 0) { 
                [math]::Round([double]$response1[0].total_balance / 1e6, 2) 
            } else { 0 }
            Assets = @()
        }
        
        if ($response2) {
            foreach ($asset in $response2) {
                $quantity = [double]$asset.quantity
                $decimals = [int]$asset.decimals
                
                if ($decimals -gt 0) {
                    $quantity = $quantity * [math]::Pow(10, -$decimals)
                }
                
                $result.Assets += @{
                    Name = Convert-HexToASCII -HexString $asset.asset_name
                    Quantity = [math]::Round($quantity, 6)
                    Decimals = $decimals
                }
            }
        }
        
        return $result
    }
    catch {
        Write-Error "Error fetching account info: $_"
        return $null
    }
}

<#
.SYNOPSIS
Converts hex string to ASCII string
#>
function Convert-HexToASCII {
    param([string]$HexString)
    
    try {
        $bytes = @()
        for ($i = 0; $i -lt $HexString.Length; $i += 2) {
            $bytes += [byte]"0x$($HexString.Substring($i, 2))"
        }
        
        $asciiString = [System.Text.Encoding]::ASCII.GetString($bytes)
        return $asciiString
    }
    catch {
        Write-Warning "Error converting hex to ASCII: $_"
        return $HexString
    }
}

<#
.SYNOPSIS
Gets current date/time in formatted string
#>
function Get-FormattedTime {
    $now = Get-Date
    return $now.ToString("HH:mm:ss dd/MM/yyyy")
}

<#
.SYNOPSIS
Appends balance record to history file
#>
function Add-BalanceRecord {
    param(
        [double]$Balance,
        [string]$Timestamp = (Get-FormattedTime)
    )
    
    $record = "$Timestamp,$Balance"
    Add-Content -Path $Config.HistoryFile -Value $record -Encoding UTF8
}

<#
.SYNOPSIS
Gets the last recorded balance from history
#>
function Get-LastBalance {
    if (-not (Test-Path $Config.HistoryFile)) {
        return $null
    }
    
    $records = @(Get-Content -Path $Config.HistoryFile -Tail 1)
    if ($records.Count -gt 0) {
        $lastRecord = $records[-1]
        $parts = $lastRecord -split ','
        if ($parts.Count -ge 2) {
            return [double]$parts[1]
        }
    }
    return $null
}



<#
.SYNOPSIS
Monitors balance changes and sends notifications
#>
function Monitor-BalanceChanges {
    $currentBalance = Get-ADOBalance -PaymentAddress $Config.PaymentAddress
    
    if ($null -eq $currentBalance) {
        Write-Error "Failed to fetch current balance"
        return
    }
    
    Write-Host "Current Balance: $currentBalance ADA"
    
    $lastBalance = Get-LastBalance
    $timestamp = Get-FormattedTime
    
    Add-BalanceRecord -Balance $currentBalance -Timestamp $timestamp
    
    if ($null -ne $lastBalance) {
        $difference = $currentBalance - $lastBalance
        $changeMessage = ""
        
        if ($difference -gt 0) {
            $changeMessage = @"
<b>Ví của bạn vừa tăng thêm $difference ADA</b>`n`n
<b>Tổng số dư hiện tại là $currentBalance ADA</b>`n
Thời gian: $timestamp`n
"@
        }
        elseif ($difference -lt 0) {
            $absChange = [math]::Abs($difference)
            $changeMessage = @"
<b>Ví của bạn vừa giảm đi $absChange ADA</b>`n`n
<b>Tổng số dư hiện tại là $currentBalance ADA</b>`n
Thời gian: $timestamp`n
"@
        }
        
        if (-not [string]::IsNullOrWhiteSpace($changeMessage)) {
            return $changeMessage
        }
    }
}

<#
.SYNOPSIS
Displays account information with all native assets
#>
function Show-AccountInfo {
    $timestamp = Get-FormattedTime
    $accountInfo = Get-AccountInfo -StakeAddress $Config.StakeAddress
    
    if ($null -eq $accountInfo) {
        Write-Error "Failed to fetch account information"
        return
    }
    
    $message = "<b>Thông tin tài khoản của bạn</b>`n`n"
    $message += "- ADA : <b>$($accountInfo.TotalBalance)</b>`n"
    
    foreach ($asset in $accountInfo.Assets) {
        $message += "- $($asset.Name) : <b>$($asset.Quantity)</b>`n"
    }
    
    $message += "`nThời gian kiểm tra: $timestamp`n"
    $message += "Cảm ơn bạn đã luôn ủng hộ VIET pool`n"
    
    return $message
}

<#
.SYNOPSIS
Main execution function - Start wallet tracking
Usage: Start-WalletTracking -Action 'monitor'  # Monitor balance changes
       Start-WalletTracking -Action 'account'  # Show account info
       Start-WalletTracking -Action 'balance'  # Get current balance
#>
function Start-WalletTracking {
    param(
        [ValidateSet('balance', 'account', 'monitor')]
        [string]$Action = 'monitor'
    )
    
    switch ($Action) {
        'balance' {
            Write-Host "=== Fetching Balance ===" -ForegroundColor Cyan
            $balance = Get-ADOBalance -PaymentAddress $Config.PaymentAddress
            if ($balance) {
                Write-Host "Current Balance: $balance ADA" -ForegroundColor Green
            }
        }
        'account' {
            Write-Host "=== Account Information ===" -ForegroundColor Cyan
            Show-AccountInfo
        }
        'monitor' {
            Write-Host "=== Monitoring Balance Changes ===" -ForegroundColor Cyan
            Monitor-BalanceChanges
        }
    }
}

# Export functions
Export-ModuleMember -Function @(
    'Get-ADOBalance',
    'Get-AccountInfo',
    'Convert-HexToASCII',
    'Get-FormattedTime',
    'Add-BalanceRecord',
    'Get-LastBalance',
    'Monitor-BalanceChanges',
    'Show-AccountInfo',
    'Start-WalletTracking'
)
      message += "Thời gian kiểm tra thực tế: " + currentTime + "\n";

      sendTelegramMessageToGroup(telegramBotToken, telegramChatId, message)
    } else if (result < 0) {
      message += "\n" ;
      message += "<b> Ví của bạn vừa giảm đi " + result + " ADA  </b>\n";
      message += "\n" ;
      message += "<b> Tổng số dư hiện tại là " + currentValue + " ADA </b>\n";
      message += " Kiểm tra giao dịch ở đây nhé" + check + "\n";
      message += "Thời gian kiểm tra thực tế: " + currentTime + "\n";
      sendTelegramMessageToGroup(telegramBotToken, telegramChatId, message)
    }
  }
  var emailSubject = "Thông tin ví của sếp";
if (message.trim() !== "") {
  MailApp.sendEmail({
    to: recipientEmail,
    subject: emailSubject,
    htmlBody: message
  });

  // Print the final message to the console
  console.log("Comparison completed:\n" + message);
} else {
  console.log("Message is empty. Not sending the email.");
}
}


function sendTelegramMessageToGroup(telegramBotToken, telegramChatId, message) {
  if (message.trim() !== "") {  // Check if the message is not empty or just whitespace
 

    var telegramApiUrl = "https://api.telegram.org/bot" + telegramBotToken + "/sendMessage";

    var payload = {
      "chat_id": telegramChatId,
      "text": message,
      "parse_mode": "HTML"
    };

    // Make the HTTP request to send the message
    var response = UrlFetchApp.fetch(telegramApiUrl, {
      "method": "post",
      "contentType": "application/json",
      "payload": JSON.stringify(payload)
    });

    // Log the response to check for errors
    console.log(response.getContentText());
  } else {
    console.log("Message is empty. Not sending to Telegram.");
  }
}

// Lấy dữ liệu từ sheet
var sheetData = getDataFromSheet();

// So sánh và gửi thông báo nếu có thay đổi
compareAndPrintResults(sheetData);

function account_info(){

var url1 = 'https://api.koios.rest/api/v1/account_info';
var url2 = 'https://api.koios.rest/api/v1/account_assets';

var headers = {
  'Accept': 'application/json',
  'Content-Type': 'application/json'
};

var payload = {
  '_stake_addresses': ["stakekey của bạn"]
};

var options = {
  'method': 'post',
  'headers': headers,
  'payload': JSON.stringify(payload)
};

var responseurl1 = UrlFetchApp.fetch(url1, options);
var responseurl2 = UrlFetchApp.fetch(url2, options);

  // Chuyển đổi phản hồi từ API sang đối tượng JSON
var data1 = JSON.parse(responseurl1.getContentText())[0];
var data2 = JSON.parse(responseurl2.getContentText());
  // Lấy kết quả stake_address từ phản hồi API
var adabal = Math.round(parseFloat(data1.total_balance) * 1e-6);
var asset_info = [];
for (var i = 0; i < data2.length; i++) {
  var assetName = data2[i].asset_name;
  var quantity = data2[i].quantity;
  var decimal = data2[i].decimals;

  // Chuyển đổi assetName thành chuỗi ASCII
  var asciiAssetName = convertHexToASCII(assetName);

  // Thêm vào mảng values để sau đó ghi vào Google Sheets
  asset_info.push([asciiAssetName, quantity, decimal]);
}

  // Lọc và trả kết quả từ bảng "tonghop"
var spreadsheet1 = SpreadsheetApp.openById(spreadsheetId);

  // Chọn sheet (nếu có nhiều sheet)
var sheet1 = spreadsheet1.getSheetByName("live"); // Thay "Sheet1" bằng tên của sheet trong bảng tính của bạn
sheet1.clear();
sheet1.getRange(1, 1).setValue("ADA");
sheet1.getRange(2, 1).setValue(adabal);

if (asset_info.length > 0) {
  // Ghi asset_name vào hàng đầu tiên, bắt đầu từ cột 2
  for (var i = 0; i < asset_info.length; i++) {
    sheet1.getRange(1, i + 2).setValue(asset_info[i][0]);
  }

  // Ghi quantity vào hàng thứ hai, bắt đầu từ cột 2
  for (var i = 0; i < asset_info.length; i++) {
    sheet1.getRange(2, i + 2).setValue(asset_info[i][1]);
  }
  // Ghi decimals vào hàng thứ ba, bắt đầu từ cột 2
  for (var i = 0; i < asset_info.length; i++) {
    sheet1.getRange(3, i + 2).setValue(asset_info[i][2]);
  }
  Logger.log(adabal);
} else {
  Logger.log("Không có dữ liệu asset_info để ghi vào sheet.");
}
  var dataRange = sheet1.getDataRange();
  var values = dataRange.getValues();
  
  // Check if there is any data
  if (values.length > 1) {
    var message = "<b>Thông tin tài khoản của bạn</b>\n\n";
    var assetNameColumn = values[0];
    var quantityColumn = values[1];
    var decimalColumn = values[2];
    var message1 ="";
    // Iterate through each item in the column
    for (var i = 0; i < assetNameColumn.length; i++) {
      var assetName = assetNameColumn[i];
      var quantity = quantityColumn[i];
      var decimal = decimalColumn[i]
      if (decimal > 0) {
          quantity = quantity * Math.pow(10, -decimal);
        }

      // Append assetName and quantity to the message as a list item
      message1 += `-  ${assetName} : <b> ${quantity} </b>\n`;
    }
      message1 += `\nThời gian kiểm tra thực tế: ` + currentTime + '\n';
      message1 += `Cảm ơn sếp đã luôn ủng hộ VIET pool\n `;
     
      
    
    var finalmess = message + message1;

    // Send the constructed message
    sendTelegramMessageToGroup(telegramBotToken, telegramChatId, finalmess);
    var emailSubject = "Thông tin ví sếp";
    if (message.trim() !== "") {
    MailApp.sendEmail({
      to: recipientEmail,
      subject: emailSubject,
      htmlBody: finalmess
    });
    }
    }else {
    // Inform the user if there is no data
    send("Không có thông tin về ví.", telegramChatId);
  }

}

function convertHexToASCII(hexString) {
  try {
    // Convert hex to bytes
    var bytes = [];
    for (var i = 0; i < hexString.length; i += 2) {
      bytes.push(parseInt(hexString.substr(i, 2), 16));
    }

    // Create a blob from the bytes
    var blob = Utilities.newBlob(bytes);

    // Convert the blob to ASCII string
    var asciiString = blob.getDataAsString();

    Logger.log("Converted ASCII String: " + asciiString);
    return asciiString;
  } catch (error) {
    Logger.log("Error converting hex to ASCII: " + error);
    return null; // Return null if there's an error
  }
  }
function getCurrentTime() {
  var currentTime = new Date();
  var hours = currentTime.getHours();
  var minutes = currentTime.getMinutes();
  var seconds = currentTime.getSeconds();
  var day = currentTime.getDate();
  var month = currentTime.getMonth() + 1; // Tháng bắt đầu từ 0
  var year = currentTime.getFullYear();

  // Đảm bảo rằng các giá trị nhỏ hơn 10 được hiển thị với hai chữ số
  if (hours < 10) {
    hours = '0' + hours;
  }
  if (minutes < 10) {
    minutes = '0' + minutes;
  }
  if (seconds < 10) {
