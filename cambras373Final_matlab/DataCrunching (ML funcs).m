% DataCrunching.m
% Team CAMBRAS - Written by Jordan Argyle
% ME373 Spring 2015
% Final Project
% This file takes the state data (population, power production, emissions) and writes out a file
% that contains 4 coefficients (a,b,c,d) per function that are plugged into a second-order
% exponential curve-fit: Y,exp2 = a*exp(b*x)+c*exp(d*x). There is a row for all 50 states, and an 
% extra row for total US data. The row indices are, in order:
% StateID:    ID from 0-50, 0=Alabama, 49=Wyoming, 50=All US (1)
% Population:                   a,b,c,d (2-5)
% Coal Residential Generation:  a,b,c,d (6-9)
% Natural Gas Residential Gen:  a,b,c,d (10-13)
% Other Resident'l Generation:  a,b,c,d (14-17)
% Clean Resident'l Generation:  a,b,c,d (18-21)
% Coal non-res Generation:      a,b,c,d (22-25)
% Natural Gas non-res Gen:      a,b,c,d (26-29)
% Other non-res Generation:     a,b,c,d (30-33)
% Clean non-res Generation:     a,b,c,d (34-37)

% To clarify, generation data is divided between residential only, and all other so that we can make
% comparisons and give statistics for the user.

% Rough psudocode
% 1) Population data
%   a) Pull in population data
%   b) Create a best-fit curve for it
% 2) Power Generation data
%   a) Pull in generation data
%   b) Separate it
%   c) Best-fit curve it
% 3) Emissions data
%   a) Pull in emissions data
%   b) Separate it
%   c) Best-fit curve it
% 4) Cost data
%   a) Pull in cost data
%   b) Separate it
%   c) Best-fit curve it
% 5) Combine everything and write out file
%   a) Combine everything
%   b) Write it to file

%% 1) Population data - pull it in
%   1a) Pull in population data
% Inform user what's going on
fprintf('Importing historical state population data...');
pop = readtable('../Data/ResidentDataByState.csv','Delimiter',',');
% Sort the rows according to state code
pop = sortrows(pop,'Code');
fprintf('Done.\n');

%   1b) Create a best-fit curve for it
% First, we need a date vecor containing all 13 years included in this data. We adjust from using
% years down to 0-102 because otherwise our matrices are badly scaled (date-1900)
% dates = [0:10:100, 101, 102];
% % THE BELOW CREATES A 3RD ORDER POLYNOMIAL BEST FIT, BUT THE GOODNESS OF IT FOR A POLYNOMIAL FIT IS
% % TERRIBLE, THEREFORE THE BELOW IS ABANDONED. CONTINUE TO NEXT SECTION (begins %%)
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

%AL = pop{2,4:16}; % {} extracts data, rather than creating a table

%% After all that work, the goodness of fit is awful for all of them. In fact, I went from a second
% -order to a 3rd and the residuals got significantly worse. I need to do a exponential curve fit,
% but I don't know how to program that manually, so I instead used Matlab's function for it.

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
popgof= zeros(52,1); % Holds our goodness of fit measurement

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
  % the line above (feeding values into f), so this remains in comments.
  %for j=1:13
  %  reg(i,j) = c(1)*exp(c(2)*dates(j))+c(3)*exp(c(4)*dates(j));
  %end
  
  % Show uswer some progress
  fprintf('.');
  
  % Calculate goodness of fit variables
  st    = 0; % SUM( (yi-ybar)^2 )
  sr    = 0; % SUM( (yi,act-regi)^2 )
  sumy  = 0;
  for j=4:16
    sumy = sumy + pop{i,j};
  end
  ybar  = sumy/13;
  
  % Show user that something is happening
  fprintf('.');
  
  % Actually calculate the least-square goodness of fit (r^2)
  for j=4:16
    st = (pop{i,j}-ybar)^2;
    sr = (pop{i,j}-reg(i,j-3))^2;
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
popM = zeros(52,4);
for i=1:52
  popM(i,1:4)  = pop{i,17:20};
end
pop = popM;

% Inform user, then clear variables that we no longer need.
fprintf('. Done.\n\n');

clear c; clear dates; clear f; clear i; clear j; clear popM;
clear reg; clear sr; clear st; clear sumy; clear ybar; clear s;

