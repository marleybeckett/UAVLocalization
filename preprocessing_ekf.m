% Load data
clear all
%% Load in the Data
UAV_data = readtable('GPS_flight.csv');
sensor_data = readtable('Inspiron_Backup.csv');

sensor = table2array(sensor_data(:,["Time_Zeroed","Latitude","Longitude",]));
uav = table2array(UAV_data(:,["time_zeroed","latitude","longitude","altitude_above_seaLevel_feet_","xSpeed_mph_","ySpeed_mph_"]));

sensor_data(~sensor_data.Latitude,:) = [];
sensor_data(~sensor_data.Longitude,:) = [];
%% Plotting Original Data
lat_min = min(UAV_data.latitude);
lat_max = max(UAV_data.latitude);
lon_min = min(UAV_data.longitude);
lon_max = max(UAV_data.longitude);

figure; 
path_3D = plot3(UAV_data.latitude, UAV_data.longitude, UAV_data.altitude_above_seaLevel_feet_);
title('UAV Flight Map - 3D - all samples')

figure;
geoplot(UAV_data.latitude, UAV_data.longitude,'.')
title('UAV Flight Map - all samples')

%% Remove duplicate timestamps

% Find the unique values in the column
[~, index_sensor] = unique(sensor_data.Time_Zeroed);
[~, index_UAV] = unique(UAV_data.time_zeroed);

% Check which rows have values that are not unique
is_unique_sensor = ismember(1:height(sensor_data), index_sensor);
is_unique_UAV = ismember(1:height(UAV_data), index_UAV);

% Use logical indexing to select the rows with unique values
sensor_unique = sensor_data(is_unique_sensor,:);
UAV_unique = UAV_data(is_unique_UAV,:);
%% Create synchronized data tables
unique_values = unique([UAV_unique.time_zeroed; sensor_unique.Time_Zeroed]);

% Check which unique values are present in both tables
is_member1 = ismember(unique_values, UAV_unique.time_zeroed);
is_member2 = ismember(unique_values, sensor_unique.Time_Zeroed);

% Use logical indexing to select the values that are present in both tables
common_values = unique_values(is_member1 & is_member2);

SEN = table();
UAV = table();

for i=1:numel(common_values)
    rows1 = sensor_unique.Time_Zeroed == common_values(i);
    rows2 = UAV_unique.time_zeroed == common_values(i);
    SEN = [SEN; sensor_unique(rows1,:)];
    UAV = [UAV; UAV_unique(rows2,:)];
end

h = 130;
[x_gps,y_gps,~] = latlon2local(UAV.latitude,UAV.longitude,h,[UAV.latitude(1),UAV.longitude(1),h]);
[x_sen,y_sen,~] = latlon2local(SEN.Latitude,SEN.Longitude,h,[SEN.Latitude(1),SEN.Longitude(1),h]);

%%
uav = table();
sen = table();
uav.x = x_gps;
uav.y = y_gps;
uav.time = UAV.time_zeroed;
sen.x = x_sen;
sen.y = y_sen;
sen.time = UAV.time_zeroed;

writetable(uav, 'uav_prep.csv')
writetable(sen, 'sensor_prep.csv')


%% Plotting the paths
figure(1);
plot(x_gps,y_gps)
hold on;
plot(x_gps(1),y_gps(1),'rx')
hold on;
plot(x_gps(end),y_gps(end),'ro')
hold off;
legend('Path','Start','End')
axis('equal'); % set 1:1 aspect ratio to see real-world shape


figure(2);
plot(x_sen,y_sen)
hold on;
plot(x_gps(1),y_gps(1),'rx')
hold on;
plot(x_gps(end),y_gps(end),'ro')
hold off;
legend('Path','Start','End')
axis('equal'); % set 1:1 aspect ratio to see real-world shape

%% Manual Segmentation
figure(1);
i = 288;
j = 301;
plot(x_gps(i:j),y_gps(i:j))
axis('equal'); % set 1:1 aspect ratio to see real-world shape
title(sprintf("i: %d to j: %d",i,j))
figure(2);
plot(i:j,UAV.speed_mph_(i:j))

