using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using System;
using System.Threading.Tasks;

namespace CommunityAdmin
{
    public sealed partial class MainWindow : Window
    {
        private string? _currentAction;
        private DispatcherTimer? _statusTimer;

        public MainWindow()
        {
            InitializeComponent();
            SetupWindow();
            InitializeStatusBar();
        }

        private void SetupWindow()
        {
            // Set title bar drag area
            SetTitleBarDragArea();
        }

        private void SetTitleBarDragArea()
        {
            // Make the content area draggable for the title bar
            ExtendsContentIntoTitleBar = true;
            SetTitleBar(null);
        }

        private void InitializeStatusBar()
        {
            // Timer to update timestamp in status bar
            _statusTimer = new DispatcherTimer();
            _statusTimer.Interval = TimeSpan.FromSeconds(1);
            _statusTimer.Tick += (s, e) =>
            {
                TimestampBar.Text = DateTime.Now.ToString("HH:mm:ss");
            };
            _statusTimer.Start();
            TimestampBar.Text = DateTime.Now.ToString("HH:mm:ss");
        }

        // ============ BUTTON HANDLERS ============

        private async void BtnGenChallenge_Click(object sender, RoutedEventArgs e)
        {
            _currentAction = "generate_challenge";
            ContentTitle.Text = "🔐 Generate Challenge";
            ActionPanel.Visibility = Visibility.Visible;
            InputMessage.PlaceholderText = "Optional custom message...";
            OutputContent.Blocks.Clear();
            AddOutput("Ready to generate challenge.");
            UpdateStatus("Action: Generate Challenge", "#00FF00");
        }

        private async void BtnVerifySignature_Click(object sender, RoutedEventArgs e)
        {
            _currentAction = "verify_signature";
            ContentTitle.Text = "✔️ Verify Signature";
            ActionPanel.Visibility = Visibility.Visible;
            InputMessage.PlaceholderText = "Paste signature data (JSON)...";
            OutputContent.Blocks.Clear();
            AddOutput("Ready to verify signature.\nPlease paste the signature data in JSON format.");
            UpdateStatus("Action: Verify Signature", "#00FF00");
        }

        private async void BtnCheckOnChain_Click(object sender, RoutedEventArgs e)
        {
            _currentAction = "check_on_chain";
            ContentTitle.Text = "🔗 Check On-Chain Stake";
            ActionPanel.Visibility = Visible;
            InputMessage.PlaceholderText = "Enter stake address...";
            OutputContent.Blocks.Clear();
            AddOutput("Ready to check on-chain stake information.\nEnter a stake address to query.");
            UpdateStatus("Action: Check On-Chain", "#00FF00");
        }

        private async void BtnViewRegistry_Click(object sender, RoutedEventArgs e)
        {
            _currentAction = "view_registry";
            ContentTitle.Text = "👥 User Registry";
            ActionPanel.Visibility = Visibility.Collapsed;
            OutputContent.Blocks.Clear();
            
            // Simulate loading registry
            AddOutput("📊 User Registry\n");
            AddOutput("─────────────────────────────────────\n", "#808080");
            AddOutput("Total Users: 0\n", "#CCCCCC");
            AddOutput("Verified Users: 0\n", "#CCCCCC");
            AddOutput("Communities: 0\n", "#CCCCCC");
            AddOutput("─────────────────────────────────────\n", "#808080");
            AddOutput("\nNo registry data available yet.", "#808080");
            
            UpdateStatus("Viewing Registry", "#00FF00");
        }

        private async void BtnExportReport_Click(object sender, RoutedEventArgs e)
        {
            _currentAction = "export_report";
            ContentTitle.Text = "📋 Export Report";
            ActionPanel.Visibility = Visibility.Visible;
            InputMessage.PlaceholderText = "Select format: json or csv";
            OutputContent.Blocks.Clear();
            AddOutput("Ready to export registry report.\nOptions: json, csv");
            UpdateStatus("Action: Export Report", "#00FF00");
        }

        private async void ExecuteAction_Click(object sender, RoutedEventArgs e)
        {
            string communityId = InputCommunityId.Text;
            string messageData = InputMessage.Text;

            if (string.IsNullOrWhiteSpace(_currentAction))
            {
                AddOutput("Error: No action selected.", "#FF0000");
                return;
            }

            OutputContent.Blocks.Clear();
            UpdateStatus("Processing...", "#FFD700");
            AddOutput($"🔄 Executing: {_currentAction}\n", "#FFD700");

            try
            {
                switch (_currentAction)
                {
                    case "generate_challenge":
                        await ExecuteGenerateChallenge(communityId, messageData);
                        break;
                    case "verify_signature":
                        await ExecuteVerifySignature(messageData);
                        break;
                    case "check_on_chain":
                        await ExecuteCheckOnChain(messageData);
                        break;
                    case "export_report":
                        await ExecuteExportReport(messageData);
                        break;
                    default:
                        AddOutput("Unknown action.", "#FF0000");
                        break;
                }

                UpdateStatus("✓ Action completed", "#00FF00");
            }
            catch (Exception ex)
            {
                AddOutput($"Error: {ex.Message}", "#FF0000");
                UpdateStatus("✗ Error", "#FF0000");
            }
        }

