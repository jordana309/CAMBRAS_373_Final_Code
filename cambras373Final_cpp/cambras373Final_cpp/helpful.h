/* helpful.h
 * Team CAMBRA
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
   ie: see vdblIn above  */
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

/* To Upper Case: Takes a string and capitalizes either the first letter, or the whole word,
   depending on the boolian sent in. Useful for single words, as it will operate on the entire
   string.
 * Args: s-The string to capitalize
         all-True: capitalizes every letter in the string
             False: only capitalizes the first letter, and forces the rest of the string to lower
 * Location: helpful.h
 * Author: Jordan Argyle 
 * Use: Send a string, and a boolean. It returns the modified string. */
string toUpper(string s, bool all)
{
  char c; // Each char from s will be shoved in c
  
  // Capitalize first letter
  s[0] = toupper( s[0] );
  
  // Make sure there's more string to operate on
  if(s.length() > 1)
  {
    // Loop through the string
    for(int i=1; i<s.length(); i++)
    {
      // See if we're capitalizing everything or lower-casing everything
      if(all)
      {
        s[i] = toupper( s[i] );
      } else {
        s[i] = tolower( s[i] );
      }
    } // end for loop
  } // end check that string is longer than 1 char
  return s;
}

/* State: Maps all our state codes to a text representation that we can print to terminal
   where the code is 0-49, 0=Alabama, 49=Wyoming. DC=Virginia.
 * Args: the state code, generated from vstate
 * Location: helpful.h
 * Author: Jordan Argyle
 * Use: in a cout call, just call State(state_code) */
enum State {
  Alabama=0,    // 0
  Alaska,
  Arizona,
  Arkansas,
  California,
  Colorado,     // 5
  Connecticut,
  Delaware,
  Florida,
  Georgia,
  Hawaii,       // 10
  Idaho,
  Illinois,
  Indiana,
  Iowa,
  Kansas,       // 15
  Kentucky,
  Louisiana,
  Maine,
  Maryland,
  Massachusetts,// 20
  Michigan,
  Minnesota,
  Mississippi,
  Missouri,
  Montana,      // 25
  Nebraska,
  Nevada,
  NewHampshire,
  NewJersey,
  NewMexico,    // 30
  NewYork,
  NorthCarolina,
  NorthDakota,
  Ohio,
  Oklahoma,     // 35
  Oregon,
  Pennsylvania,
  RhodeIsland,
  SouthCarolina,
  SouthDakota,  // 40
  Tennessee,
  Texas,
  Utah,
  Vermont,
  Virginia,     // 45
  Washington,
  WestVirginia,
  Wisconsin,
  Wyoming       // 49
};

/* Verify State: Verifies that the input is actually a state and returns the code for the state
   where the code is 0-49, 0=Alabama, 49=Wyoming. DC=Virginia.
 * Args: msg-the prompt to the user; text asking them for a state
         errMsg-the message to print to the screen if their input fails verification
 * Location: helpful.h
 * Author: Jordan Argyle
 * Use: set an int that will hold the code for the state = to this function, passing in both
   messages. ie: see vdblIn above  */
