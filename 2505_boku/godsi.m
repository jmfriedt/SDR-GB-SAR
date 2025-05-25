clear all
close all

npos=127  % number of antenna positions
nt=1024;  % number of samples in the time domain
nm=9;     % number of averages
fs = 5e6; % sampling frequency
rangemax=nt;
rmdsibefore=1;
rmdsiafter=0;

if rmdsibefore=1
 Ndsi=1;   % 1 when DSI removal before stacking
else
 Ndsi=40;  % 1 when DSI removal before stacking
end

function cleaned=dsi(ref,sur,Ndsi)
  p=1;
  for m=-Ndsi:Ndsi
    if m<=0
       mat(:,p)=[ref(-m+1:end) ; zeros(-m,1)];
    else
       mat(:,p)=[zeros(m,1) ; ref(1:end-m)];
    end
    p=p+1;
  end
  w=pinv(mat)*sur;
  cleaned=sur-mat*w;
end

for position=1:npos
  position
  load([num2str(position),'ltor.mat']);
  if (position==1) 
     fstart=freq(1)*1e6-fs/2;
     fstop=freq(end)*1e6+fs/2;
     fb=fstop-fstart;
     fc=mean(freq);
  end
  for moy=1:nm
    reft=mes1((moy-1)*nt+1:moy*nt,1);
    surt=mes2((moy-1)*nt+1:moy*nt,1);
    if (rmdsibefore==1)
      reft=dsi(surt,reft,Ndsi);
    end
    ref=fftshift(fft(reft));
    sur=fftshift(fft(surt));
    for freq=2:size(mes1)(2)
        reft=mes1((moy-1)*nt+1:moy*nt,freq);
        surt=mes2((moy-1)*nt+1:moy*nt,freq);
        if (rmdsibefore==1)
          reft=dsi(surt,reft,Ndsi);
        end
        ref=[ref ; fftshift(fft(reft))];  % frequency stacking
        sur=[sur ; fftshift(fft(surt))];
    end
    if (rmdsiafter==1)
       reft=ifft(ref);
       surt=ifft(sur);
       reft=dsi(surt,reft,Ndsi);
       ref=fft(reft);
    end
    if (moy==1)
      xco(:,position)=(ifft(ref.*conj(sur).*hamming(length(ref))));
      sigf_mat(:,position) =ref.*conj(sur).*hamming(length(ref));
    else
      xco(:,position)=xco(:,position)+(ifft(ref.*conj(sur).*hamming(length(ref))));
      sigf_mat(:,position) = sigf_mat(:,position)+ref.*conj(sur).*hamming(length(ref));
    end
  end
end
% imagesc(abs(fftshift(fft(xco(1:rangemax,:),127,2),2)),[0 200])
  imagesc(abs(fftshift(ifft(xco(1:rangemax,:),127,2),2)),[0 2])

% this part below written by W. Feng (Xian, China)
c=3e8
Image_focused=fliplr((abs(fftshift(ifft(xco(1:rangemax,:),127,2),2))));
Na=size(Image_focused)(2);
Nf=size(Image_focused)(1);
lambda=c/fc
dx=lambda/4; % antenna moving step

% number of frequencies, antenna postion number
sigf = zeros(size(Image_focused)(1),size(Image_focused)(2));

df=(fstop-fstart)/size(Image_focused)(1); % frequency step
fs_r = 1/df;
r = (0:rangemax-1)*fs_r;

fs_a = 1/dx; % 
alpha = (0:Na-1)*fs_a/Na-fs_a/2;

fs_r = 1/df;
r = (0:Nf-1)*fs_r/Nf*c/2;
rangemax=r(end)

fs_a = 1/dx;
alpha = (0:Na-1)*fs_a/Na-fs_a/2;
sin_theta=alpha*lambda/2;

[R,ST] = meshgrid(r,sin_theta(abs(sin_theta)<=1));
X = R.*ST;Y = R.*sqrt(1-ST.^2);
Z=Image_focused(:,(abs(sin_theta)<=1));

figure;pcolor(X.',Y.',10*log10(Image_focused(:,(abs(sin_theta)<=1))));
colorbar;shading flat;colormap(jet);
xlabel('x (m)');ylabel('y (m)');
%if rmdsi==1
%  caxis([-15 0])
%else
  caxis([-10 20])
%end
