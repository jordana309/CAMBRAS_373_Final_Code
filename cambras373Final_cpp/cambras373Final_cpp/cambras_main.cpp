/* cambras_main.cpp
 * Michael Ah Sue, Jordan Argyle, Matthew Bare, Angus Cameron,
    Debora Lyn Moran, Shaun Rhodes, Peter Schleede
    ie Team CAMBRA (last names of each member, if you must know)
 * ME373-Numerical Methods for Engineers Spring 2015
 * Final Project

 // Explaination of project goes here

   C++:
    Tell them what we're doing
      Jordan
    Ask where they live
      Jordan
    Pull in data for that location
      Jordan
    Give them state-wide/average-per-resident-of-state data
      Jordan
    Ask them lots of personal questions
      Everyone but Jordan
    Use that data to give them their average
      Shaun, Angus=CO2, Power, 
    Compare their usage to the "average" from their state
      
    How much their state would produce if everyone in it produced as much as they did
    Extrapolate back their their life (up 'till now) and present cumulative until now
    Extrapolate forward until they die (until you die), and give how much more damage they'll cause
    Combine it all, and show them how much they'll damage the world
    Suggestions for improvement, and and comparisons with their changes and now extrapolated to future
    Output a file with personal data for them to import into Matlab for better visualization

   Matlab:
    Crunch census data, state power generation data, and state emissions data
    Output it all to a file for C++ to read in, giving all useful info for each state in a single file
    ---
    Inport C++ output and plot it for them, or otherwise visualize it (bar graphs, whatever)
    Stress the importance of taking care of the planet!
  */

/* Explaination for group members:
 * This is our C++ main program. Classes, other functions should be included in headers.
 * The includes: - classes, in alphabetical order
                 - headers/libraries, in alphabetical order
                 - summary of all functions. Please follow the layout for those
                 - our main function
 * I try to keep the program lines shorter than 100 total characters. To help with this, I use two
   spaces instead of tabs (you can set tab width in Tools-->Options, Text Editor->C/C++->Tabs). 
 * If you have any questions about how to use GitHub or anything else, just let me know, and I'll
   do my best to help you out! */

/*---- Declare Namespace ----*/
using namespace std;

/*---- Includes: needed classes ----*/
#include <fstream>  // To be able to access files and write to them
#include <iostream> // To be able to take input and write output to the terminal
#include <iomanip>  // To be able to format the iostream output so it's pretty
#include <string>   // To be able to use strings normally
#include <vector>   // To be able to make matrices
/*---- Includes: needed libraries ----*/
#include <conio.h>  // To be able to use _kbhit()
#include "helpful.h" // Includes helpufl functions to use

/*---- Function summaries ----*/
/* function full name: explain function quickly. Function name is abbreviated
 * Args: explain what the arguments are
 * Location: library/file containing this function
 * Author: person who coded up the function/method 
 * Note that in the actual function definition, you would add some usage information under the
   author line (explain how to use the function, give a little example, etc). See "helpful.h"
   for some examples. Also other notes can go here. */
//type fxnFN(type, type);

// helpful.h
/* Verify Double Input: Verifies that the input is a number. The result is type double, but can be
   easily cast to any numeric datatype.
 * Args: msg-the prompt to the user, telling them what input is wanted
         errmsg-the message to print to the screen if their input fails verification
 * Location: helpful.h 
 * Author: Jordan Argyle */
//double vdblIn(string msg, string errMsg);

/* Verify File name: Verifies that the input is a file that actually exists
 * Args: msg-the prompt to the user; text asking them for file name
         errMsg-the message to print to the screen if their input fails verification
 * Location: helpful.h
 * Author: Jordan Argyle */
//string vfilename(string msg, string errMsg);

/* Pause: Pauses the program with a custom message, and then skips to a new line after any key
   press.
 * Args: strMsg-message to print to screen when pausing
 * Location: helpful.h
 * Author: Jordan Argyle */
//int pause(string strMsg);

/*---- Begin Main function ----*/
int main()
{
  // -- Variable Declarations -- \\
  //type var; // Quick summary of what the var does
  string msg, errmsg;   // The message and error message to send verification functions
  unsigned int stID;            // Holds the enum index of the state, or the state ID
  // -- 1) First main subsection. -- \\
  // 1a) What 1a is
  // Code for 1a
  //...

  msg = "Enter a state: ";
  errmsg = "No, a state, please. You can use the name, or the 2-letter abbreviation.\n\n";
  stID = vstate(msg, errmsg);
  cout << State(stID);
  pause("Hit a key to exit");

  
}