int vstate(string msg, string errMsg)
{
  string sn;      // Our temp var
  fstream f;      // Temp file name
  bool cont=true; // Ends the while loop

  while(cont)
  {
    cout << msg;
    cin >> sn;
    // Puts state name in all lower case to compare. Used upper because the list of US states and
    // abbreviations I found was in all uppercase.
    sn = toUpper(sn, true);

    // Verify input
    if( cin.fail( ) )
    {
      // Input failed. Loop again.
      cin.clear();
      cin.ignore();
      cout << endl << errMsg;
    } else {
      // Input succeeded. Check if it's a state. If so, return the state code and break.
      cont = false; // Set cont=false, and only make it true again if they didn't enter a state
      if(sn=="ALABAMA" || sn=="AL")
      {
        return State(Alabama);
      } else if(sn=="ALASKA" || sn=="AK") {
        return State(Alaska);
      } else if(sn=="ARIZONA" || sn=="AZ") {
        return State(Arizona);
      } else if(sn=="ARKANSAS" || sn=="AR") {
        return State(Arkansas);
      } else if(sn=="CALIFORNIA" || sn=="CA") {
        return State(California);
      } else if(sn=="COLORADO" || sn=="CO") {
        return State(Colorado);
      } else if(sn=="CONNECTICUT" || sn=="CT") {
        return State(Connecticut);
      } else if(sn=="DELAWARE" || sn=="DE") {
        return State(Delaware);
      } else if(sn=="FLORIDA" || sn=="FL") {
        return State(Florida);
      } else if(sn=="GEORGIA" || sn=="GA") {
        return State(Georgia);
      } else if(sn=="HAWAII" || sn=="HI") {
        return State(Hawaii);
      } else if(sn=="IDAHO" || sn=="ID") {
        return State(Idaho);
      } else if(sn=="ILLINOIS" || sn=="IL") {
        return State(Illinois);
      } else if(sn=="INDIANA" || sn=="IN") {
        return State(Indiana);
      } else if(sn=="IOWA" || sn=="IA") {
        return State(Iowa);
      } else if(sn=="KANSAS" || sn=="KS") {
        return State(Kansas);
      } else if(sn=="KENTUCKY" || sn=="KY") {
        return State(Kentucky);
      } else if(sn=="LOUISIANA" || sn=="LA") {
        return State(Louisiana);
      } else if(sn=="MAINE" || sn=="ME") {
        return State(Maine);
      } else if(sn=="MARYLAND" || sn=="MD") {
        return State(Maryland);
      } else if(sn=="MASSACHUSETTS" || sn=="MA") {
        return State(Massachusetts);
      } else if(sn=="MICHIGAN" || sn=="MI") {
        return State(Michigan);
      } else if(sn=="MINNESOTA" || sn=="MN") {
        return State(Minnesota);
      } else if(sn=="MISSISSIPPI" || sn=="MS") {
        return State(Mississippi);
      } else if(sn=="MISSOURI" || sn=="MO") {
        return State(Missouri);
      } else if(sn=="MONTANA" || sn=="MT") {
        return State(Montana);
      } else if(sn=="NEBRASKA" || sn=="NE") {
        return State(Nebraska);
      } else if(sn=="NEVADA" || sn=="NV") {
        return State(Nevada);
      } else if(sn=="NEW HAMPSHIRE" || sn=="NH") {
        return State(NewHampshire);
      } else if(sn=="NEW JERSEY" || sn=="NJ") {
        return State(NewJersey);
      } else if(sn=="NEW MEXIC" || sn=="NM") {
        return State(NewMexico);
      } else if(sn=="NEW YORK" || sn=="NY") {
        return State(NewYork);
      } else if(sn=="NORTH CAROLINA" || sn=="NC") {
        return State(NorthCarolina);
      } else if(sn=="NORTH DAKOTA" || sn=="ND") {
        return State(NorthDakota);
      } else if(sn=="OHIO" || sn=="OH") {
        return State(Ohio);
      } else if(sn=="OKLAHOMA" || sn=="OK") {
        return State(Oklahoma);
      } else if(sn=="OREGON" || sn=="OR") {
        return State(Oregon);
      } else if(sn=="PENNSYLVANIA" || sn=="PA") {
        return State(Pennsylvania);
      } else if(sn=="RHODE ISLAN" || sn=="RI") {
        return State(RhodeIsland);
      } else if(sn=="SOUTH CAROLIN" || sn=="SC") {
        return State(SouthCarolina);
      } else if(sn=="SOUTH DAKOTA" || sn=="SD") {
        return State(SouthDakota);
      } else if(sn=="TENNESSEE" || sn=="TN") {
        return State(Tennessee);
      } else if(sn=="TEXAS" || sn=="TX") {
        return State(Texas);
      } else if(sn=="UTAH" || sn=="UT") {
        return State(Utah);
      } else if(sn=="VERMONT" || sn=="VT") {
        return State(Vermont);
      } else if(sn=="VIRGINIA" || sn=="VA") {
        return State(Virginia);
      } else if(sn=="WASHINGTON DC" || sn=="DC") {
        cout << "\nWashington DC uses Virginia's data\n";
        return State(Virginia);
      } else if(sn=="WASHINGTON" || sn=="WA") {
        return State(Washington);
      } else if(sn=="WEST VIRGINIA" || sn=="WV") {
        return State(WestVirginia);
      } else if(sn=="WISCONSIN" || sn=="WI") {
        return State(Wisconsin);
      } else if(sn=="WYOMING" || sn=="WY") {
        return State(Wyoming);
      } else {
        cout << errMsg;
        cont = true; // Continue the loop: ask them again, because they didn't enter a state
      }
    } // End check if they failed input
  } // End while
}