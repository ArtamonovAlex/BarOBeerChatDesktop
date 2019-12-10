using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.NetworkInformation;
using System.Text;
using System.Threading.Tasks;

namespace BOBCClient
{
    public static class BobcDesktopUtils
    {
        public static int GetAvaliablePort(int min, int max) {
            Random r = new Random();
            bool isAvailable = false;
            int port = 0;
            IPGlobalProperties ipGlobalProperties = IPGlobalProperties.GetIPGlobalProperties();
            TcpConnectionInformation[] tcpConnInfoArray = ipGlobalProperties.GetActiveTcpConnections();
            while (!isAvailable) {
                port = r.Next(min, max);
                isAvailable = true;
                foreach (TcpConnectionInformation tcpi in tcpConnInfoArray)
                {
                    if (tcpi.LocalEndPoint.Port == port)
                    {
                        isAvailable = false;
                        break;
                    }
                }
            }
            return port;
        }

        public static T FromJson<T>(string json) {
            return JsonConvert.DeserializeObject<T>(json);
        }

        public static dynamic FromJson(string json) {
            return JsonConvert.DeserializeObject(json);
        }

        public static string ToJson(object Obj) {
            return JsonConvert.SerializeObject(Obj);
        }
    }
}