% Analysis: Using exp1 fit, I got 1 +/- .05 fit on most states, with DC being -480. Using exp2 fit,
% I got 1 +/- .05 for all states, most being within +/- .005 , and only -34 for DC. I'm sticking
% with that fit, and I will just ignore DC, because it's pretty erratic and overall very small.
% We'll just turn any DC's entered into our program into Virginias.

% Total run time so far on home computer: 18.418 s

%% 2) Power Generation data
%   2a) Pull in generation data
% Inform user what's going on
fprintf('Importing historical state power generation data...');
gen = readtable('../Data/AnnualGenerationByState.csv','Delimiter','/');
% Sort the rows according to state code
gen = sortrows(gen,'Code');
fprintf('Done.\n');

%%   2b) Separate it. Pull out just the residentential power generation
% First, prep the table. We need to convert these columns from cells to categories, so we can just
% check them using ==, rather than trying to compare strings.
gen.TYPEOFPRODUCER = categorical(gen.TYPEOFPRODUCER);
gen.ENERGYSOURCE = categorical(gen.ENERGYSOURCE);
% Now, pull off residental power generated
rows = gen.TYPEOFPRODUCER == 'Total Electric Power Industry';
resgen = gen(rows, {'YEAR', 'Code', 'ENERGYSOURCE', 'GENERATION_Megawatthours_'} );
% Pull of all other forms of power generation/usage. We need to add the logical arrays using bitor()
rows = gen.TYPEOFPRODUCER == 'Combined Heat and Power, Commercial Power';
rows = bitor(rows, gen.TYPEOFPRODUCER == 'Combined Heat and Power, Electric Power');
rows = bitor(rows, gen.TYPEOFPRODUCER == 'Combined Heat and Power, Industrial Power');
othgen = gen(rows, {'YEAR', 'Code', 'ENERGYSOURCE', 'GENERATION_Megawatthours_'} );

% Polynomial model: pol9: Y = p1*x^9+p2*x^8+...+p10
% We need a date vecor containing all 23 years included in this data. We adjust from using
% years down to 90-103 to improve matrices scaling (use date-1900). This scaling also puts our
% scaling the same as population data, so we can have a common C++ function to use both datasets.
dates = [90:1:113];

% Categories that we'll use in our analysis:
% Coal-the dirtiest, with lots of emission data
% Natural Gas-relatively clean, also lots of emission data
% Other (Other, Other Biomass, Other Gases, Petroleum, Wood and Wood Derived Fuels) - grab-bag of
  % all other emission data. This is a simplifying assumption.
% Clean (Geothermal, Hydroelectric Conventional, Nuclear, Solar Thermal and Photovoltaic, Wind) -
  % We'll assume these produce no emissions, as all are clean.

% Rather than using tables for this data, it actually is much easier to create some data matrices to
% handle all our data needs.
resM = zeros(52*4,24+16); % Holds generation data per state per generation cat (see above) per year...
othM = zeros(52*4,24+16); % ...to help us aggrigate our data. Extra 16 columns hold exp2 model coefs.
reg  = zeros(2,24); % Holds our regression values for Res (row 1) and Oth (row 2) for current iteration
resgof = zeros(52,4); % Holds our goodness of fit measurement for residential data
othgof = zeros(52,4); % Holds our goodness of fit measurement for other data
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
  end % loop through states
  
  % Make sure user knows that something is happening, because this next part will be SLOW
  fprintf('.');
  
  % Loop through each of the four categories, and develop a best-fit for them. We're going to use
  % exp2 again (better results).
  fs = {};
  fo = {};
  for j=1:4
    % Start with residential
    f = fit( dates', (resM(4*i+j+4,1:24))', 'poly9', 'normalize', 'on');
    c = coeffvalues(f);
    resM(4*i+j+4, 4*j+21) = c(1); % a in 25, 29, 33, 37
    resM(4*i+j+4, 4*j+22) = c(2); % b in 26, 30, 34, 38
    resM(4*i+j+4, 4*j+23) = c(3); % c in 27, 31, 35, 39
    resM(4*i+j+4, 4*j+24) = c(4); % d in 28, 32, 36, 40
    reg(1,1:24) = f(dates);
    
    % Do other
    f = fit( dates', (othM(4*i+j+4,1:24))', 'poly9', 'normalize', 'on');
    c = coeffvalues(f);
    othM(4*i+j+4, 4*j+21) = c(1); % a in 25, 29, 33, 37
    othM(4*i+j+4, 4*j+22) = c(2); % b in 26, 30, 34, 38
    othM(4*i+j+4, 4*j+23) = c(3); % c in 27, 31, 35, 39
    othM(4*i+j+4, 4*j+24) = c(4); % d in 28, 32, 36, 40
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
  end
  
  % Let the user know somehting is happening
  if(mod( (50-i),15 ) == 0 && (50-i) ~= 0)
    s = strcat('\n', num2str(50-i));
  else
    s = num2str(50-i);
  end
  fprintf(s);
