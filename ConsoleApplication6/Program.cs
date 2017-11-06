using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApplication6
{
    class Program
    {
        static string getOpCode(string instruction)
        {
            string opcode = "";
            switch (instruction) //bits 13:15 opcodes
            {
                case "mov":
                    opcode = "000";
                    break;
                case "load":
                    opcode = "001";
                    break;
                case "add":
                    opcode = "010";
                    break;
                case "lsh":
                    opcode = "011";
                    break;
                case "brl":
                    opcode = "100";
                    break;
                case "brz":
                    opcode = "101";
                    break;
                case "br":
                    opcode = "110";
                    break;
                default:
                    opcode = "000";
                    break;
            }
            return opcode;
        }
        static string getRegCode(string reg)
        {
            string regCode = "";
            switch (reg) //bits 10:12 first input reg
            {
                case "a1":
                    regCode = "001";
                    break;
                case "a2":
                    regCode = "010";
                    break;
                case "a3":
                    regCode = "011";
                    break;
                case "d1":
                    regCode = "100";
                    break;
                case "out":
                    regCode = "101";
                    break;
                case "fp":
                    regCode = "110";
                    break;
                case "sp":
                    regCode = "111";
                    break;
                default:
                    Console.WriteLine("ERROR: Invalid Input");
                    Environment.Exit(2); //exit code 2 terminate
                    break;
            }
            return regCode;
        }
        static void Main(string[] args)
        {
            int counter = 0;
            List<string[]> lines = new List<string[]>();
            List<string> outLines = new List<string>();
            string lineOut;
            string line;
            int lit;

            Dictionary<string, string> lookup = new Dictionary<string, string>();

            StreamReader file = new StreamReader("code.txt");
            //StreamWriter outF = new StreamWriter("out.oem");
            using (file)
            {
                while ((line = file.ReadLine()) != null)
                {
                    lines.Add(line.Split(' '));
                }
            }


            foreach(string[] l in lines)
            {
                if (l.Length == 1)
                { //Here:
                    lineOut = "111"; 
                    string labelName = l[0].Substring(0, l[0].Length - 1);
                    if (!lookup.ContainsKey(labelName)) { 
                        string lookupValue = "";
                        string s = Convert.ToString(lookup.Count, 2);
                        for (int i = s.Length; i < 13; i++) //add extra zeros to fill the 8 bits
                        {
                            lookupValue += "0";
                        }
                        lookupValue += s;
                        lookup.Add(labelName, lookupValue);
                        lineOut += lookupValue;
                    } else
                    {
                        lineOut+=lookup[labelName];
                    }
                } else if (l.Length == 2) //branch
                {
                    lineOut = getOpCode(l[0]);
                    string value = "";
                    if (!lookup.ContainsKey(l[1]))
                    {
                        string s = Convert.ToString(lookup.Count, 2);
                        for (int i = s.Length; i < 13; i++) //add extra zeros to fill the 8 bits
                        {
                            value += "0";
                        }
                        value += s;
                        lookup.Add(l[1], value);
                        lineOut += value;
                    } else
                    {
                        lineOut += lookup[l[1]];
                    }
                } else
                {
                    lineOut = getOpCode(l[0]); //bits 13:15 opcodes

                    lineOut += getRegCode(l[1]); //bits 10:12
                    Console.WriteLine(l[2][0]);
                    if (l[2][0] == '-') //parse negative literal
                    {
                        lineOut += "000";
                        string negativeNum = l[2].Substring(1, l[2].Length - 1);
                        int neg;
                        if (Int32.TryParse(negativeNum, out neg))
                        {
                            string s = Convert.ToString(neg * -1, 2);
                            lineOut += s.Substring(s.Length - 7);
                        }
                        else
                        {
                            Console.WriteLine("ERROR: Negative number could not be parsed");
                            Environment.Exit(2);
                        }
                    }
                    else
                    {
                        if (Int32.TryParse(l[2], out lit)) //check if the lit can be parsed or not
                        {                                 //if it can then that's the literal
                            if (lit < 64 && lit > -64)
                            {
                                lineOut += "000";
                                string s = Convert.ToString(lit, 2);
                                for (int i = s.Length; i < 7; i++) //add extra zeros to fill the 8 bits
                                {
                                    lineOut += "0";
                                }
                                lineOut += s;
                            }
                            else
                            {
                                Console.WriteLine("ERROR: invalid literal range");
                                Environment.Exit(2); //exit code 2 terminate
                            }
                        }
                        else
                        {
                            lineOut += getRegCode(l[2]); //bits 7:9 second input reg
                            lineOut += "0000000"; //bits 0:6
                        }
                    }

                }
                outLines.Add(lineOut);
                counter++;
            }
                

            File.Create("out.oem").Close();
            using (StreamWriter outLine = new StreamWriter("out.oem"))
            {
                outLine.WriteLine("memory_initialization_radix=2;");
                outLine.WriteLine("memory_initialization_vector=");
                foreach(string s in outLines)
                {
                    outLine.WriteLine(s + ',');
                }
                outLine.Write(";");
            }
        }
    }
}
