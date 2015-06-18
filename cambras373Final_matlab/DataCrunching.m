% DataCrunching.m
% Team CAMBRAS - Written by Jordan Argyle
% ME373 Spring 2015
% Final Project
% This file takes the state data (population, power production, emissions) and writes out a file
% that contains the best-fit coefficients (a,b,c,d...) for each function to a file. For each file,
% there is a row for each of the 50 states, and an extra row for total US data. Those fits, and the 
% file output format, is as follows:

% Population - Y_exp2 = a*exp(b*x)+c*exp(d*x)
% The population data is an excellent fit, for the most part, of a second-order exponential.

% StateID:                      ID from 0-50, 0=Alabama, 49=Wyoming, 50=All US (1), DC removed
% Population:                   a,b,c,d (2-5)

% Generation - Y_fourier3 = 
  % a0 + a1*cos(x*p)+b1*sin(x*p) + a2*cos(2*x*p)+b2*sin(2*x*p) + a3*cos(3*x*p)+b3*sin(3*x*p), where
  % p=kw, where k is the subscript on a,b (1,2, or 3)
% Generation data didn't match any kind of fit very well, but the best overall was a fourier fit. To
% make it so that I wasn't just fitting the data (high order fourier), I limited myself to 3, but I
% fear that I am still just trying to fit the dataset, and it wouldn't hold up historically. But,
% we'll assume that it doesn't change much +/- 50 years to either side, which is a terrible
% assumption. To clarify, generation data is divided between residential only, and all other so that
% we can make comparisons and give statistics for the user. ie "You're worse than the average person,
% and your total is only X% of the total used in your state because residental power use accounts 
% for only Y% of total power usage!" This also gives us more flexibility in data access.

% StateID:                      ID from 0-50, 0=Alabama, 49=Wyoming, 50=All US (1), DC removed
% Coal Residential Generation:  a,b,c,d (2-5)
% Natural Gas Residential Gen:  a,b,c,d (6-9)
% Other Resident'l Generation:  a,b,c,d (10-13)
% Clean Resident'l Generation:  a,b,c,d (14-17)
% Coal non-res Generation:      a,b,c,d (18-21)
% Natural Gas non-res Gen:      a,b,c,d (22-25)
% Other non-res Generation:     a,b,c,d (26-29)
% Clean non-res Generation:     a,b,c,d (30-33)

% Emission - Y_avg = avg
% There is no cuve to fit here. We are interested in the total overage emission / MWh produced, so
% we need to combine this with the fit data we got for generation (which is a very good fit for
% those few years, so it's a good assumption to make).

% Coal Emissions:               CO2,SO2,Nox (1-3)
% Natural Gas Emissions:        CO2,SO2,Nox (4-6)
% Other Emissions:              CO2,SO2,Nox (7-9)
% Clean Emissions:              CO2,SO2,Nox (10-12)

% Rough psudocode
% 1) Population data
%   a) Pull in population data
%   b) Create a best-fit curve for it
%   c) Write to file
% 2) Power Generation data
%   a) Pull in generation data
%   b) Separate it
%   c) Best-fit curve it
%   d) Write to file
% 3) Emissions data
%   a) Pull in emissions data
%   b) Separate it, average it over the years
%   c) Average it over the states
%   d) Write it out to file
% 4) Cost data--never coded
%   a) Pull in cost data
%   b) Separate it
%   c) Average it over the years
%   d) Best-fit curve it
%   e) Write it out to file

%% 1) Population data
% The population data looks at US census data from 1900 to 2000 plus 2001, 2002 for each state. We
% pull in that data, fit each state's history, and finish by writing out the coefficients for our
% regression to a file to easily pull it into C++.

%   1a) Pull in population data
% Inform user what's going on
fprintf('Importing historical state population data...');
pop = readtable('../Data/ResidentDataByState.csv','Delimiter',',');
% Sort the rows according to state code
pop = sortrows(pop,'Code');
fprintf('Done.\n\n');

%AL = pop{2,4:16}; % {} extracts data, rather than creating a table

%% After all that work, the goodness of fit using a polynomial is awful for all of them. In fact, I
% went from a second-order to a 3rd and the residuals got significantly worse. Looking again at 
% plots for the data, it was clear that the data is exponential, so I moved to a exponential curve
% fit. But since I don't know how to program that manually, so I instead used Matlab's function for
% it. At the bottom of this file is my older code for manually computing the 3-rd order polynomial
% fit, so you know that I can do it, but it wasn't useful.

%   1b) Create a best-fit curve for it

% Exponential model: exp1: Y = a*exp(b*x), exp2: Y = a*exp(b*x)+c*exp(d*x)
% First, we need a date vecor containing all 13 years included in this data. We adjust from using
% years down to 0-102 because otherwise our matrices are badly scaled (date-1900).
dates = [0:10:100, 101, 102];
pop.a = (pop.Code);
pop.b = (pop.Code ./2);
pop.c = (pop.Code ./3);
pop.d = (pop.Code ./4);
% Create a population matrix, not table, containing the data points only for plotting
popM  = zeros(52,13); % Holds the population data so we can check how good our corrilation is
reg   = zeros(52,13); % Holds our regression values so we can check how good our corrilation is
popgof= zeros(52,1);  % Holds our goodness of fit calculations

