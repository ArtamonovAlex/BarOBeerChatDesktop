using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.IO;

namespace BOBCClient
{
    /// <summary>
    /// Логика взаимодействия для LoginPage.xaml
    /// </summary>
    public partial class StartNodePage : Page
    {

        public MainWindow mainWindow;
        public StartNodePage(MainWindow _mainWindow)
        {
            InitializeComponent();

            mainWindow = _mainWindow;
        }

        private void StartButton_Click(object sender, RoutedEventArgs e)
        {
            string nodeName = NodeNameBox.Text;
            int.TryParse(InternalPortBox.Text, out int internalPort);
            int.TryParse(ExternalPortBox.Text, out int externalPort);
            string remotePorts = RemotePortBox.Text;
            bool debugMode = (bool)DebugMode.IsChecked;
            mainWindow.OpenPage(new ChatPage(mainWindow, nodeName, internalPort, externalPort, remotePorts, debugMode));
        }
    }
}
