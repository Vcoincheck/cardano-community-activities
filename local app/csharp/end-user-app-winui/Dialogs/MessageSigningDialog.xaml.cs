using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace CardanoEndUserTool.Dialogs;

public sealed partial class MessageSigningDialog : ContentDialog
{
    public string? SignMessage { get; private set; }
    public string? SignMethod { get; private set; }

    public MessageSigningDialog()
    {
        this.InitializeComponent();
        this.Title = "✍️ Sign Message";
        this.PrimaryButtonText = "Sign Offline";
        this.SecondaryButtonText = "Sign via Wallet";
        this.CloseButtonText = "Cancel";
    }

    private void ContentDialog_PrimaryButtonClick(ContentDialog sender, ContentDialogButtonClickEventArgs args)
    {
        SignMessage = MessageTextBox.Text;
        SignMethod = "offline";
    }

    private void ContentDialog_SecondaryButtonClick(ContentDialog sender, ContentDialogButtonClickEventArgs args)
    {
        SignMessage = MessageTextBox.Text;
        SignMethod = "wallet";
    }
}