% Inform user what's going on
fprintf('Processing state population data--states remaining:');

% Loop through each state (including whole US and DC separately)
for i=1:52
  % Stuff data into the popM matrix
  popM(i,1:13)  = pop{i,4:16};
  % The fit. This requires column vectors and returns a column. We have to use a matrix for the x
  % values because Matlab cannot transpose values pulled from a table using the (pop{})' notation.
  f = fit( dates', (popM(i,1:13))', 'exp2', 'normalize', 'off');
  c = coeffvalues(f);
  % Store the coefficients
  pop(i,17) = table(c(1)); % a
  pop(i,18) = table(c(2)); % b
  pop(i,19) = table(c(3)); % c
  pop(i,20) = table(c(4)); % d
  
  % Note: Use date-1900 for accurate values. The fit was MUCH worse using actual dates than using
  % this "normalized" date method.
  reg(i,1:13) = f(dates);
  
  % Just checking that I do understand how the use the coefficients again. Faster to calculate using
  % the line above (feeding values into f), so this remains in comments to verify the C++
  % implimentation, as I won't have access to the cfit object (f).
  %for j=1:13
  %  reg(i,j) = c(1)*exp(c(2)*dates(j))+c(3)*exp(c(4)*dates(j));
  %end
  
  % Show uswer some progress
  fprintf('.');
  
  % Calculate goodness of fit variables
  st    = 0; % SUM( (yi-ybar)^2 )
  sr    = 0; % SUM( (yi,act-regi)^2 )
  sumy  = 0;
  for j=1:13
    sumy = sumy + popM(i,j);
  end
  ybar  = sumy/13;
  
  % Show user that something is happening
  fprintf('.');
  
  % Actually calculate the least-square goodness of fit (r^2)
  for j=1:13
    st = (popM(i,j)-ybar)^2;
    sr = (popM(i,j)-reg(i,j))^2;
  end
  popgof(i) = (st-sr)/st; % Store the goodness of fit value
  
  % Show the user that something is happening
  if(mod( (52-i),15 ) == 0 && (52-i)~=0)
    s = strcat('\n', num2str(52-i));
  else
    s = num2str(52-i);
  end
  fprintf(s);
end

% Put what we need to write out in pop, which will now be just a matrix, not a Table
popM = zeros(52,5);
for i=1:52
  popM(i,1:5)  = [i-2, pop{i,17:20}];
end
popM(52,:) = popM(1,:); % Put all state data in last row
pop = popM(2:52,:); % Delete first row, so that first row is Alabama

% Inform user, then clear variables that we no longer need.
fprintf('. Done.\n\n');

%   1c) Write it all out to files
% Let user know something is happening
fprintf('Writing population coefficients to ''/Data/StatePopCoefs.dat'': ');

% Final format for population file
% StateID:                      ID from 0-50, 0=Alabama, 49=Wyoming, 50=All US (1), DC removed
% Population:                   a,b,c,d (2-5)

% Create format: 1 int, 4 floats, new line, all separated with \t=tab
formatSpec = '%d\t%f\t%f\t%f\t%f\r\n';
fout = fopen('../Data/StatePopCoefs.dat','w');

% Actually write to file. This can't be included in the loop above because we're writing out the ith
% line, but we were bulding the (i-1)th line in the loop above, and we need the aggregate data as
% the last row.
for i=1:51
  fprintf( fout,formatSpec,[i,popM(i,:)] );
  % Show user something is happening
  fprintf('.');
end

% Inform user, then clear variables that we no longer need.
fprintf('\nDone.\n\n');

% Clean up. Be sure also to close the file.
fclose(fout); clear ans; % ans is returned whenever a file is opened.
clear c; clear dates; clear f; clear formatSpec; clear fout; clear i; clear j; clear popM;
clear reg; clear s; clear sr; clear st; clear sumy; clear ybar;

% Analysis: I first coded a 2rd order polynomial best fit for this, but the fit of coefficients was
% terrible. Upgrading to a 3rd order made the fit even worse, so I switched to using exponential
% fits. Using exp1 fit, I got 1 +/- .05 fit on most states, with DC being -480. Using exp2 fit,
% I got 1 +/- .05 for all states, most being within +/- .005 , and only -34 for DC. I decided to
% stick with that fit, and I will just ignore DC, because it's population history is pretty erratic
% and overall very small: we'll just turn any DC's entered into our program into Virginias.

% Total run time so far on home computer (average of three runs): 20.033 s

%% 2) Power Generation data
% Similar to population data, we'll be looking at each state separately. However, for power
% generation, it makes it easier to use the data is it is grouped in certain ways. Our four groups
% are coal, natural gas, other (anything else that is burned), and clean (non-burned fuel). It also
% makes sense to group the data by residential use only (since we're asking residents about their
% total use for residential applications), and all other (since I know that residential doesn't
% really cover a very large percentage of power used in many places). Because we have 4 groups in 2
% divisions, we have 8 times the data to crunch here (not to mention the file has over 40,000 data
% points), so this runs significantly slower than the population code.

%   2a) Pull in generation data
% Inform user what's going on
fprintf('Importing historical state power generation data...');
gen = readtable('../Data/AnnualGenerationByState.csv','Delimiter','/');
% Sort the rows according to state code
gen = sortrows(gen,'Code');
fprintf('Done.\n\n');