end

% Format output to have all coefficients in 52 rows
for i=1:52
  resM(i, 25:28) = resM(4*i-3, 25:28);
  resM(i, 29:32) = resM(4*i-2, 29:32);
  resM(i, 33:36) = resM(4*i-1, 33:36);
  resM(i, 37:40) = resM(4*i,   37:40);
  othM(i, 25:28) = othM(4*i-3, 25:28);
  othM(i, 29:32) = othM(4*i-2, 29:32);
  othM(i, 33:36) = othM(4*i-1, 33:36);
  othM(i, 37:40) = othM(4*i,   37:40);
end
% Assign the condenced form of the data to the variables we're keeping
resgen = resM(1:52,25:40);
othgen = othM(1:52,25:40);

% Inform user, then clear variables that we no longer need.
fprintf('. Done.\n');

clear c; clear gen; clear f; clear i; clear j; clear k;  clear reg; clear rows; clear temp; clear s;
clear othM; clear srO; clear stO; clear sumyO, clear tempO; clear ybarO; 
clear resM; clear srR; clear stR; clear sumyR; clear tempR; clear ybarR; 
% We'll use dates next time

% Analysis: I just jumped to using exp2 fit, since it was so good last time, and checked it after
% (it didn't disappoint). However, there are several variables where there is no generation of that
% kind in the state, and so the regression yields NaN. The rest are within .05 of 1 (except for 1,
% which is .3 away). End result: I feel that it's good enough to again just export the coefficients.

% Total additional runtime: 336.878s. Running total: 355.296s = 5:55.296
 % Running it all together: 370.249s = 6:10.249

%% 3) Emissions data
% %   2a) Pull in emissions data
% % Inform user what's going on
% fprintf('Importing emission data...');
% ems = readtable('../Data/AnnualEmissionByState.csv','Delimiter','/');
% % Sort the rows according to state code
% ems = sortrows(ems,'Code');
% fprintf('Done.\n');
% 
% %%   2b) Separate it. We're only interested in emissions for specific types
% % First, prep the table. We need to convert these columns from cells to categories, so we can just
% % check it using ==, rather than trying to compare strings.
% ems.EnergySource = categorical(ems.EnergySource);
% 
% % Now, pull off each category
% % Rather than using tables for this data, it actually is much easier to create a data matrix to
% % handle all our data needs.
% catM = zeros(52*4,3+24); % Holds emission data per state per generation cat (see above) per year...
% f = fittype('exp2');     % Holds our best-fit function, which we'll pare with coefficients from before
% % Categories that we'll use in our analysis:
% % Coal-the dirtiest, with lots of emission data
% % Natural Gas-relatively clean, also lots of emission data
% % Other (Other, Other Biomass, Other Gases, Petroleum, Wood and Wood Derived Fuels) - grab-bag of
%   % all other emission data. This is a simplifying assumption.
% % Clean (Geothermal, Hydroelectric Conventional, Nuclear, Solar Thermal and Photovoltaic, Wind) -
%   % We'll assume these produce no emissions, as all are clean.
% 
% % Inform user what's going on
% fprintf('Processing emissions data--states remaining:');
% 
% % Populate our tables and matrices. Loop through each state. We use the state code (ID) to index.
% for i=-1:50 % State Codes (plus DC-50 and All USA- -1)
%   % Get a table of just the state we're interested in
%   rows = ems.Code == i;
%   tempE = ems(rows, {'Year', 'EnergySource', 'CO2', 'SO2', 'Nox'} );
%   
%   % Loop through the years to build rows for each category and state
%   for j=1990:2013
%     % Category 1: Coal. First, lets get residential
%     % TODO: This doesn't work. It won't import anything.
%     rows = tempE.EnergySource == 'Coal' & tempE.Year == j;
%     tempEs = [ tempE.CO2(rows), tempE.SO2(rows), tempE.Nox(rows) ];
%     catM(4*i+5,j-1989) = mean( tempEs(1) );
%     catM(4*i+5,j-1988) = mean( tempEs(2) );
%     catM(4*i+5,j-1987) = mean( tempEs(3) );
%     
%     % Cat. 2: Natural Gas. First, lets get residential
%     rows = tempE.EnergySource == 'Natural Gas' & tempE.Year == j;
%     tempEs = [ tempE.CO2(rows), tempE.SO2(rows), tempE.Nox(rows) ];
%     catM(4*i+6,j-1989) = mean( tempEs(1) );
%     catM(4*i+6,j-1988) = mean( tempEs(2) );
%     catM(4*i+6,j-1987) = mean( tempEs(3) );
%     
%     % Cat. 3: Other (Other, Other Biomass, Other Gases, Petroleum, Wood and Wood Derived Fuels)
%     rows = tempE.EnergySource == 'Other' & tempE.Year == j;
%     rows = bitor(rows, tempE.EnergySource == 'Other Biomass' & tempE.Year == j);
%     rows = bitor(rows, tempE.EnergySource == 'Other Gases' & tempE.Year == j);
%     rows = bitor(rows, tempE.EnergySource == 'Petroleum' & tempE.Year == j);
%     rows = bitor(rows, tempE.EnergySource == 'Wood and Wood Derived Fuels' & tempE.Year == j);
%     tempEs = [ tempE.CO2(rows), tempE.SO2(rows), tempE.Nox(rows) ];
%     catM(4*i+7,j-1989) = mean( tempEs(1) );
%     catM(4*i+7,j-1988) = mean( tempEs(2) );
%     catM(4*i+7,j-1987) = mean( tempEs(3) );
%     
%     
%     % Cat. 4: Clean (Geothermal, Hydroelectric Conventional, Nuclear, Solar Thermal and Photovoltaic, Wind) 
%     rows = tempE.EnergySource == 'Geothermal' & tempE.Year == j;
%     rows = bitor(rows, tempE.EnergySource == 'Hydroelectric Conventional' & tempE.Year == j);
%     rows = bitor(rows, tempE.EnergySource == 'Nuclear' & tempE.Year == j);
%     rows = bitor(rows, tempE.EnergySource == 'Solar Thermal and Photovoltaic' & tempE.Year == j);
%     rows = bitor(rows, tempE.EnergySource == 'Wind' & tempE.Year == j);
%     tempEs = [ tempE.CO2(rows), tempE.SO2(rows), tempE.Nox(rows) ];
%     catM(4*i+8,j-1989) = mean( tempEs(1) ); % Average emmissions of CO2,
%     catM(4*i+8,j-1988) = mean( tempEs(2) ); % SO2,
%     catM(4*i+8,j-1987) = mean( tempEs(3) ); % and Nox over the 24 years of data
%   end % loop through states
%   
%   % Make sure user knows that something is happening, because this next part will be SLOW
%   fprintf('.');
% 
%   % Loop through each of the four categories, finding emission/MWh.
%   for j=1:4
%     % Get best-fit curve from data we've stored before
%     a = resgen(i+2, 4*j-3);
%     b = resgen(i+2, 4*j-2);
%     c = resgen(i+2, 4*j-1);
%     d = resgen(i+2, 4*j);
%     cf= cfit(f,a,b,c,d);
%     % All other points of data in catM = (total emissions per category)/(total generaged for category)
%     % I use the f from generation to compute it
%     catM(4*i+j+4, 4:27) = catM(4*i+j+4, j)/cf(dates);
%     % Average power produced in that category over the 24 years of data
%     catM(4*i+j+4, 4) = mean( catM(4*i+j+4, 4:27) );
%   end
%   
%   % Let the user know somehting is happening
%   if(mod( (50-i),15 ) == 0 && (50-i) ~= 0)
%     s = strcat('\n', num2str(50-i));
%   else
%     s = num2str(50-i);
%   end
%   fprintf(s);
% end
% 
% % Format output to have all coefficients in 52 rows
% for i=1:52
%   catM(i, 1) = catM(4*i-3, 1)/catM(4*i-3, 4);
%   catM(i, 2) = catM(4*i-2, 2)/catM(4*i-2, 4);
%   catM(i, 3) = catM(4*i-1, 3)/catM(4*i-1, 4);
% end
% % Assign the condenced form of the data to the variables we're keeping
% ems = catM;
% 
% % Inform user, then clear variables that we no longer need.
% fprintf('. Done.\n');