//yeah this code is huge, but here it is! 
//Combined code of Angus and Shaun

#include<cmath>
#include<iomanip> 
#include<iostream> 
#include<fstream> 
#include<string> 
#include<vector> 
#include<array>

using namespace std;


int main()
{
	//Declare variables
	int microwave, oven, dishwasher, dryer, washer, tv, comp, lap, coffee, vac, game, freezer, frig, cellp, freezertime, frigtime, siga, typtv, y(1);
	double micromin, ovenmin, dishtime, dryertime, washertime, tvmin, comptime, laptime, coffeetime, vactime, gametime, cellptime;
	double ca, cb, cc, cd, ce, cf(0), cg, ch, ci, cj, ck, cl, cm, cn, tot, apptotal;
	double mpg, miles, gal(0), total(0), watheat(0);
	double sqft(0), apow(0), showtime(0), cool(0);
	double showmin(0), natgas(0), carco2(0);
	char ans, vehicle, car, acondition, heattype, heater;
	double gco2pm(0), aconduse(0), heatmonth(0);
	int chooseheat, cont;
	fstream fout;
	string filename;

	//re-do option for entire function
	do{

		//Car Data
		//Ask user if they own a vehicle
		cout << "Do You own a vehicle? (Y/N)" << endl;
		cin >> vehicle;

		//Start if loop for vehicle
		if ((vehicle == 'y') | (vehicle == 'Y'))
		{
			//Do-loop for gallons of gas used/month
			do
			{
				//Prompt the user for 
				cout << "How many miles per gallon does this vehicle get?" << endl;
				cin >> mpg;
				cout << "How many miles do you drive this car per month on average?" << endl;
				cin >> miles;
				cout << "Is this vehicle a diesel?" << endl;
				cin >> car;


				//Determine which conversion to use for gas
				//Diesel g C02/gal
				if ((car == 'y') | (car == 'Y'))
				{
					carco2 += (1 / (mpg))*miles*22.38; //This is CO2 output in g/month
				}
				//Normal g C02/gal
				else
				{
					carco2 += (1 / (mpg))*miles*19.64; //This is CO2 output in g/month
				}

				//Ask user to continue for loop
				cout << "Do you own another vehicle?\n";
				cin >> ans;

			} while ((ans == 'Y') | (ans == 'y'));
		}
		//exit the do loop
		else
		{
			carco2 += 0;
		}


		//Gas Usage data
		//Find if water heater is gas or electric
		cout << "Is your water heater electric or gas? (E for electric, G for gas)" << endl;
		cin >> heattype;

		//For Gas water heater
		if ((heattype == 'G') | (heattype == 'g'))
		{
			natgas += 750 * 3 * 30 * .0731644; //750 Btu per hour 3hour/day this is per month .0731644 gco2/btu
		}

		//For Electric
		if ((heattype == 'E') | (heattype == 'e'))
		{
			total += 3 * 4000 * 30; //Typically electric water heaters 4000 watts 3 hours a day (30 days)
		}

		//any other input
		else
		{
			natgas += 0;
		}

		//Prompt if heats house
		cout << "Do you heat your house?(Y/N)" << endl;
		cin >> heater;

		//If house is heated
		if ((heater == 'Y') | (heater == 'y'))
		{
			//Establish variables
			int heat;
			int dayburn;

			//Ask user for method to heat house
			cout << "How many months do you have to heat your house?" << endl;
			cin >> heat;
			cout << "With which method do you heat your house ?\n" << endl;
			cout << "Space Heater" << setw(16) << "Furnace" << setw(16) << "Fireplace" << endl;
			cout << "\t1" << setw(12) << "\t2" << setw(12) << "\t3" << endl;
			cin >> chooseheat;

			//For Space heater
			if (chooseheat == 1)
			{
				//Prompt for hours usage
				cout << "How many hours do you use your heater each month?" << endl;
				cin >> heatmonth;
				total += 1200 * heatmonth*heat / 12; //1200 watts/hour average in house heater (this calc is in per month)
			}
			//For Furnace
			else if (chooseheat == 2)
			{
				cout << "How many hours is your furnace running each day that you are using it?" << endl;
				cin >> heatmonth;
				natgas += 80000 * heatmonth * 30 * heat * .0731644 / 144; //80000 btu/ hour (this calculation is in g/per month)
			}
			//For fire
			else if (chooseheat == 3)
			{
				cout << "How many days a month do you burn ?" << endl;
				cin >> dayburn;
				cout << "How many logs do you burn in your fireplace each day that you burn?" << endl;
				cin >> heatmonth;
				gco2pm += dayburn*heat*heatmonth * 5 * 830 / 12; //This is grams of co2 /month
			}
			//escape for loop
			else
			{
				natgas += 0;
			}
		}
		//escape for loop
		else
		{
			natgas += 0;
		}


		//Prompt for use of air conditioning
		cout << "Do you use a system to cool your house?(Y/N)" << endl;
		cin >> acondition;

		if ((acondition == 'y') | (acondition == 'Y'))
		{
			//Declare variables
			double houracond;
			int type;
			int redo(0);

			//Prompt user for information
			cout << "How many months of the year do you use air conditioning?" << endl;
			cin >> aconduse;
			cout << "How many hours do you use your air conditioner per day?" << endl;
			cin >> houracond;

			do{
				redo = 0;
				cout << "Which unit do you use to cool your house ? (Enter the number)\n" << endl;
				cout << "Window unit" << setw(14) << "Swamp Cooler" << setw(14) << "A/C Unit" << endl;
				cout << "    1" << setw(12) << "\t    2" << setw(12) << "        3" << endl;
				cin >> type;

				//For loops to calculate power consumption
				//For Window unit
				if (type == 1)
				{
					cool += aconduse*houracond * 900 * 30 / 12; //900 watts for window (result in watt-h/month)
				}
				//For Swamp cooler
				else if (type == 2)
				{
					cool += aconduse*houracond * 30 * 539 / 12; //539 watts per hour for Swamp cooler
				}
				//For air conditioning
				else if (type == 3)
				{
					cool += aconduse*houracond * 30 * 1140 / 12; //1140 watts per hour for a/c
				}
				//repeat for error
				else
				{
					//Calls back error
					cout << "Im sorry please enter a valid number." << endl;
					redo = 1;
					cin.clear(); //Clears an error code if one occurs
					cin.ignore(); //ignores any charachter that is not written to memory.
				}
			} while (redo == 1);
		}
		//Get out of for loop
		else
		{
			total += 0;
		}

		// Ask user about household appliance usage
		cout << "For all of the following yes or no questions, use 1 for yes and 0 for no" << endl;

		//Microwave
		cout << "Do you own a microwave?" << endl;
		cin >> microwave;
		if (microwave == y)
		{
			cout << "Approximately how long (in minutes) do you use it each day?";
			cin >> micromin;
		}
		else
		{
			micromin = 0;
		}

		//Oven
		cout << "Do you own an oven?" << endl;
		cin >> oven;
		if (oven == y)
		{
			cout << "Approximately how long (in minutes) do you use it each week?";
			cin >> ovenmin;
		}
		else
		{
			ovenmin = 0;
		}

		//Dishwasher
		cout << "Do you own a dishwasher?" << endl;
		cin >> dishwasher;
		if (dishwasher == y)
		{
			cout << "How many times do you run your dishwasher every week?";
			cin >> dishtime;
		}
		else
		{
			dishtime = 0;
		}

		//Dryer
		cout << "Do you own a clothes dryer?" << endl;
		cin >> dryer;
		if (dryer == y)
		{
			cout << "How many times do you run your clothes dryer every week?";
			cin >> dryertime;
		}
		else
		{
			dryertime = 0;
		}

		//Washing Machine
		cout << "Do you own a washing machine?" << endl;
		cin >> washer;
		if (washer == y)
		{
			cout << "How many times do you run your washing machine every week?";
			cin >> washertime;
		}
		else
		{
			washertime = 0;
		}

		//Television
		cout << "Do you own an television?" << endl;
		cin >> tv;
		if (tv == y)
		{
			cout << "What kind of television is it?\n" << endl;
			cout << "Plasma" << setw(16) << "LCD" << setw(16) << "Standard" << endl;
			cout << "\t1" << setw(12) << "\t2" << setw(12) << "\t3" << endl;
			cin >> typtv;

			if (typtv == 1)
			{
				cout << "Approximately how long (in minutes) do you use it each day?";
				cin >> tvmin;
				cf += (tvmin * 339) / 60;
			}
			else if (typtv == 2)
			{
				cout << "Approximately how long (in minutes) do you use it each day?";
				cin >> tvmin;
				cf += (tvmin * 213) / 60;
			}
			else if (typtv == 3)
			{
				cout << "Approximately how long (in minutes) do you use it each day?";
				cin >> tvmin;
				cf += (tvmin * 150) / 60;
			}
			else
			{
				cf = 0;
			}
		}
		else
		{
			cf = 0;
		}

		//Computer
		cout << "Do you own a desktop computer?" << endl;
		cin >> comp;
		if (comp == y)
		{
			cout << "How many hours a day do you have your desktop computer turned on?";
			cin >> comptime;
		}
		else
		{
			comptime = 0;
		}

		//Laptop
		cout << "Do you own a laptop computer?" << endl;
		cin >> lap;
		if (lap == y)
		{
			cout << "How many hours a day do you have your laptop plugged in?";
			cin >> laptime;
		}
		else
		{
			laptime = 0;
		}

		//Coffee Maker
		cout << "Do you own a coffee maker?" << endl;
		cin >> coffee;
		if (coffee == y)
		{
			cout << "How many pots of coffee do you make a day?";
			cin >> coffeetime;
		}
		else
		{
			coffeetime = 0;
		}

		//Vacuum
		cout << "Do you own a vacuum cleaner?" << endl;
		cin >> vac;
		if (vac == y)
		{
			cout << "How many minutes do you spend vacuuming each week?";
			cin >> vactime;
		}
		else
		{
			vactime = 0;
		}

		//Video Games
		cout << "Do you own a video game console?" << endl;
		cin >> game;
		if (game == y)
		{
			cout << "How many minutes do you spend on your game console each day?";
			cin >> gametime;
		}
		else
		{
			gametime = 0;
		}

		//Freezer
		cout << "Do you own a stand alone freezer?" << endl;
		cin >> freezer;
		if (freezer == y)
		{
			freezertime = 1240;
		}
		else
		{
			freezertime = 0;
		}

		//Refrigerator
		cout << "Do you own a refrigerator?" << endl;
		cin >> frig;
		if (frig == y)
		{
			frigtime = 1411;
		}
		else
		{
			frigtime = 0;
		}

		//Cellphone
		cout << "Do you own a cellphone?" << endl;
		cin >> cellp;
		if (cellp == y)
		{
			cout << "How many hours a day do you have your cell phone plugged in?";
			cin >> cellptime;
		}
		else
		{
			cellptime = 0;
		}

		//Ask user to run the survey again
		cout << "Would you like to run the survey again? Enter 1 for yes or anything else for no." << endl;
		cin >> cont;

		cin.clear(); //Clears an error code if one occurs
		cin.ignore(); //ignores any charachter that is not written to memory.

		//end original repeat loop
	} while (cont == 1);

	//Calculate watt-hour consumption from these appliances per day
	ca = (micromin * 1500) / 60;
	cb = (ovenmin * 3000) / (7 * 60);
	cc = (washertime * 1500 * 1.5) / 7;
	cd = (dryertime * 3400 * 60) / 7;
	ce = (washertime * 500 * 0.75) / 7;
	cg = (comptime * 120);
	ch = (laptime * 250);
	ci = (coffeetime * 1500 * 20) / 60;
	cj = (vactime * 500) / (7 * 60);
	ck = (gametime * 195) / 60;
	cl = freezertime;
	cm = frigtime;
	cn = (cellp * 5);
	//Calculate total watt-hour consumption
	tot = ca + cb + cc + cd + ce + cf + cg + ch + ci + cj + ck + cl + cm + cn;

	//convert w-hours to g/month 81% is coal 15% is nat gas
	double gtotal = ((.15)*(total)*.465) + ((.81)*total*.909);
	double gcool = ((.15)*(cool)*.465) + ((.81)*cool*.909);
	apptotal = ((.15)*(tot)*.465) + ((.81)*tot*.909);

	//Display total CO2 emmissions per month
	cout << "Your total CO2 emissions are:  " << carco2+natgas+gtotal+gco2pm+gcool+apptotal << endl;

	//Output to a file
	fout << carco2 << setw(10) << natgas << setw(10) << gtotal << setw(10) << gco2pm << setw(10) << gcool <<setw(10)<<apptotal<< endl;
	
	//close file that was written to
	fout.close();

	//System Pause
	system("pause");

	return 0;
}

