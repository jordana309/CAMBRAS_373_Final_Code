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
