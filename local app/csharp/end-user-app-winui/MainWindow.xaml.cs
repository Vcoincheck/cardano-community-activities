using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using System;

namespace CardanoEndUserTool;

public sealed partial class MainWindow : Window
{
    public MainWindow()
    {
        this.InitializeComponent();
        SetTitleBarDragArea();
    }

    private void SetTitleBarDragArea()
    {
        // Allow dragging from title bar
        var nonClientInputSite = this.AppTitleBar;
        if (nonClientInputSite is not null)
        {
            InputNonClientPointerSource nonClientInputSrc = InputNonClientPointerSource.GetForWindowId(this.AppWindow.Id);
            nonClientInputSrc.SetRegionRects(NonClientRegionKind.Passthrough, new[] { new Windows.Graphics.RectInt32(0, 0, (int)nonClientInputSite.ActualWidth, (int)nonClientInputSite.ActualHeight) });
        }
    }

    private void BtnKeygen_Click(object sender, RoutedEventArgs e)
    {
        UpdateContent("Generate Keypair", @"🔑 Keypair Generation

Generating keypair...
✓ Status: Ready for implementation

Features:
• BIP39 mnemonic generation
• Derivation path support (HD wallets)
• Multiple address generation
• Cardano network compatibility

Click button to start the process.");
    }

    private void BtnSign_Click(object sender, RoutedEventArgs e)
    {
        UpdateContent("Sign Message", @"✍️ Message Signing

Choose signing method:
1. Sign Offline - Use local private key
2. Sign via Wallet - Browser wallet extension

Features:
• Support for Yoroi, Nami, Eternl, Lace
• Ed25519 signatures
• Message hex encoding
• Signature verification

Status: Ready for implementation");
    }

    private void BtnExport_Click(object sender, RoutedEventArgs e)
    {
        UpdateContent("Export Wallet", @"💾 Wallet Export

Export wallet data for backup/transfer:

Features:
• BIP39 mnemonic export
• Private key export (encrypted)
• Address export
• JSON format support
• Password protection

Status: Ready for implementation");
    }

    private void BtnVerify_Click(object sender, RoutedEventArgs e)
    {
        UpdateContent("Verify Signature", @"✓ Signature Verification

Verify message signatures:

Features:
• Ed25519 signature verification
• Public key validation
• Message hash checking
• On-chain verification support

Status: Ready for implementation");
    }

    private void UpdateContent(string title, string content)
    {
        ContentTitle.Text = title;
        OutputText.Text = content;
        StatusText.Text = $"Loaded: {title}";
    }
}
