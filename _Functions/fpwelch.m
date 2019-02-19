function [spec, freq] = fpwelch(x,window,overlap_frac,Nfft,Fs,varargin)
% Partial implementation of MATLAB's pwelch function
% Returns one-sided PSD of the real-valued signal x
% If empty arguments are given, this script uses by default:
%    - the Hamming window 
%    - 50% overlap
%    - each segment is of length nextpow2(sqrt(length(x))
%    - Fs is 1
%  
% To obtain a PSD without averaging, Nfft should be the length of the signal and the window should be made of ones. Otherwise a warning is thrown
% 
% NOTE: default is one-sided, not-detrended. Corresponds to:
%     OCTAVE:
%         pwelch(y,window,overlap_frac      ,Nfft,Fs,'onesided','none');
%     MATLAB:
%         pwelch(y,window,overlap_frac*Nfft,Nfft,Fs);

%
% INPUTS:
%     x             time series
%     window       - vector of window-function values between 0 and 1
%                  - integer providing the length of each data segment using Hamming window
%                    The default is window=sqrt(length(x)) rounded up to the
%                    nearest integer power of 2.
%                  - empty: use Hamming window with length
%     overlap_frac  Segment overlap expressed as a multiple of segment length
%                     0 <= overlap_frac < 0.95 default is overlap_frac=0.5 .
%     Nfft          FFT length, the default is the length of the "window" vector or has the same value as the
%                   scalar "window" argument.  If Nfft is larger than the
%                   segment length, "seg_len", the data segment is padded
%                   with "Nfft-seg_len" zeros.  The default is no padding.
%                   Nfft values smaller than the length of the data
%                   segment (or window) are ignored silently.
%     Fs            Sampling frequency [Hz], default=1.0
%
% OPTIONAL INPUTS: pairs of key/values arguments with the following keys
%     'detrend' : default False
%     'type'    : default 'PSD'
%    
%
% OUTPUTS:
%     spec: power spectrum
%     freq: frequency
% 
% Author: E. Branlard
%         Adapted from pwelch by Peter V. Lanspeary <pvl@mecheng.adelaide.edu.au>

    % --- optional argument
    bDetrend      = false;
    sType         = 'PSD'; % Amplitude, PSD, fxPSD
    if mod(length(varargin),2)~=0
        o.error('fpwelch: requires pairs of name / values as arguments');
    end
    for i=1:2:length(varargin)
        switch lower(varargin{i}) 
            case 'detrend'  ; bDetrend   = varargin{i+1};
            case 'type'     ; sType      = varargin{i+1};
            otherwise
                o.error('fpwelch: Unknown Key %s ',varargin{i})
        end % switch
    end

    % --- convenient formatting
    x=x(:);
    x_len = length(x);

    %% Default arguments values and checks
    % --- overlap_frac
    max_overlap = 0.95;
    if ( isempty(overlap_frac) )
        overlap_frac=0.5; % default value
    else
        if (~isscalar(overlap_frac) || ~isreal(overlap_frac) || overlap_frac<0 || overlap_frac>max_overlap )
            error( 'fpwelch: overlap_frac must be real from 0 to %f', max_overlap );
        end
    end
    % --- window and segment length
    bHamming=true;
    if ~isempty(window)
        if isscalar(window)
            seg_len = window;
            if ( ~isreal(window) || fix(window)~=window || window<=3 ) 
                error( 'fpwelch: window must be integer >3');
            end
        elseif isvector(window)
            bHamming=false;
            window = window(:);
            seg_len = length(window);
            if ~isreal(window) || any(window<0)
                error( 'fpwelch: window vector must be real and >=0');
            end
        else
            error( 'fpwelch: window must be scalar or vector');
        end
    else
        seg_len=fnextpow2(sqrt(x_len/(1-overlap_frac))); % default value
    end
    if bHamming % use Hamming window
        n = seg_len - 1;
        window = 0.54 - 0.46 * cos( (2*pi/n)*[0:n].' );
    end
    % --- Nfft
    if isempty(Nfft)
        Nfft = seg_len; % default value
    else
        if ( ~isscalar(Nfft) || ~isreal(Nfft) || fix(Nfft)~=Nfft || Nfft<0 )
            error( 'fpwelch: Nfft must be integer >=0');
        end
        Nfft = max( Nfft, seg_len );
    end
    % --- Nfft
    if isempty(Fs)
        Fs=1;
    end
    % --- overlap
    overlap = fix(seg_len * overlap_frac);

    %% Compute mean periograms
    if bDetrend
    % --- Remove mean from the data
    n_ffts = max( 0, fix( (x_len-seg_len)/(seg_len-overlap) ) ) + 1;
    x_len  = min( x_len, (seg_len-overlap)*(n_ffts-1)+seg_len );
    x = x - sum( x(1:x_len) ) / x_len;
    end
    % --- Calculate and accumulate periodograms
    xx = zeros(Nfft,1); % padded data segments
    Pxx = xx; % periodogram sums
    n_ffts = 0;
    for start_seg = [1:seg_len-overlap:x_len-seg_len+1]
        end_seg = start_seg+seg_len-1;
        xx(1:seg_len) = window .* x(start_seg:end_seg);
        fft_x = fft(xx);
        % force Pxx to be real; pgram = periodogram
        pgram = real(fft_x .* conj(fft_x));
        Pxx = Pxx + pgram;
        n_ffts = n_ffts +1;
    end
    % --- domains, as required by Parseval theorem.
    if rem(Nfft,2)==0  % Nfft is even
        psd_len = Nfft/2+1;
        Pxx = Pxx(1:psd_len) + [0; Pxx(Nfft:-1:psd_len+1); 0];
    else  % Nfft is odd
        psd_len = (Nfft+1)/2;
        Pxx = Pxx(1:psd_len) + [0; Pxx(Nfft:-1:psd_len+1)];
    end
    % --- Frequencies
    freq = [0:psd_len-1].' * ( Fs / Nfft );
    % --- scaling
    win_meansq = (window.' * window) / seg_len;
    scale = n_ffts * seg_len * Fs * win_meansq;
    switch lower(sType)
        case 'psd'
    spec = Pxx / scale;
        case 'fxpsd'
            spec = freq.* Pxx / scale;
        case 'amplitude'
            df = freq(2)-freq(1); 
            spec = sqrt( Pxx / scale * 2 * df );
        otherwise
            error('Unsupported spectrum type %s',sType)
    end

    % Safety checks
    if n_ffts==1
        if mean(window)<0.999
            warning('Using a non rectangular window while averaging only 1 spectrum. You can decrease the window size (to effectively do some averaging) or use a rectangular window (to get a standard DSP without averaging)')
        end
    end

    % Keep me
    %fprintf('df:%.3f - fmax:%.2f - nseg:%5d - Lf:%5d - Lseg:%5d - Lwin:%5d - Lovlp:%5d - Nfft:%5d  - Lsig:%d\n',freq(2)-freq(1), freq(end),n_ffts,length(freq),seg_len,length(window),overlap,Nfft,x_len)

end
function np2=fnextpow2(x)
    np2 = 2^ceil( log(x)*0.99999999999/log(2));
end