%clear c; clear dates; clear f; clear gen; clear i; clear j; clear k;  clear reg; clear rows; 
%clear othM; clear srO; clear stO; clear sumyO, clear tempO; clear ybarO; clear temp;
%clear resM; clear srR; clear stR; clear sumyR; clear tempR; clear ybarR; clear s;

% Analysis: I just jumped to using exp2 fit, since it was so good last time, and checked it after
% (it didn't disappoint). However, there are several variables where there is no generation of that
% kind in the state, and so the regression yields NaN. The rest are within .05 of 1 (except for 1,
% which is .3 away). End result: I feel that it's good enough to again just export the coefficients.

% Total additional runtime: 336.878s. Running total: 355.296s = 5:55.296
 % Running it all together: 370.249s = 6:10.249






% 4) Cost data
%   a) Pull in cost data
%   b) Separate it
%   c) Best-fit curve it
 
 %% After spending 9 hours on the above, I figured that I could forbear doing it again for emissions
% data and power consumption data, especially because the rest of the group has decided that they
% are going to just find this data from questions that the user answers. So, we go to part 4:

% 4) Combine everything and write out file
% Let user know something is happening
fprintf('Now outputting data to ''/Data'' folder: ');

% Prepare output variable
out = zeros(51,37);

%   4a) Combine everything
% Loop through the states, putting everything together for final output
% Our pop, resgen, and othgen all have aggregate USA states first, DC last, and the rest in
% alphabetical order between them. We're ignoring DC because population extrapolation is very off
% and it's almost more accurate to use Virginia data anyway.
for i=1:51
  % Write out the index we use in C++
  out(i, 1) = i-1;
  if(i==1)
    % We have all USA aggregate data; write to last line
    out(51,2:5)  = pop(1,1:4);
    out(51,6:21) = resgen(1,1:16);
    out(51,22:37)= othgen(1,1:16);
  else
    % We have a state's data. Note that the loop ends before we get to DC.
    out(i-1,2:5)   = pop(i,1:4);
    out(i-1,6:21)  = resgen(i,1:16);
    out(i-1,22:37) = othgen(i,1:16);
  end

  % Let the user know somehting is happening
  if(mod( (50-i),15 ) == 0 && (50-i) ~= 0)
    s = strcat('\n', num2str(50-i));
  else
    s = '.';
  end
  fprintf(s);