%%   2b) Separate it. Pull out just the residentential power generation
% First, prep the table. We need to convert these columns from cells to categories, so we can just
% check them using ==, rather than trying to compare strings.
gen.TYPEOFPRODUCER = categorical(gen.TYPEOFPRODUCER);
gen.ENERGYSOURCE = categorical(gen.ENERGYSOURCE);
% Now, pull off residental power generated
rows = gen.TYPEOFPRODUCER == 'Total Electric Power Industry';
resgen = gen(rows, {'YEAR', 'Code', 'ENERGYSOURCE', 'GENERATION_Megawatthours_'} );
% Pull off all other forms of power generation/usage. We need to add the logical arrays using bitor()
rows = gen.TYPEOFPRODUCER == 'Combined Heat and Power, Commercial Power';
rows = bitor(rows, gen.TYPEOFPRODUCER == 'Combined Heat and Power, Electric Power');
rows = bitor(rows, gen.TYPEOFPRODUCER == 'Combined Heat and Power, Industrial Power');
othgen = gen(rows, {'YEAR', 'Code', 'ENERGYSOURCE', 'GENERATION_Megawatthours_'} );

% We need a date vecor containing all 23 years included in this data. We adjust from using
% years down to 90-103 to improve matrices scaling (use date-1900). This scaling also puts our
% scaling the same as population data, making it easier to trasfer across.
dates = [90:1:113];

% Categories that we'll use in our analysis:
% Coal-the dirtiest, and one of the largest
% Natural Gas-relatively clean, also heavily used
% Other (Other, Other Biomass, Other Gases, Petroleum, Wood and Wood Derived Fuels) - grab-bag of
  % all other emission data. This is a simplifying assumption.
% Clean (Geothermal, Hydroelectric Conventional, Nuclear, Solar Thermal and Photovoltaic, Wind) -
  % We'll assume these produce essentially no emissions, as all are clean.

% Rather than using tables for this data, it actually is much easier to create some data matrices to
% handle all our data needs.
resM = zeros(52*4,24+32); % Holds generation data per state per generation cat (see above) per year...
othM = zeros(52*4,24+32); % ...to help us aggrigate our data. Extra 32 columns hold fourier model coefs.
reg  = zeros(2,24); % Holds our regression values for Res (row 1) and Oth (row 2) for current iteration
resgof = zeros(52,4); % Holds our goodness of fit calculation for residential data
othgof = zeros(52,4); % Holds our goodness of fit calculation for other data

% Inform user what's going on
fprintf('Processing state power generation data--states remaining:');

