# requires octave-zeromq and octave-socket
#
clear all
more off
channelstart=96
Nfreq=22               % channels 96 to 140
total_length=1000;
averages=10
fs=5.;                 % acquisition sampling freq (MHz)
finc=5.0;
error_threshold=0.2;
error_number=100;
disp_curv=0;
maxposition=127
maxmeas=20

pkg load zeromq
pkg load signal
pkg load sockets
# pkg load instrument-control   % switch control

sck=socket(AF_INET, SOCK_STREAM, 0); 
server_info=struct("addr","192.168.77.168","port",5556);
connect(sck,server_info);

error_vector=ones(error_number,1);

function [tmpmes1,tmpmes2]=acq(total_length,error_threshold,error_vector,maxmeas)
  tmpmes1=[];
  tmpmes2=[];
  compteur=0;
  do
    sock1 = zmq_socket(ZMQ_SUB);  % socket-connect-opt-close = 130 us
    zmq_connect   (sock1,"tcp://192.168.77.168:5555");
    zmq_setsockopt(sock1, ZMQ_SUBSCRIBE, "");
    received=zmq_recv(sock1, total_length*8*2, 0); % *2: interleaved channels
    value=typecast(received,"single complex"); % char -> float
    tmpv1=value(1:2:length(value));
    tmpv2=value(2:2:length(value));
    zmq_close (sock1);
    baddata=findstr(abs(tmpv1)<error_threshold*max(abs(tmpv1)),error_vector'); % all data below threshold
    tmpv1(baddata)=NaN;
    tmpv2(baddata)=NaN;
    gooddata=find(!isnan(tmpv1));
% length(gooddata)
    if (max(abs(tmpv1))>0.5) 
       tmpmes1=[tmpmes1 tmpv1(gooddata)]; % tmpmes1=[tmpmes1 tmpv1];
       tmpmes2=[tmpmes2 tmpv2(gooddata)]; % tmpmes2=[tmpmes2 tmpv2];
    end
    compteur=compteur+1;
  until ((length(tmpmes1)>=total_length) || (compteur >= maxmeas))
  if (compteur >= maxmeas) printf("DATA LOST\n");end
  clear tmpv1 tmpv2
end

send(sck,'z');                   % reset frequency to min value
recv(sck,1); % 111
tic 
for position=1:maxposition
  position
  send(sck,'0');                   % reset frequency to min value
  recv(sck,1); % 111
  for frequence=1:Nfreq+1
    for repet=1:2
%      printf("\n");
      [tmpmes1,tmpmes2]=acq(total_length*averages,error_threshold,error_vector,maxmeas);
      if (length(tmpmes1)>=total_length*averages)
         mes1(:,(frequence-1)*2+repet)=tmpmes1(1:total_length*averages);
         mes2(:,(frequence-1)*2+repet)=tmpmes2(1:total_length*averages);
      else
         mes1(1:length(tmpmes1),(frequence-1)*2+repet)=tmpmes1;
         mes2(1:length(tmpmes2),(frequence-1)*2+repet)=tmpmes2;
      end
      % printf("max_sur=%f max_ref=%f\n",max(mes1),max(mes2));
      if (repet==1)
        xindex((frequence-1)*2+repet)=((channelstart+(frequence-1)*2)*5+5000)-fs/2;
        send(sck,'+');  % sample center band
        recv(sck,1); % 111
      else
        xindex((frequence-1)*2+repet)=((channelstart+(frequence-1)*2)*5+5000)+fs/2;
      end
      if (disp_curv==1)
        subplot(211);plot(real(tmpmes1))
        subplot(212);plot(real(tmpmes2))
        pause(.1)
      end
    end
    send(sck,'u');  % sample center band
    recv(sck,1);    % 111 
  end
  freq=xindex;
  xindexmin=(min(xindex)-fs/2);
  xindexmax=(max(xindex)+fs/2);
  fmin=xindexmin;
  fmax=xindexmax;
  eval(['save -v6 ',num2str(position),'ltor.mat mes1 mes2 freq fmin fmax']);

%  L=size(mes1)(1);
%  binwidth=fs/L;   
%  xindex=round((xindex-fs/2-xindexmin)/binwidth); % frequency -> index shifted by half a Nyquist zone
%  if (xindex(1)<=0) xindex=xindex+min(xindex)+1;end
%  span=ceil((xindexmax-xindexmin)/binwidth);  % bin index increment every time LO increases by finc
%  spectrum1=zeros(span,1); % extended spectral range
%  spectrum2=zeros(span,1); % ... resulting from spectra concatenation
%  w=hanning(L);
%  for f=1:length(xindex)
%      spectrum1(xindex(f):xindex(f)+L-1)=spectrum1(xindex(f):xindex(f)+L-1)+fftshift(fft(mes1(:,f))); % center of FFT in the middle
%      spectrum2(xindex(f):xindex(f)+L-1)=spectrum2(xindex(f):xindex(f)+L-1)+fftshift(fft(mes2(:,f))); % center of FFT in the middle
%  end
%  
%  badindex=find(abs(spectrum2)<1e-2)
%  spectrum2(badindex)=1e-2;
%  spectrum1(badindex)=1e-2;
%  res=(ifft(spectrum1./spectrum2)); % .*hamming(length(spectrum1))));
%  xtime=[0:length(res)-1]/(xindexmax-xindexmin);  % us
%  plot(300/2*xtime,abs(res))
  % next position
  send(sck,'r');
  recv(sck,1)
  pause(0.5)
end  % position
send(sck,'q');
recv(sck,1)
disconnect(sck)
toc

return

figure
subplot(211)
plot(linspace(fmin,fmax,length(spectrum1)),abs(spectrum1))
ylabel('power (a.u.)')
subplot(212)
plot(linspace(fmin,fmax,length(spectrum1)),abs(spectrum2))
xlabel('frequency (MHz)')
ylabel('power (a.u.)')

figure
subplot(211)
plot(300/2*xtime(22500:23500),abs(res(22500:23500)))
xlim([-325 325])
ylim([0 0.2])
subplot(212)
plot(300/2*xtime(23000:23500),abs(res(23000:23500)-flipud(res(22500:23000))))
xlim([0 325])
ylim([0 0.2])
xlabel('range (m)')
ylabel('power (a.u.)')
