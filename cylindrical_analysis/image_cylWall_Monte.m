function I = image_cylWall_Monte(b0, X)

flagShowModelImages = 0;

% CYLINDER PARAMETERS
xcen   = b0(1);
ycen   = b0(2);
cylrad = b0(3);
var    = b0(4);
height = b0(5);
psi    = b0(6);

myBox = evalin('base', 'myBox');
maxdiag = evalin('base','maxdiag');

arblength = maxdiag; % pixels
twoSS     = 2*abs(var);
a         = cylrad;
nPoints   = 10000;  % Number of fluorophores to simulate

% FORWARD MODEL FOR PIXEL VALUES
% Relevant Distances from pixels (centre of each pixel) 
% rr   =  distance from cylinder centre
% chi  =  angle with cylinder axis
% rCyl =  distance from cylinder axis along XY plane 



theta = 2*pi*rand(nPoints,1);
surfYp = a*sin(theta);
surfXp = 2*arblength*(rand(nPoints,1)-0.5);
surfZ = a*cos(theta);

surfX = surfXp.*cos(psi) + surfYp.*sin(psi)  + xcen; % Rotate about Z-axis
surfY = -surfXp.*sin(psi) + surfYp.*cos(psi) + ycen;

I = zeros(size(X,1), 1); % Bod

for lp = 1:nPoints
    if(0)
      twoSS = 2*abs(var)*(1+(surfZ(lp)/4).^2);
    end
    dispsSq = ( (surfX(lp) - X(:,1) ).^2 + ...
                (surfY(lp) - X(:,2) ).^2 + ....
                (1/11)*(surfZ(lp)).^2 ); % z-PSF, Zhang 2007, NA 1.4 WFFM n 1.33 
              
    ints  = exp(-(dispsSq)./twoSS);
    I = I + ints;
end

I = I * height / max( I(:) );



if(flagShowModelImages)
  im = zeros(myBox(4), myBox(3));
  for lp = 1:length(I)
    im(X(lp,2),X(lp,1)) = I(lp);
  end
  figure(9)
  imagesc(im); % Note transpose for image orientation!
  colormap(gray)
  % figure(10)
  % scatter3(surfX, surfY, surfZ)
end

end