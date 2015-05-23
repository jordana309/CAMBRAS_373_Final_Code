/* helpful.h
 * CAMBRA
 * ME373-Spring 2015
 * This file contails some useful functions that we use throughout the program.
 * Functions include data verification, a pause function, etc. */

/* Verify Double Input: Verifies that the input is a number. The result is type double, but can be
   easily cast to any numeric datatype.
 * Args: msg-the prompt to the user, telling them what input is wanted
         errmsg-the message to print to the screen if their input fails verification
 * Coder: Jordan Argyle
 * Use: set the number you're trying to use = to this function, passing in both messages
   ie string msg="Please enter a number: ";
      string errMsg="I said a number. Try again.";
      float myvar = vdblIn(msg, errMsg); */
double vdblIn(string msg, string errMsg)
{
  double f;       // Our temp var
  bool cont=true; // Ends the while loop

  while(cont)
  {
    cout << msg;
    cin >> f;
    
    // Verify input
    if( cin.fail( ) )
    {
      // Input failed. Loop again.
      cin.clear();
      cin.ignore();
      cout << endl << errMsg;
    } else {
      // Input succeeded
      cont = false;
      return(f);
    }
  } // End while
}

/* Verify File name: Verifies that the input is a file that actually exists
 * Args: msg-the prompt to the user; text asking them for file name
         errMsg-the message to print to the screen if their input fails verification
 * Location: helpful.h
 * Author: Jordan Argyle
 * Use: set the string that will hold the filename = to this function, passing in both messages
   ie see vdblIn above  */
string vfilename(string msg, string errMsg)
{
  string fn, loc; // Our temp var, root location
  fstream f;      // Temp file name
  bool cont=true; // Ends the while loop
  
  loc = "../../";

  while(cont)
  {
    cout << msg;
    cin >> fn;
    
    // Verify input
    if( cin.fail( ) )
    {
      // Input failed. Loop again.
      cin.clear();
      cin.ignore();
      cout << endl << errMsg;
    } else {
      // Input succeeded
      // First, See if they want to kill the program
      if(fn == "End" || fn == "end" || fn == "0")
      {
        cont = !cont;
        return(fn);
      } else {
        // Now check if file opened
        fn = loc + fn;
        f.open(fn,ios::in);
        if( f.is_open() )
        {
          // It opened!
          f.close();
          cont = false;
          return(fn);
        } else {
          // It didn't open!
          cout << endl << errMsg;
        } // End check if file opened
      } // End check if they killed the program
    } // End check if they failed input
  } // End while
}

/* Pause: Pauses the program with a custom message, and then skips to a new line after any key
   press.
 * Args: strMsg-message to print to screen when pausing
 * Location: helpful.h
 * Author: Jordan Argyle 
 * Use: Just send in a string for a message to display. When they hit any key, it exits the
   function.
TODO: This function doesn't currently pull in what they pushed, but can be adapted to return an int
      when they enter certain things. Just need to figure out how to get it from the iostream. */
int pause(string strMsg)
{
	// Initialize needed variables
	char usrIn;
	int ret = 0;
	// Set a default message text
	if (strMsg.empty())
	{
		strMsg = "Press any key to continue...";
	}
	// Output the message and wait for input
	cout << endl << strMsg << "\n\n";
	cin.clear();
	while (1)
	{
		// If they push something on their keyboard
		if (_kbhit())
		{
			usrIn = getchar();
			break;
		}
	}

	return ret;
}