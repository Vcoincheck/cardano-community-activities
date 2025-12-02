// ============================================
// CARDANO COMMUNITY SUITE - LAUNCHER WINDOW
// ============================================
// Main launcher interface with buttons to launch child applications

using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using System;
using System.Diagnostics;
using System.IO;

namespace CardanoLauncher
{
    public sealed partial class MainWindow : Window
    {
        public MainWindow()
        {
            this.InitializeComponent();
            this.ExtendsContentIntoTitleBar = true;
        }

        /// <summary>
        /// Launch End-User Tools application
        /// </summary>
        private void BtnEndUser_Click(object sender, RoutedEventArgs e)
        {
            LaunchApplication("End-User Tools", "CardanoEndUserTool.exe");
        }

        /// <summary>
        /// Launch Admin Dashboard application
        /// </summary>
        private void BtnAdmin_Click(object sender, RoutedEventArgs e)
        {
            LaunchApplication("Admin Dashboard", "CardanoCommunityAdmin.exe");
        }

        /// <summary>
        /// Show documentation information
        /// </summary>
        private void BtnDocs_Click(object sender, RoutedEventArgs e)
        {
            ShowDocumentation();
        }

        /// <summary>
        /// Generic application launcher
        /// </summary>
        private void LaunchApplication(string appName, string exeName)
        {
            try
            {
                // Try to find application in sibling directories
                string launcherPath = AppDomain.CurrentDomain.BaseDirectory;
                string parentPath = Directory.GetParent(launcherPath)?.FullName ?? "";

                string[] possiblePaths = new[]
                {
                    Path.Combine(parentPath, exeName),
                    Path.Combine(launcherPath, exeName),
                    Path.Combine(parentPath, "end-user-app-winui", "bin", "Release", "net8.0-windows10.0.22621.0", exeName),
                    Path.Combine(parentPath, "end-user-app-winui", "bin", "Debug", "net8.0-windows10.0.22621.0", exeName),
                    Path.Combine(parentPath, "community-admin-winui", "bin", "Release", "net8.0-windows10.0.22621.0", exeName),
                    Path.Combine(parentPath, "community-admin-winui", "bin", "Debug", "net8.0-windows10.0.22621.0", exeName),
                };

                string? foundPath = null;
                foreach (var path in possiblePaths)
                {
                    if (File.Exists(path))
                    {
                        foundPath = path;
                        break;
                    }
                }

                if (foundPath != null)
                {
                    ProcessStartInfo psi = new ProcessStartInfo
                    {
                        FileName = foundPath,
                        UseShellExecute = true,
                        CreateNoWindow = false
                    };
                    Process.Start(psi);
                }
                else
                {
                    ShowError($"Could not find {appName}", 
                        $"The {appName} executable ({exeName}) was not found. " +
                        $"Make sure it has been built successfully.\n\n" +
                        $"Looked in: {string.Join("\n", possiblePaths)}");
                }
            }
            catch (Exception ex)
            {
                ShowError("Launch Error", 
                    $"Failed to launch {appName}:\n\n{ex.Message}");
            }
        }

        /// <summary>
        /// Display documentation information
        /// </summary>
        private void ShowDocumentation()
        {
            string docContent = @"📖 CARDANO COMMUNITY SUITE - DOCUMENTATION

🔹 SECURITY FEATURES
  • Offline Signing - Private keys never transmitted
  • Challenge-Response Authentication - Secure user verification
  • Ed25519 Signature Verification - Industry-standard cryptography
  • On-Chain Stake Verification - Blockchain-based authority checks
  • Community-Based Governance - Democratic decision-making

🔹 END-USER TOOLS FEATURES
  ✓ Generate Cardano keypairs securely
  ✓ Sign messages offline with full control
  ✓ Export wallet data in multiple formats
  ✓ Verify signatures locally without network
  ✓ Support for Mesh SDK wallet integrations

🔹 ADMIN DASHBOARD FEATURES
  ✓ Generate time-limited signing challenges
  ✓ Verify user signatures against public keys
  ✓ Check on-chain stake of Cardano addresses
  ✓ Manage user registry with JSON/CSV export
  ✓ Generate reports for auditing

🔹 ARCHITECTURE
  • Service-Based Design - Clean separation of concerns
  • Async/Await Throughout - Non-blocking operations
  • Type Safety - Nullable reference types enabled
  • Error Handling - Comprehensive exception management
  • Modern UI - WinUI 3 with Fluent Design System

🔹 FOR MORE INFORMATION
  Visit: cardano-community-suite/docs/
  - API_SPEC.md - Complete API documentation
  - SECURITY_MODEL.md - Security design details
  - USER_FLOW_ADMIN.md - Administrator workflows
  - USER_FLOW_ENDUSER.md - End-user workflows

🔹 PROJECT STRUCTURE
  /cardano-launcher-winui/     ← This application (Main entry point)
  /end-user-app-winui/         ← End-user tools (Keypair generation, signing)
  /community-admin-winui/      ← Admin dashboard (Verification, registry)
  /core-crypto/                ← Cryptographic utilities
  /docs/                        ← Full documentation";

            ShowInformationDialog("Documentation & Resources", docContent);
        }

        /// <summary>
        /// Show error dialog
        /// </summary>
        private void ShowError(string title, string message)
        {
            ShowDialog(title, message, "❌");
        }

        /// <summary>
        /// Show information dialog
        /// </summary>
        private void ShowInformationDialog(string title, string message)
        {
            ShowDialog(title, message, "ℹ️");
        }

        /// <summary>
        /// Generic dialog display
        /// </summary>
        private async void ShowDialog(string title, string message, string icon)
        {
            ContentDialog dialog = new ContentDialog
            {
                Title = icon + " " + title,
                Content = new TextBlock
                {
                    Text = message,
                    TextWrapping = TextWrapping.Wrap,
                    FontSize = 14,
                    IsTextSelectionEnabled = true
                },
                CloseButtonText = "Close",
                XamlRoot = this.Content.XamlRoot
            };

            await dialog.ShowAsync();
        }
    }
}