end

%   4b) Write it all out to files
% Create format: 1 int, 36 floats, new line, all separated with \t=tab
formatSpec = '%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t';
formatSpec = strcat(formatSpec, '%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\r\n');
fout = fopen('../Data/AllStateCoefs.txt','w');

% Final output file format: StateID (1)
% Population:                   a,b,c,d (2-5)
% Coal Residential Generation:  a,b,c,d (6-9)
% Natural Gas Residential Gen:  a,b,c,d (10-13)
% Other Resident'l Generation:  a,b,c,d (14-17)
% Clean Resident'l Generation:  a,b,c,d (18-21)
% Coal non-res Generation:      a,b,c,d (22-25)
% Natural Gas non-res Gen:      a,b,c,d (26-29)
% Other non-res Generation:     a,b,c,d (30-33)
% Clean non-res Generation:     a,b,c,d (34-37)

% Actually write to file. This can't be included in the loop above because we're writing out the ith
% line, but we were bulding the (i-1)th line in the loop above.
for i=1:51
  fprintf( fout,formatSpec,out(i,:) );
end

% Inform user, then clear variables that we no longer need.
fprintf('. Done.\n');

% Be sure also to close the file.
fclose(fout);
clear ans; clear formatSpec; clear fout; clear i; clear s;

fprintf('You now have a file that you can import into the C++ portion of the project!\n');
fprintf('This program is now done. Thank you for running me.');

% Total run time: 422.374s = 7:02.374