clc
clear all



%Set master directory to the drive holding the Rode_etal_projections file
cd('/Volumes/ext_drive/NatureComms')


%{
check in file
%}
attributes = ncinfo("/Volumes/ext_drive/NatureComms/FD_FGLS_inter_OTHERIND_electricity_TINV_clim-noadapt-levels.nc4")


%{
Set loop over fuels, the RCP, the SSP, and GCM in run
%}

fuels = {'electricity','other_energy'};

error=0
%%Loop

for f_type = fuels

                %% TRY BLOCK%%%
                display(f_type{1})
                try 
                    
                   

%{
Pull in the two panels with and without adaptation
%}


%Pull time series
rebased = ncread("FD_FGLS_inter_OTHERIND_" + f_type{1} + "_TINV_clim-noadapt-levels.nc4",'rebased');
year_baseline = ncread("FD_FGLS_inter_OTHERIND_" + f_type{1} + "_TINV_clim-noadapt-levels.nc4",'year');


% rebased = ncread("FD_FGLS_inter_OTHERIND_electricity_TINV_clim-noadapt-levels.nc4",'rebased');
% year_baseline = ncread("FD_FGLS_inter_OTHERIND_electricity_TINV_clim-noadapt-levels.nc4",'year');

max_year=max(year_baseline);


%{
Read in region file to append as column 1 for this panel
%}

load('regions_24k.mat');

%{
Damage = adapt-BL
%}
damages_array = rebased;


%%append regions
table_input_damages = [regions_24k,damages_array];

%%set correct length of year names vector
    if max_year == 2100
        %Make labels for years
        column_names = { 'regions', 'year_1981'	, 'year_1982'	, 'year_1983'	, 'year_1984'	, 'year_1985'	, 'year_1986'	, 'year_1987'	, 'year_1988'	, 'year_1989'	, 'year_1990'	, 'year_1991'	, 'year_1992'	, 'year_1993'	, 'year_1994'	, 'year_1995'	, 'year_1996'	, 'year_1997'	, 'year_1998'	, 'year_1999'	, 'year_2000'	, 'year_2001'	, 'year_2002'	, 'year_2003'	, 'year_2004'	, 'year_2005'	, 'year_2006'	, 'year_2007'	, 'year_2008'	, 'year_2009'	, 'year_2010'	, 'year_2011'	, 'year_2012'	, 'year_2013'	, 'year_2014'	, 'year_2015'	, 'year_2016'	, 'year_2017'	, 'year_2018'	, 'year_2019'	, 'year_2020'	, 'year_2021'	, 'year_2022'	, 'year_2023'	, 'year_2024'	, 'year_2025'	, 'year_2026'	, 'year_2027'	, 'year_2028'	, 'year_2029'	, 'year_2030'	, 'year_2031'	, 'year_2032'	, 'year_2033'	, 'year_2034'	, 'year_2035'	, 'year_2036'	, 'year_2037'	, 'year_2038'	, 'year_2039'	, 'year_2040'	, 'year_2041'	, 'year_2042'	, 'year_2043'	, 'year_2044'	, 'year_2045'	, 'year_2046'	, 'year_2047'	, 'year_2048'	, 'year_2049'	, 'year_2050'	, 'year_2051'	, 'year_2052'	, 'year_2053'	, 'year_2054'	, 'year_2055'	, 'year_2056'	, 'year_2057'	, 'year_2058'	, 'year_2059'	, 'year_2060'	, 'year_2061'	, 'year_2062'	, 'year_2063'	, 'year_2064'	, 'year_2065'	, 'year_2066'	, 'year_2067'	, 'year_2068'	, 'year_2069'	, 'year_2070'	, 'year_2071'	, 'year_2072'	, 'year_2073'	, 'year_2074'	, 'year_2075'	, 'year_2076'	, 'year_2077'	, 'year_2078'	, 'year_2079'	, 'year_2080'	, 'year_2081'	, 'year_2082'	, 'year_2083'	, 'year_2084'	, 'year_2085'	, 'year_2086'	, 'year_2087'	, 'year_2088'	, 'year_2089'	, 'year_2090'	, 'year_2091'	, 'year_2092'	, 'year_2093'	, 'year_2094'	, 'year_2095'	, 'year_2096'	, 'year_2097'	, 'year_2098'	, 'year_2099'	, 'year_2100'};
    else
        column_names = { 'regions', 'year_1981'	, 'year_1982'	, 'year_1983'	, 'year_1984'	, 'year_1985'	, 'year_1986'	, 'year_1987'	, 'year_1988'	, 'year_1989'	, 'year_1990'	, 'year_1991'	, 'year_1992'	, 'year_1993'	, 'year_1994'	, 'year_1995'	, 'year_1996'	, 'year_1997'	, 'year_1998'	, 'year_1999'	, 'year_2000'	, 'year_2001'	, 'year_2002'	, 'year_2003'	, 'year_2004'	, 'year_2005'	, 'year_2006'	, 'year_2007'	, 'year_2008'	, 'year_2009'	, 'year_2010'	, 'year_2011'	, 'year_2012'	, 'year_2013'	, 'year_2014'	, 'year_2015'	, 'year_2016'	, 'year_2017'	, 'year_2018'	, 'year_2019'	, 'year_2020'	, 'year_2021'	, 'year_2022'	, 'year_2023'	, 'year_2024'	, 'year_2025'	, 'year_2026'	, 'year_2027'	, 'year_2028'	, 'year_2029'	, 'year_2030'	, 'year_2031'	, 'year_2032'	, 'year_2033'	, 'year_2034'	, 'year_2035'	, 'year_2036'	, 'year_2037'	, 'year_2038'	, 'year_2039'	, 'year_2040'	, 'year_2041'	, 'year_2042'	, 'year_2043'	, 'year_2044'	, 'year_2045'	, 'year_2046'	, 'year_2047'	, 'year_2048'	, 'year_2049'	, 'year_2050'	, 'year_2051'	, 'year_2052'	, 'year_2053'	, 'year_2054'	, 'year_2055'	, 'year_2056'	, 'year_2057'	, 'year_2058'	, 'year_2059'	, 'year_2060'	, 'year_2061'	, 'year_2062'	, 'year_2063'	, 'year_2064'	, 'year_2065'	, 'year_2066'	, 'year_2067'	, 'year_2068'	, 'year_2069'	, 'year_2070'	, 'year_2071'	, 'year_2072'	, 'year_2073'	, 'year_2074'	, 'year_2075'	, 'year_2076'	, 'year_2077'	, 'year_2078'	, 'year_2079'	, 'year_2080'	, 'year_2081'	, 'year_2082'	, 'year_2083'	, 'year_2084'	, 'year_2085'	, 'year_2086'	, 'year_2087'	, 'year_2088'	, 'year_2089'	, 'year_2090'	, 'year_2091'	, 'year_2092'	, 'year_2093'	, 'year_2094'	, 'year_2095'	, 'year_2096'	, 'year_2097'	, 'year_2098'	, 'year_2099'};
    end
%print out a table and save to csv
table_out_baseline = array2table(table_input_damages,'VariableNames',column_names);
%name correctly
file_name_temp =   f_type{1} + ".csv";
%printout
writetable(table_out_baseline,file_name_temp)
    
                catch 
                 %% Catch BLOCK%%%
                    error = error+1
                    
                end

end

    