% Populate our tables and matrices. Loop through each state. We use the state code (ID) to index.
for i=-1:50 % State Codes (plus DC-50 and All USA- -1)
  % Get a table of just the state we're interested in
  rows = resgen.Code == i;
  tempR = resgen(rows, {'YEAR', 'ENERGYSOURCE', 'GENERATION_Megawatthours_'} );
  rows = othgen.Code == i;
  tempO = othgen(rows, {'YEAR', 'ENERGYSOURCE', 'GENERATION_Megawatthours_'} );
  
  % Loop through the years to build rows for each category and state
  for j=1990:2013
    % Category 1: Coal. First, lets get residential
    rows = tempR.ENERGYSOURCE == 'Coal' & tempR.YEAR == j;
    temp = tempR.GENERATION_Megawatthours_(rows);
    resM(4*i+5,j-1989) = sum(temp);
    % Now, other
    rows = tempO.ENERGYSOURCE == 'Coal' & tempO.YEAR == j;
    temp = tempO.GENERATION_Megawatthours_(rows);
    othM(4*i+5,j-1989) = sum(temp);
    
    % Cat. 2: Natural Gas. First, lets get residential
    rows = tempR.ENERGYSOURCE == 'Natural Gas' & tempR.YEAR == j;
    temp = tempR.GENERATION_Megawatthours_(rows);
    resM(4*i+6,j-1989) = sum(temp);
    % Now, other
    rows = tempO.ENERGYSOURCE == 'Natural Gas' & tempO.YEAR == j;
    temp = tempO.GENERATION_Megawatthours_(rows);
    othM(4*i+6,j-1989) = sum(temp);
    
    % Cat. 3: Other (Other, Other Biomass, Other Gases, Petroleum, Wood and Wood Derived Fuels)
    rows = tempR.ENERGYSOURCE == 'Other' & tempR.YEAR == j;
    rows = bitor(rows, tempR.ENERGYSOURCE == 'Other Biomass' & tempR.YEAR == j);
    rows = bitor(rows, tempR.ENERGYSOURCE == 'Other Gases' & tempR.YEAR == j);
    rows = bitor(rows, tempR.ENERGYSOURCE == 'Petroleum' & tempR.YEAR == j);
    rows = bitor(rows, tempR.ENERGYSOURCE == 'Wood and Wood Derived Fuels' & tempR.YEAR == j);
    temp = tempR.GENERATION_Megawatthours_(rows);
    resM(4*i+7,j-1989) = sum(temp);
    % Now, other
    rows = tempO.ENERGYSOURCE == 'Other' & tempO.YEAR == j;
    rows = bitor(rows, tempO.ENERGYSOURCE == 'Other Biomass' & tempO.YEAR == j);
    rows = bitor(rows, tempO.ENERGYSOURCE == 'Other Gases' & tempO.YEAR == j);
    rows = bitor(rows, tempO.ENERGYSOURCE == 'Petroleum' & tempO.YEAR == j);
    rows = bitor(rows, tempO.ENERGYSOURCE == 'Wood and Wood Derived Fuels' & tempO.YEAR == j);
    temp = tempO.GENERATION_Megawatthours_(rows);
    othM(4*i+7,j-1989) = sum(temp);
    
    % Cat. 4: Clean (Geothermal, Hydroelectric Conventional, Nuclear, Solar Thermal and Photovoltaic, Wind) 
    rows = tempR.ENERGYSOURCE == 'Geothermal' & tempR.YEAR == j;
    rows = bitor(rows, tempR.ENERGYSOURCE == 'Hydroelectric Conventional' & tempR.YEAR == j);
    rows = bitor(rows, tempR.ENERGYSOURCE == 'Nuclear' & tempR.YEAR == j);
    rows = bitor(rows, tempR.ENERGYSOURCE == 'Solar Thermal and Photovoltaic' & tempR.YEAR == j);
    rows = bitor(rows, tempR.ENERGYSOURCE == 'Wind' & tempR.YEAR == j);
    temp = tempR.GENERATION_Megawatthours_(rows);
    resM(4*i+8,j-1989) = sum(temp);
    % Now, other
    rows = tempO.ENERGYSOURCE == 'Geothermal' & tempO.YEAR == j;
    rows = bitor(rows, tempO.ENERGYSOURCE == 'Hydroelectric Conventional' & tempO.YEAR == j);
    rows = bitor(rows, tempO.ENERGYSOURCE == 'Nuclear' & tempO.YEAR == j);
    rows = bitor(rows, tempO.ENERGYSOURCE == 'Solar Thermal and Photovoltaic' & tempO.YEAR == j);
    rows = bitor(rows, tempO.ENERGYSOURCE == 'Wind' & tempO.YEAR == j);
    temp = tempO.GENERATION_Megawatthours_(rows);
    othM(4*i+8,j-1989) = sum(temp);
  end % loop through years
  
  % Make sure user knows that something is happening, because this next part will be SLOW
  fprintf('.');
  
  %   2c) Best-fit curve it. We're using a third-order fourier of the form:
  % a0 + a1*cos(x*p)+b1*sin(x*p) + a2*cos(2*x*p)+b2*sin(2*x*p) + a3*cos(3*x*p)+b3*sin(3*x*p), where
  % p=kw, where k is the subscript on a,b
  % Loop through each of the four categories, developing a best-fit for them, saving coefs as we go.
  
  for j=1:4
    % Start with residential
    f = fit( dates', (resM(4*i+j+4,1:24))', 'fourier3', 'normalize', 'off');
    c = coeffvalues(f);
    resM(4*i+j+4, 8*j+21) = c(1); % a0 in 25, 33, 41, 49
    resM(4*i+j+4, 8*j+22) = c(2); % a1 in 26, 34, 42, 50
    resM(4*i+j+4, 8*j+23) = c(3); % b1 in 27, 35, 43, 51
    resM(4*i+j+4, 8*j+24) = c(4); % a2 in 28, 36, 44, 52
    resM(4*i+j+4, 8*j+24) = c(5); % b2 in 29, 37, 45, 53
    resM(4*i+j+4, 8*j+24) = c(6); % a3 in 30, 38, 46, 54
    resM(4*i+j+4, 8*j+24) = c(7); % b3 in 31, 39, 47, 55
    resM(4*i+j+4, 8*j+24) = c(8); % w  in 32, 40, 48, 56
    reg(1,1:24) = f(dates);
    
    % Test my fourierFit function. It's good.
    %EG=fourierFit( c(1),c(2),c(3),c(4),c(5),c(6),c(7),c(8), dates(1) );
    %disp( strcat( 'THE VALUES:...',num2str(reg(1,1)),'...', num2str(EG) ) );
    
    % Do other
    f = fit( dates', (othM(4*i+j+4,1:24))', 'fourier3', 'normalize', 'off');
    c = coeffvalues(f);
    othM(4*i+j+4, 8*j+21) = c(1); % a0 in 25, 33, 41, 49
    othM(4*i+j+4, 8*j+22) = c(2); % a1 in 26, 34, 42, 50
    othM(4*i+j+4, 8*j+23) = c(3); % b1 in 27, 35, 43, 51
    othM(4*i+j+4, 8*j+24) = c(4); % a2 in 28, 36, 44, 52
    othM(4*i+j+4, 8*j+24) = c(5); % b2 in 29, 37, 45, 53
    othM(4*i+j+4, 8*j+24) = c(6); % a3 in 30, 38, 46, 54
    othM(4*i+j+4, 8*j+24) = c(7); % b3 in 31, 39, 47, 55
    othM(4*i+j+4, 8*j+24) = c(8); % w  in 32, 40, 48, 56
    reg(2,1:24) = f(dates);
  
    % Let the user know that something is happening
    fprintf('.');
    
    % Calculate goodness of fit variables
    stR   = 0;
    srR   = 0;
    stO   = 0;
    srO   = 0;
    sumyR = 0;
    sumyO = 0;
    for k=1:24
      sumyR = sumyR + resM(4*i+j+4,k);
      sumyO = sumyO + othM(4*i+j+4,k);
    end
    ybarR = sumyR/24;
    ybarO = sumyO/24;
    
    % Actually calculate the least-square goodness of fit (r^2)
    for k=1:24
      stR = (resM(4*i+j+4,k)-ybarR)^2;
      srR = (resM(4*i+j+4,k)-reg(1,k))^2;
      stO = (othM(4*i+j+4,k)-ybarO)^2;
      srO = (othM(4*i+j+4,k)-reg(2,k))^2;
    end
    resgof(i+2,j) = (stR-srR)/stR;
    othgof(i+2,j) = (stO-srO)/stO;
  end % looping through groups
  
  % Let the user know somehting is happening
  if(mod( (50-i),15 ) == 0 && (50-i) ~= 0)
    s = strcat('\n', num2str(50-i));
  else
    s = num2str(50-i);
  end
  fprintf(s);
