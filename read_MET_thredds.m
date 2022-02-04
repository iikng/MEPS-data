
% Read data from MET thredds


start_yr=2017;
start_month=1;
start_day=1;
start_hour=0;

end_yr=2017;
end_month=1;
end_day=2;
end_hour=18;


% number of dates
no_dates=datenum(end_yr,end_month,end_day,0,0,0)-datenum(start_yr,start_month,start_day,0,0,0)+1;

% analysis times (UTC)
ana_times=['00';'06';'12';'18'];

% number of analysis times
no_ana=size(ana_times,1);

count=1;
% loop through the dates
for i=1:no_dates

    clear merra_stream
% find date
    current_yr=datestr(datenum(start_yr,start_month,start_day+i-1,0,0,0),10);
    current_month=datestr(datenum(start_yr,start_month,start_day+i-1,0,0,0),5);
    if current_month<10
       current_month_txt=['0' num2str(current_month)];
    else
        current_month_txt=num2str(current_month);
    end
    current_day=datestr(datenum(start_yr,start_month,start_day+i-1,0,0,0),7);
  if current_day<10
       current_day_txt=['0' num2str(current_day)];
    else
        current_day_txt=num2str(current_day);
    end
  
% loop through the analysis times
  for k=1:no_ana
      
% address to data
     url =['http://thredds.met.no/thredds/dodsC/meps25epsarchive/' num2str(current_yr) '/' current_month_txt '/' current_day_txt '/meps_subset_2_5km_'  num2str(current_yr) current_month_txt current_day_txt 'T' ana_times(k,:) 'Z.nc.html'];
     
% see what is in the file     
%     ncdisp( ['http://' url])
      
% clear variables for try command to work
       clear met_lat met_lon met_time met_forecast_ref_time
       try
           met_lat=ncread(url,'latitude');
           met_lon=ncread(url,'longitude');

           met_time=ncread( url,'time');
           met_ser_time=datenum(met_time/(24*60*60))+datenum(1970,1,1,0,0,0);

           met_forecast_ref_time=ncread(url,'forecast_reference_time');
           met_forecast_ref_ser_time=datenum(met_forecast_ref_time/(24*60*60))+datenum(1970,1,1,0,0,0);
       end

% take out only analysis time if the data exis

      if exist('met_forecast_ref_time')==0
          start_pnt=1;
         % met_ser_time=met_ser_time_all(count-1)+str2num(ana_times(k,:))/24;
          disp(['WARNING: Data for: ' url  ' do not exist. Fill with NaNs'])
      else
          start_pnt=find(met_ser_time==met_forecast_ref_ser_time);
          met_ser_time=met_ser_time(start_pnt);
          disp(['Read data from: ' url])
      end
      
% clear variables for try command to work      
      clear met_relative_humidity_2m met_u_wnd met_v_wnd
      try
          met_relative_humidity_2m=ncread(['http://' url],'relative_humidity_2m',[1 1 1 start_pnt ], [Inf Inf Inf 1], [1 1 1 1]);
          met_u_wnd=ncread(['http://' url],'x_wind_10m',[1 1 1 start_pnt ], [Inf Inf Inf 1], [1 1 1 1]);
          met_v_wnd=ncread(['http://' url],'y_wind_10m',[1 1 1 start_pnt ], [Inf Inf Inf 1], [1 1 1 1]);
      end
 % if file do not exist put in NaNs     
          %if exist('met_relative_humidity_2m')==0
            %  met_relative_humidity_2m= squeeze(met_relative_humidity_2m_all(:,:,count-1))*NaN;
             % met_u_wnd=met_relative_humidity_2m;
             % met_v_wnd=met_relative_humidity_2m;
         % end
          
          %met_wndspd=sqrt(met_u_wnd.^2+met_v_wnd.^2);
  
 % save all in one array 
     met_relative_humidity_2m_all(:,:,count)=met_relative_humidity_2m;
     %met_wndspd_all(:,:,count)=met_wndspd;
     met_ser_time_all(count)=met_ser_time;
    
     count=count+1;
  end
end




