function out = printval (v, varargin)

if nargin < 2
    opts = struct;
else
    if ~ isstruct (varargin{1})
        opts = cell2struct(varargin(2:2:end)',varargin(1:2:end));
    end 
end

if ~ isfield (opts, 'isSigned')
    opts.isSigned = true;
end

if ~ isfield (opts, 'stars')
    opts.stars = false;
end

if ~ isfield (opts, 'digits')
    opts.digits = 3;
end

isNeglible = abs (v) < 10^(- opts.digits);
s = sign (v);
v = round (abs (v),opts.digits);

format = ['%0.' num2str(opts.digits) 'f'];

out = sprintf(format,v);
if opts.isSigned 
    if s < 0
        out = ['-' out];
    %else
    %    out = [' ' out];
    end
end

if isNeglible
    out(end) = '1';
    if s < 0
        out = ['>' out];
    else
        out = ['<' out];
    end
%else
    %out = [' ' out];
end


if opts.stars
    nstars = sum (v <= [.05 .01 .001]);
    out = string([out repmat('*',1,nstars) repmat(' ',1,3-nstars)]);
end



    