end % loop through states

% Format output to have all coefficients in 52 rows
for i=1:52
  resM(i,24) = i-2;                    % State ID
  resM(i, 25:32) = resM(4*i-3, 25:32); % Coal generation coefficients
  resM(i, 33:40) = resM(4*i-2, 33:40); % Natural gas generation coefficients
  resM(i, 41:48) = resM(4*i-1, 41:48); % Other burned fuel generation coefficients
  resM(i, 49:56) = resM(4*i,   49:56); % Clean generation coefficients
  othM(i,24) = i-2;                    % State ID
  othM(i, 25:32) = othM(4*i-3, 25:32); % Coal generation coefficients
  othM(i, 33:40) = othM(4*i-2, 33:40); % Natural gas generation coefficients
  othM(i, 41:48) = othM(4*i-1, 41:48); % Other burned fuel generation coefficients
  othM(i, 49:56) = othM(4*i,   49:56); % Clean generation coefficients
end
% Move all state data to bottom by copying the row then deleting the row
resM(52,:) = resM(1,:);
resgof(52,:) = resgof(1,:);
othM(52,:) = othM(1,:);
othgof(52,:) = othgof(1,:);
% Assign the condenced form of the data to the variables we're keeping
resgen = resM(2:52,24:56);
resgof = resgof(2:52,:);
othgen = othM(2:52,24:56);
othgof = othgof(2:52,:);

% Inform user, then clear variables that we no longer need.
fprintf('. Done.\n\n');

%   d) Write to file
% Let user know something is happening
fprintf('Writing population coefficients to ''/Data/StatePopCoefs.dat'': ');

% Create format: 1 int, 32 floats, new line, all separated with \t=tab
formatSpec = '%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t';
formatSpec = strcat(formatSpec, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n');
fout = fopen('../Data/StateGenCoefs.dat','w');

% Final output format for generation data:
% StateID:                      ID from 0-50, 0=Alabama, 49=Wyoming, 50=All US (1), DC removed
% Coal Residential Generation:  a,b,c,d (2-5)
% Natural Gas Residential Gen:  a,b,c,d (6-9)
% Other Resident'l Generation:  a,b,c,d (10-13)
% Clean Resident'l Generation:  a,b,c,d (14-17)
% Coal non-res Generation:      a,b,c,d (18-21)
% Natural Gas non-res Gen:      a,b,c,d (22-25)
% Other non-res Generation:     a,b,c,d (26-29)
% Clean non-res Generation:     a,b,c,d (30-33)

% Actually write to file. This can't be included in the loop above because we're writing out the ith
% line, but we were bulding the (i-1)th line in the loop above.
for i=1:51
  fprintf( fout,formatSpec,[resgen(i,:), othgen(i,:)] );
  fprintf('.');
end

% Inform user, then clear variables that we no longer need.
fprintf('\nDone.\n\n');

% Be sure also to close the file.
fclose(fout); clear ans; clear formatSpec; clear fout;
clear c; clear gen; clear f; clear i; clear j; clear k;  clear reg; clear rows; clear temp; clear s;
clear othM; clear srO; clear stO; clear sumyO, clear tempO; clear ybarO; clear dates;
clear resM; clear srR; clear stR; clear sumyR; clear tempR; clear ybarR; 

% Analysis: I tried every different model that matlab had in it's toolboxes that I could find, and 
% I even tried creating my own functions for a few times. Plots of the data were just too erratic to
% be able to find a good fit, so I finally settled on a low-ish order fourier, since it's r^2 values
% for the data set were the best of any other fit (besides very high-order polynomial fits). My
% general error is within 0.1 of 1, but there are some generation categories that certain states do
% not have, leading to NaN, and other states show that they are clearly not periodic at all, leading
% to a far worse r^2 (+/- hundreds). End result: I feel that it's mostly good enough to again just
% export the coefficients.

% Total additional runtime (average of three runs): 89.8450 s = 1:29.8450
% From beginning to here (average of three runs): 108.8097 s = 1:48.8097

%% 3) Emissions data
% Here, we'll be calculating total averages for each pollutant based on MWh produced. We aren't 
% interested in historical trends. Rather than again crunch the generation data, I'm just going
% to use my regression from 2), even though in places it is grossly inaccurate. I figure that, by
% and large, this will be pretty good for the given dataset. This data goes from 1990-2012.

