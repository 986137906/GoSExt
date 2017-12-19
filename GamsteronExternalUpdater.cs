using System;
using System.IO;
using System.Net;
using System.Linq;

namespace GamsteronExternalUpdater
{
	class Program
	{
		static string[] DownloadFileArray(string link)
		{
			string[] result = {};
			using (var client = new WebClient())
			{
				result = client.DownloadString(link).Split("\r\n".ToCharArray(), StringSplitOptions.RemoveEmptyEntries);
			}
			return result;
		}
		static string DownloadFileString(string link)
		{
			string result = "";
			using (var client = new WebClient())
			{
				result = client.DownloadString(link);
			}
			return result;
		}
		static string GetFileName(string line)
		{
			string result	= "";
			string name	= "";
			int lenght	= line.Length;
			for (int i = lenght - 1; i >= 0; i--)
			{
				char c = line[i];
				if (c == '/')
					break;
				name += c;
			}
			int count = name.Length;
			for (int i = count - 1; i >= 0; i--)
			{
				result += name[i];
			}
			return result;
		}
		public static void Main(string[] args)
		{
			Console.WriteLine(Environment.NewLine+"Gamsteron Scripts Updater:");
			Console.WriteLine(Environment.NewLine+"Downloading, please wait...");
			string scriptPath	= Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData)+@"\GamingOnSteroids\LOLEXT\Scripts\";
			string commonPath	= Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData)+@"\GamingOnSteroids\LOLEXT\Scripts\Common\";
			
			string rawLink		= "https://raw.githubusercontent.com/gamsteron/GoSExt/master/GetRaw.txt";
			string[] rawResult	= DownloadFileArray(rawLink);
			bool isScript		= false;
			int lenght			= rawResult.Length;
			for (int i = 0; i < lenght; i++)
			{
				if (i==0) continue;
				var line = rawResult[i];
				if (line == "Script:")
				{
					isScript = true;
					continue;
				}
				string filename = GetFileName(line);
				if (isScript)
				{
					File.WriteAllText (scriptPath+filename, DownloadFileString(line));
				}
				else
				{
					File.WriteAllText (commonPath+filename, DownloadFileString(line));
				}
			}
			Console.Clear();
			Console.WriteLine(Environment.NewLine+"Gamsteron Scripts Updater:");
			Console.WriteLine(Environment.NewLine+Environment.NewLine+Environment.NewLine+"Download complete. Press any key to continue . . . ");
			Console.ReadKey(true);
		}
	}
}
