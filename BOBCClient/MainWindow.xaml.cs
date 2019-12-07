using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
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
    /// Логика взаимодействия для MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private ObservableCollection<string> messages;

        private WebSocket ws;

        public MainWindow()
        {
            InitializeComponent();


            messages = new ObservableCollection<string> {};

            MessageBox.ItemsSource = messages;

            ws = new WebSocket("ws://localhost:8080/websocket");
            ws.OnMessage += Ws_OnMessage;
            ws.OnClose += Ws_OnClose;
            ws.Connect();

        }

        private void Ws_OnClose(object sender, CloseEventArgs e)
        {
            ws = new WebSocket("ws://localhost:8080/websocket");
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
