using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
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
using WebSocketSharp;

namespace BOBCClient
{
    /// <summary>
    /// Логика взаимодействия для ChatPage.xaml
    /// </summary>
    public partial class ChatPage : Page
    {

        private ObservableCollection<string> messages;

        public MainWindow mainWindow;

        private WebSocket ws;

        private int internalPort;

        private Process erlNode;
        public ChatPage(MainWindow _mainWindow, string nodeName, int _internalPort, int externalPort, string remotePort, bool debugModeOn)
        {
            InitializeComponent();

            string location = System.Reflection.Assembly.GetEntryAssembly().Location;
            string executableDirectory = System.IO.Path.GetDirectoryName(location);
            string relativePath = @"..\..\..\bobc";
            string fullPath = System.IO.Path.GetFullPath(relativePath);


            erlNode = new Process();
            erlNode.StartInfo.WorkingDirectory = string.Format(fullPath);
            erlNode.StartInfo.FileName = "cmd.exe";
            erlNode.StartInfo.CreateNoWindow = !debugModeOn;
            erlNode.StartInfo.RedirectStandardInput = true;
            erlNode.StartInfo.UseShellExecute = false;
            erlNode.Start();
            erlNode.StandardInput.WriteLine($"start.bat {nodeName} {_internalPort} {externalPort} \"{remotePort}\"");


            mainWindow = _mainWindow;

            messages = new ObservableCollection<string> { };

            MessagesHolder.ItemsSource = messages;

            internalPort = _internalPort;

            ws = new WebSocket($"ws://localhost:{internalPort}/websocket");
            ws.OnMessage += Ws_OnMessage;
            ws.OnClose += Ws_OnClose;
            ws.Connect();

        }

        public ChatPage(MainWindow _mainWindow, string name, string remoteUsers, bool debugModeOn)
        {
            InitializeComponent();

            string location = System.Reflection.Assembly.GetEntryAssembly().Location;
            string executableDirectory = System.IO.Path.GetDirectoryName(location);
            string relativePath = @"..\..\..\bobc";
            string fullPath = System.IO.Path.GetFullPath(relativePath);

            int _internalPort = BobcDesktopUtils.GetAvaliablePort(25001, 45000);
            int externalPort = BobcDesktopUtils.GetAvaliablePort(10000, 25000);

            erlNode = new Process();
            erlNode.StartInfo.WorkingDirectory = string.Format(fullPath);
            erlNode.StartInfo.FileName = "cmd.exe";
            erlNode.StartInfo.CreateNoWindow = !debugModeOn;
            erlNode.StartInfo.RedirectStandardInput = true;
            erlNode.StartInfo.UseShellExecute = false;
            erlNode.Start();
            erlNode.StandardInput.WriteLine($"start.bat {name} {_internalPort} {externalPort} \"{remoteUsers}\"");


            mainWindow = _mainWindow;

            messages = new ObservableCollection<string> { };

            MessagesHolder.ItemsSource = messages;

            internalPort = _internalPort;

            ws = new WebSocket($"ws://localhost:{internalPort}/websocket");
            ws.OnMessage += Ws_OnMessage;
            ws.OnClose += Ws_OnClose;
            ws.Connect();
        }


        private void Ws_OnClose(object sender, CloseEventArgs e)
        {
            ws = new WebSocket($"ws://localhost:{internalPort}/websocket");
            ws.OnMessage += Ws_OnMessage;
            ws.OnClose += Ws_OnClose;
            ws.Connect();
        }

        private void Ws_OnMessage(object sender, MessageEventArgs e)
        {
            App.Current.Dispatcher.Invoke((Action)delegate
            {
                messages.Add(e.Data);
            });
        }

        private void SendButton_Click(object sender, RoutedEventArgs e)
        {
            string newMessage = InputBox.Text;
            InputBox.Clear();
            ws.Send(newMessage);
            messages.Add(newMessage);
        }
    }
}