%   3a) Pull in emissions data
% Inform user what's going on
fprintf('Importing emission data...');
ems = readtable('../Data/AnnualEmissionByState.csv','Delimiter','/');
% Sort the rows according to state code
ems = sortrows(ems,'Code');
fprintf('Done.\n\n');

%%   3b) Separate it. We're only interested in emissions for the 4 groups
% First, prep the table. We need to convert these columns from cells to categories, so we can just
% check it using ==, rather than trying to compare strings.
ems.EnergySource = categorical(ems.EnergySource);

% Now, pull off each category
% Rather than using tables for this data, it actually is much easier to create a data matrix to
% handle all our data needs.
catM = zeros(52,4*3); % Holds emission data per state per generation category for CO2, SO2, Nox

% We need a date vecor containing all 22 years included in this data. We adjust from using
% years down to 90-103 to improve matrices scaling (use date-1900). This scaling also puts our
% scaling the same as population data, making it easier to trasfer across.
dates = [90:1:112];

% Inform user what's going on
fprintf('Processing emissions data--states remaining:');

%   3b) Separate it, average it over the years.
% Populate our tables and matrices. Loop through each state. State code (ID)=index.
for i=0:49 % State Codes (plus DC-50 and All USA- -1), we're skipping DC and all
  % Get a table of just the state we're interested in
  rows = ems.Code == i+1;
  tempE = ems(rows, {'Year', 'EnergySource', 'CO2', 'SO2', 'Nox'} );
  
  % Loop through the years to build rows for each category and state
  for j=1990:2012    
    % Category 1: Coal. First, grab the emissions for coal, and add them up
    rows = tempE.EnergySource == 'Coal' & tempE.Year == j;
    tempEs = [ tempE.CO2(rows), tempE.SO2(rows), tempE.Nox(rows) ];
    if(isempty(tempEs))
      % There is no generation for that type. Thus:
      tempEs = [0,0,0]; % No emissions, no generation
    else
      % We do have some generation for that type, and need to add all emissions together
      tempEs = [ sum( tempEs(1) ), sum( tempEs(2) ), sum( tempEs(3) ) ];
    end
    
    % Coal coefs: [a0,a1,b1,a2,b2,a3,b3,w]
    coefs = [resgen(i+1,2), resgen(i+1,3), resgen(i+1,4), resgen(i+1,5)];               
    coefs = [coefs, resgen(i+1,6), resgen(i+1,7), resgen(i+1,8), resgen(i+1,9)];
    g1 = fourierFit( [coefs,(j-1900)] );
    % Non-residential generation
    coefs = [othgen(i+1,2), othgen(i+1,3), othgen(i+1,4), othgen(i+1,5)];
    coefs = [coefs, othgen(i+1,6), othgen(i+1,7), othgen(i+1,8), othgen(i+1,9)];
    g2 = fourierFit( [coefs,(j-1900)] );
    
    % Total amount generated
    gen = abs(g1)+abs(g2);

    % Amount of each pollutant per MWh produced, Metric tons
    catM(i+1,1) = tempEs(1)/gen;
    catM(i+1,2) = tempEs(2)/gen;
    catM(i+1,3) = tempEs(3)/gen;
    
    % Cat. 2: Natural Gas. First, grab the emissions and add them up
    rows = tempE.EnergySource == 'Natural Gas' & tempE.Year == j;
    tempEs = [ tempE.CO2(rows), tempE.SO2(rows), tempE.Nox(rows) ];
    if(isempty(tempEs))
      % There is no generation for that type. Thus:
      tempEs = [0,0,0]; % No emissions, no generation
    else
      % We do have some generation for that type, and need to add all emissions together
      tempEs = [ sum( tempEs(1) ), sum( tempEs(2) ), sum( tempEs(3) ) ];
    end
    
    % Natural gas coefs: [a0,a1,b1,a2,b2,a3,b3,w]
    coefs = [resgen(i+1,10), resgen(i+1,11), resgen(i+1,12), resgen(i+1,13)];               
    coefs = [coefs, resgen(i+1,14), resgen(i+1,15), resgen(i+1,16), resgen(i+1,17)];
    g1 = fourierFit( [coefs,(j-1900)] );
    % Non-residential generation
    coefs = [othgen(i+1,10), othgen(i+1,11), othgen(i+1,12), othgen(i+1,13)];
    coefs = [coefs, othgen(i+1,14), othgen(i+1,15), othgen(i+1,16), othgen(i+1,17)];
    g2 = fourierFit( [coefs,(j-1900)] );
    
    % Total amount generated
    gen = g1+g2;
    
    % Amount of each pollutant per MWh produced, Metric tons
    catM(i+1,4) = tempEs(1)/gen;
    catM(i+1,5) = tempEs(2)/gen;
    catM(i+1,6) = tempEs(3)/gen;
    
    % Cat. 3: Other (Other, Other Biomass, Other Gases, Petroleum, Wood and Wood Derived Fuels)
    % First, grab the emissions and add them up
    rows = tempE.EnergySource == 'Other' & tempE.Year == j;
    rows = bitor(rows, tempE.EnergySource == 'Other Biomass' & tempE.Year == j);
    rows = bitor(rows, tempE.EnergySource == 'Other Gases' & tempE.Year == j);
    rows = bitor(rows, tempE.EnergySource == 'Petroleum' & tempE.Year == j);
    rows = bitor(rows, tempE.EnergySource == 'Wood and Wood Derived Fuels' & tempE.Year == j);
    tempEs = [ tempE.CO2(rows), tempE.SO2(rows), tempE.Nox(rows) ];
    if(isempty(tempEs))
      % There is no generation for that type. Thus:
      tempEs = [0,0,0]; % No emissions, no generation
    else
      % We do have some generation for that type, and need to add all emissions together
      tempEs = [ sum( tempEs(1) ), sum( tempEs(2) ), sum( tempEs(3) ) ];
    end
    
    % Other coefs: [a0,a1,b1,a2,b2,a3,b3,w]
    coefs = [resgen(i+1,18), resgen(i+1,19), resgen(i+1,20), resgen(i+1,21)];               
    coefs = [coefs, resgen(i+1,22), resgen(i+1,23), resgen(i+1,24), resgen(i+1,25)];
    g1 = fourierFit( [coefs,(j-1900)] );
    % Non-residential generation
    coefs = [othgen(i+1,18), othgen(i+1,19), othgen(i+1,20), othgen(i+1,21)];
    coefs = [coefs, othgen(i+1,22), othgen(i+1,23), othgen(i+1,24), othgen(i+1,25)];
    g2 = fourierFit( [coefs,(j-1900)] );
    
    % Total amount generated
    gen = g1+g2;
    
    % Amount of each pollutant per MWh produced, Metric tons
    catM(i+1,7) = tempEs(1)/gen;
    catM(i+1,8) = tempEs(2)/gen;
    catM(i+1,9) = tempEs(3)/gen;
    
    % Cat. 4: Clean (Geothermal, Hydroelectric Conventional, Nuclear, Solar Thermal and Photovoltaic,
    % Wind). First, grab the emissions and add them up
    rows = tempE.EnergySource == 'Geothermal' & tempE.Year == j;
    rows = bitor(rows, tempE.EnergySource == 'Hydroelectric Conventional' & tempE.Year == j);
    rows = bitor(rows, tempE.EnergySource == 'Nuclear' & tempE.Year == j);
    rows = bitor(rows, tempE.EnergySource == 'Solar Thermal and Photovoltaic' & tempE.Year == j);
    rows = bitor(rows, tempE.EnergySource == 'Wind' & tempE.Year == j);
    tempEs = [ tempE.CO2(rows), tempE.SO2(rows), tempE.Nox(rows) ];
    if(isempty(tempEs))
      % There is no generation for that type. Thus:
      tempEs = [0,0,0]; % No emissions, no generation
    else
      % We do have some generation for that type, and need to add all emissions together
      tempEs = [ sum( tempEs(1) ), sum( tempEs(2) ), sum( tempEs(3) ) ];
    end
    
    % Coal coefs: [a0,a1,b1,a2,b2,a3,b3,w]
    coefs = [resgen(i+1,26), resgen(i+1,27), resgen(i+1,28), resgen(i+1,29)];               
    coefs = [coefs, resgen(i+1,30), resgen(i+1,31), resgen(i+1,32), resgen(i+1,33)];
    g1 = fourierFit( [coefs,(j-1900)] );
    % Non-residential generation
    coefs = [othgen(i+1,26), othgen(i+1,27), othgen(i+1,28), othgen(i+1,29)];
    coefs = [coefs, othgen(i+1,30), othgen(i+1,31), othgen(i+1,31), othgen(i+1,33)];
    g2 = fourierFit( [coefs,(j-1900)] );
    
    % Total amount generated
    gen = g1+g2;
    
    % Amount of each pollutant per MWh produced, Metric tons
    catM(i+1,10) = tempEs(1)/gen;
    catM(i+1,11) = tempEs(2)/gen;
    catM(i+1,12) = tempEs(3)/gen;
    
    % Corect for any NaN or infinity's that are produced
    for k=1:12
      if( isinf(catM(i+1,k)) || isnan(catM(i+1,k)) )
        catM(i+1,k) = 0;
      end
    end
    
  end % loop through years
  
