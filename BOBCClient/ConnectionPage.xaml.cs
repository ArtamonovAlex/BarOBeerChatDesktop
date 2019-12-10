using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
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

namespace BOBCClient
{
    /// <summary>
    /// Логика взаимодействия для ConnectionPage.xaml
    /// </summary>
    public partial class ConnectionPage : Page
    {

        public MainWindow mainWindow;

        private string name;
        public ConnectionPage(MainWindow _mainWindow, string _name)
        {
            InitializeComponent();

            mainWindow = _mainWindow;
            name = _name;
        }

        private async void ConnectButton_Click(object sender, RoutedEventArgs e)
        {
            bool debugModeOn = (bool)DebugMode.IsChecked;
            string chatroomId = ChatroomBox.Text;
            HttpClient client = mainWindow.httpClient;


            int externalPort = BobcDesktopUtils.GetAvaliablePort(10000, 25000);

            var responseString = await client.GetStringAsync($"http://localhost:9090/connect/{chatroomId}/{externalPort}");


            dynamic reply = BobcDesktopUtils.FromJson(responseString);
            if (reply.status == "ok")
            {
                string RemoteUsers = BobcDesktopUtils.ToJson(reply.user_list);
                mainWindow.OpenPage(new ChatPage(mainWindow, name, RemoteUsers, debugModeOn, externalPort, chatroomId));
            }
        }
    }
}
