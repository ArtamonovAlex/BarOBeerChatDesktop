using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
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
    /// Логика взаимодействия для SignInPage.xaml
    /// </summary>
    public partial class SignInPage : Page
    {

        private MainWindow mainWindow;
        public SignInPage(MainWindow _mainWindow)
        {
            InitializeComponent();

            mainWindow = _mainWindow;
        }

        private async void SignInButton_Click(object sender, RoutedEventArgs e)
        {
            string login = LoginBox.Text;
            string password = PasswordBox.Password;
            bool isEverythingCorrect = await validateUserAsync(login, password);
            if (isEverythingCorrect)
            {
                mainWindow.OpenPage(new ConnectionPage(mainWindow, login));
            }
        }

        private async Task<bool> validateUserAsync(string login, string password)
        {
            HttpClient httpClient = mainWindow.httpClient;
            var postParams = new Dictionary<string, string>
            {
            {"login", login},
            {"password", password}
            };
            var content = new FormUrlEncodedContent(postParams);
            var response = await httpClient.PostAsync("http://localhost:9090/signin", content);
            var responseStringJson = await response.Content.ReadAsStringAsync();
            string responseString = BobcDesktopUtils.FromJson<string>(responseStringJson);
            if (responseString == "ok") {
                return true;
            } else {
                MessageBox.Show(responseString);
                return false;
            }
        }
    }
}