%   3c) Average it over the states
  for j=2:52
    for k=1:12
      catM(1,k) = catM(1,k) + catM(j,k);
    end
  end
  
  % Let the user know somehting is happening
  if(mod( (50-i),15 ) == 0 && (50-i) ~= 0)
    s = strcat('\n', num2str(50-i));
  else
    s = strcat('..', num2str(50-i) );
  end
  fprintf(s);
end % loop through states

ems = catM(1,:);

%   3d) Write it out to file
% Create format: 12 floats
formatSpec = '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f';
fout = fopen('../Data/EmissionPerMWh.dat','w');

% Final output format for emissions data:
% Coal Emissions:               CO2,SO2,Nox (1-3)
% Natural Gas Emissions:        CO2,SO2,Nox (4-6)
% Other Emissions:              CO2,SO2,Nox (7-9)
% Clean Emissions:              CO2,SO2,Nox (10-12)

% Actually write to file.
fprintf( fout,formatSpec,ems(1,:) );
  
% Inform user, then clear variables that we no longer need.
fprintf('. Done.\n\nWritten to file.\n\n');

% Be sure also to close the file.
fclose(fout); clear ans; clear formatSpec; clear fout;
clear catM; clear coefs; clear dates; clear g1; clear g2; clear gen; clear i; clear j; clear k;
clear rows; clear s; clear tempE; clear tempEs;

