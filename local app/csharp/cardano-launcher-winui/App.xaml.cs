// ============================================
// CARDANO COMMUNITY SUITE - LAUNCHER
// ============================================
// Main application entry point and initialization

using Microsoft.UI.Xaml;

namespace CardanoLauncher
{
    public partial class App : Application
    {
        public App()
        {
            this.InitializeComponent();
        }

        protected override void OnLaunched(LaunchActivatedEventArgs args)
        {
            m_window = new MainWindow();
            m_window.Activate();
        }

        private Window? m_window;
    }
}