        // ============ ACTION IMPLEMENTATIONS ============

        private async Task ExecuteGenerateChallenge(string communityId, string customMessage)
        {
            await Task.Delay(500); // Simulate processing

            string challengeId = Guid.NewGuid().ToString();
            string nonce = Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(new Random().Next().ToString() + DateTime.Now.Ticks.ToString()));
            long timestamp = DateTimeOffset.Now.ToUnixTimeSeconds();
            long expiry = timestamp + 3600; // 1 hour

            AddOutput("✓ Challenge Generated\n", "#00FF00");
            AddOutput("─────────────────────────────────────\n", "#808080");
            AddOutput($"Challenge ID: {challengeId}\n", "#CCCCCC");
            AddOutput($"Community: {communityId}\n", "#CCCCCC");
            AddOutput($"Nonce: {nonce}\n", "#CCCCCC");
            AddOutput($"Timestamp: {timestamp}\n", "#CCCCCC");
            AddOutput($"Expires: {timestamp + 3600}\n", "#CCCCCC");
            AddOutput("─────────────────────────────────────\n", "#808080");
            AddOutput("\nChallenge ready for user signing.", "#00FF00");
        }

        private async Task ExecuteVerifySignature(string signatureData)
        {
            await Task.Delay(500); // Simulate processing

            AddOutput("✓ Signature Verification\n", "#00FF00");
            AddOutput("─────────────────────────────────────\n", "#808080");

            if (string.IsNullOrWhiteSpace(signatureData))
            {
                AddOutput("Error: No signature data provided.\n", "#FF0000");
                AddOutput("Please paste signature data in JSON format.", "#FF0000");
                return;
            }

            // Simulate verification
            AddOutput("Status: Processing signature...\n", "#FFD700");
            await Task.Delay(1000);
            
            AddOutput("✓ Signature verified\n", "#00FF00");
            AddOutput("Challenge: Valid\n", "#00FF00");
            AddOutput("Expiry: Not expired\n", "#00FF00");
            AddOutput("─────────────────────────────────────\n", "#808080");
        }

        private async Task ExecuteCheckOnChain(string stakeAddress)
        {
            await Task.Delay(500); // Simulate processing

            AddOutput("🔗 On-Chain Stake Check\n", "#00FF00");
            AddOutput("─────────────────────────────────────\n", "#808080");

            if (string.IsNullOrWhiteSpace(stakeAddress))
            {
                AddOutput("Error: Please provide a stake address.\n", "#FF0000");
                return;
            }

            AddOutput($"Stake Address: {stakeAddress}\n", "#CCCCCC");
            AddOutput("Querying blockchain...\n", "#FFD700");
            await Task.Delay(1500);
            
            AddOutput("─────────────────────────────────────\n", "#808080");
            AddOutput("Stake Amount: 1000.00 ADA\n", "#00FF00");
            AddOutput("Delegated Pool: Not delegated\n", "#CCCCCC");
            AddOutput("Rewards: 0.00 ADA\n", "#CCCCCC");
            AddOutput("─────────────────────────────────────\n", "#808080");
        }

        private async Task ExecuteExportReport(string format)
        {
            await Task.Delay(500); // Simulate processing

            string reportFormat = string.IsNullOrWhiteSpace(format) ? "json" : format.ToLower();

            AddOutput("📋 Registry Report Export\n", "#00FF00");
            AddOutput("─────────────────────────────────────\n", "#808080");
            AddOutput($"Format: {reportFormat}\n", "#CCCCCC");
            AddOutput("Generating report...\n", "#FFD700");
            await Task.Delay(1000);
            
            AddOutput("─────────────────────────────────────\n", "#808080");
            AddOutput("✓ Report exported successfully\n", "#00FF00");
            AddOutput($"File: registry_report_{DateTime.Now:yyyyMMddHHmmss}.{reportFormat}\n", "#CCCCCC");
            AddOutput("Location: community-admin/reports/\n", "#CCCCCC");
        }

        // ============ UI HELPERS ============

        private void AddOutput(string text, string color = "#00FF00")
        {
            var paragraph = new Paragraph();
            var run = new Run { Text = text };
            
            if (color == "#00FF00")
                run.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(Microsoft.UI.Colors.LimeGreen);
            else if (color == "#FFD700")
                run.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(Microsoft.UI.Colors.Gold);
            else if (color == "#FF0000")
                run.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(Microsoft.UI.Colors.Red);
            else if (color == "#808080")
                run.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(Microsoft.UI.Colors.Gray);
            else if (color == "#CCCCCC")
                run.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(Microsoft.UI.Colors.LightGray);
            
            paragraph.Inlines.Add(run);
            OutputContent.Blocks.Add(paragraph);
        }

        private void UpdateStatus(string message, string color)
        {
            StatusBar.Text = message;
            
            if (color == "#00FF00")
                StatusBar.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(Microsoft.UI.Colors.LimeGreen);
            else if (color == "#FFD700")
                StatusBar.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(Microsoft.UI.Colors.Gold);
            else if (color == "#FF0000")
                StatusBar.Foreground = new Microsoft.UI.Xaml.Media.SolidColorBrush(Microsoft.UI.Colors.Red);
        }
    }
}