% Analysis: This may be seeing too much error compounding, as I don't trust a lot of these values.
% However, aside from just saving the raw generation data from 2), I don't see a good way to improve
% this.

% % Total additional runtime (average of three runs): 39.3810 s
% % From beginning to here (average of three runs): 149.5630 s = 2:29.5630

%% 4) Cost data
% This was never implimented, because my team decided they they aren't going to use my data
% anyway, so there's no point in wasting the time to generate this data. Besides, you get the idea:
% it's more of the above.
%   a) Pull in cost data
%   b) Separate it
%   c) Average it over the years
%   d) Best-fit curve it
%   e) Write it out to file

%% Bid farewell to user
fprintf('Thanks for crunching data with me! The data is now exported, and ready to be used in C++.');
fprintf('\nGoodbye\n');
%FIN

%% NOTES

% % First, we need a date vecor containing all 13 years included in this data. We adjust from using
% % years down to 90-113 because otherwise our matrices are badly scaled (date-1900)
% dates = [90:1:113];
% % THE BELOW CREATES A 3RD ORDER POLYNOMIAL BEST FIT, BUT THE GOODNESS OF IT WASN'T TOO GOOD. I
% % LEAVE THIS IN TO SHOW THAT I KNOW HOW TO CODE IT. ORIGINALLY WRITTEN FOR POP DATA
% % Prep other variables needed to caclulate quadratic regression
% n = length(dates);
% sumx = 0;
% sumx2= 0;
% sumx3= 0;
% sumx4= 0;
% sumx5= 0;
% sumx6= 0;
% for i=1:n
%   sumx = sumx  + dates(i);
%   sumx2= sumx2 + dates(i)^2;
%   sumx3= sumx3 + dates(i)^3;
%   sumx4= sumx4 + dates(i)^4;
%   sumx5= sumx5 + dates(i)^5;
%   sumx6= sumx6 + dates(i)^6;
% end
% M = [  n    sumx   sumx2  sumx3
%      sumx   sumx2  sumx3  sumx4
%      sumx2  sumx3  sumx4  sumx5
%      sumx3  sumx4  sumx5  sumx6];
% Minv = inv(M);
% % Create a0,a1,a2 columns in pop
% pop.a0 = (pop.Code);
% pop.a1 = (pop.Code ./2);
% pop.a2 = (pop.Code ./3);
% pop.a3 = (pop.Code ./4);
% % Create a population matrix, not table, containing the data points only for plotting
% popM = zeros(52,13); % Holds the population data so we can check how good our corrilation is
% reg  = zeros(52,13); % Holds our regression values so we can check how good our corrilation is
% gof  = zeros(52,1); % Holds our goodness of fit measurement
% 
% % Loop through each state (including whole US and DC separately)
% for i=1:52
%   sumy  = 0;
%   sumxy = 0;
%   sumx2y= 0;
%   sumx3y= 0;
%   % Loop through each state's decade-ly data
%   for j=4:16
%     sumy  = sumy  + pop{i,j}; % SUM(yi)
%     sumxy = sumxy + dates(j-3)*pop{i,j}; % SUM(xi*yi)
%     sumx2y= sumx2y+ dates(j-3)^2*pop{i,j}; % SUM(xi^2*yi)
%     sumx3y= sumx3y+ dates(j-3)^3*pop{i,j}; % SUM(xi^2*yi)
%   end
%   
%   % Create b vector for [M]{a}={b}
%   b = [sumy; sumxy; sumx2y; sumx3y];
%   % I was going to use LU decomp for this next part, since I have 52 right-hand-side vectors, but
%   % I figured I'd just compute M^-1 once and use it. However, using M\b is more accurate than doing
%   % (M^-1)*b, and not much slower for loops shorter than multiple hundred, so that's what I'm using.
%   a = M\b;
%   % Turn them into table elements so we can insert them 
%   pop(i,17) = table( a(1) );
%   pop(i,18) = table( a(2) );
%   pop(i,19) = table( a(3) );
%   pop(i,20) = table( a(4) );
%   
%   % Stuff data into the popM matrix
%   popM(i,1:13) = pop{i,4:16};
%   
%   % Double-check what Matlab's polyfit finds
%   %a = polyfit(dates, popM(i,1:13), 2)
%   reg(i,1:13) = polyval( [a(4),a(3),a(2),a(1)], popM(i,1:13) );
%   
%   % Calculate goodness of fit
%   st    = 0;
%   sr    = 0;
%   ybar  = sumy/13;
%   for j=4:16
%     st = (pop{i,j}-ybar)^2;
%     sr = (pop{i,j}-reg(i,j-3));
%   end
%   gof(i) = (st-sr)/st;
% end