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

namespace BOBCClient
{
    /// <summary>
    /// Логика взаимодействия для WelcomePage.xaml
    /// </summary>
    public partial class WelcomePage : Page
    {
        private MainWindow mainWindow;
        public WelcomePage(MainWindow _mainWindow)
        {
            InitializeComponent();

            mainWindow = _mainWindow;
        }

        private void SignInButton_Click(object sender, RoutedEventArgs e)
        {
            mainWindow.OpenPage(new SignInPage(mainWindow));
        }

        private void SignUpButton_Click(object sender, RoutedEventArgs e)
        {

        }
    }
}
