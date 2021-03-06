function varargout=read_sbfp(filename)

varargout=cell(nargout,1);

if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile({'*.img';'*.IMG'},'Select image file');
    if isnumeric(fname) % user pressed cancel
        return
    end
    filename=fullfile(pname,fname);
end

[array,header]=read_SBF_img(filename);
if isempty(array)
    fprintf('No image data read from file %s\n',filename);
end

if nargout==0
    figure;
    imagesc(array);
    axis image;
    return
end
if nargout>=1
    varargout{1}=array;
end
if nargout>=2
    varargout{2}=header;
end

end

function [ image, header ]  = read_SBF_img(fileName)
% Reads single image from an image file (*.img) created by WinIR3 software.
% Determines the format to read from the size of the file and returns
% image and header.  Assumes file contains a header followed by binary
% image.  Assumes that size of the file uniquely determines the type of
% file.

image   = [];
header  = [];
fileSize = fsize(fileName);
if isempty(fileSize)                    % If file not found return [].
    return
end

[ dummy, dummy2, fileParam ]   = isImgType([],[]);
    % allParam contains the array of structures
nTypes = numel(fileParam);
%
%-- Look thru the structures for a file type that matches fileSize.
%
for k = 1:nTypes
    %-- Look up the sizes
    %
    imageSize       = fileParam(k).imageSize;          % [ nrows, ncols ]
    nrows           = imageSize(1);
    ncols           = imageSize(2);        
    headerSize      = fileParam(k).headerSize;
    bytesPerElement = fileParam(k).bytesPerElement;
    %
    %-- Calc number of bytes
    %
    nBytes = headerSize + ( nrows*ncols*bytesPerElement);
    if nBytes == fileSize           % Found a matching size
        precision   = fileParam(k).class;
        rowMajor    = fileParam(k).rowMajor;
        byteSwap    = fileParam(k).byteSwap;
        %
        %-- Read the image
        %
        [ image, header ]	...
            = readBinaryArrayFile(fileName,imageSize,headerSize,precision,rowMajor,byteSwap);
        return
    end
end
end

function siz = fsize(filename)
% fsize  returns the size of a file
if exist(filename,'file')  ~= 2   
    siz = [];
    return;
end
fid = fopen(filename);          % Open the file
fseek(fid, 0, 'eof');           % Go to the end
siz = ftell(fid);               % Get size in bytes
fclose(fid);
end

function  [ type, param, allParam ] = isImgType(image, header, ignoreClass )
% isImgType  determines if image and header match those of an
% .img image file generated by WinIR3.
% INPUTS:
%   image           image array
%   header          byte vector
%   ignoreClass     1 to ignore the class of image when checking for known 
%                   .img format.   0 not to ignore the class.
%                   Default = 0;
% OUTPUTS:
%   type         	0 if didn't match
%                   1 for SBF191
%                   2 for SBF134
%                   3 for SBF191 standard deviations
%   param           structure containing the parameters of the 
%                   known type.
%   allParam        array of structures containing parameters of known types
if nargin < 3
    ignoreClass = 0;
end
param   = [];           % Default
type	= 0;            % default
%
%-- Param for image from SBF191 which is type 1
%
allParam(1).name              ='SBF191';
allParam(1).fileExt           ='img';
allParam(1).imageSize         = [ 512, 640 ];          % 512 rows x 640 cols
allParam(1).class             = 'uint16';              % 16-bits unsigned
allParam(1).bytesPerElement   = 2;
allParam(1).headerSize        = 512;                   % 512 byte header
allParam(1).rowMajor          = 1;                     % Written row major
allParam(1).byteSwap          = 0;                     % with no byte swap
allParam(1).description       = 'SBF191 from WinIR3 with header';
%
%-- Param for SBF134 which is type 2
%
allParam(2).name              ='SBF134';
allParam(2).fileExt           ='img';
allParam(2).imageSize         = [ 256, 256 ];          % 256 rows x 256 cols
allParam(2).class             = 'int16';               % 16-bits signed
allParam(2).bytesPerElement   = 2;
allParam(2).headerSize        = 512;                   % 512 byte header
allParam(2).rowMajor          = 1;                     % Written row major
allParam(2).byteSwap          = 0;                     % with no byte swap
allParam(2).description       = 'SBF134 from WinIR3 with header';
%
%-- Param for standard deviation image from SBF191 which is type 3
%
allParam(3).name              ='SBF191_SD';
allParam(3).fileExt           ='img';
allParam(3).imageSize         = [ 512, 640 ];          % 512 rows x 640 cols
allParam(3).class             = 'single';              % Single prec. floating.
allParam(3).bytesPerElement   = 4;
allParam(3).headerSize        = 512;                   % 512 byte header
allParam(3).rowMajor          = 1;                     % Written row major
allParam(3).byteSwap          = 0;                     % with no byte swap
allParam(3).description       = 'SBF191 standard deviations from WinIR3 with header';
%
%-- Need a match for image shape, class, header size
%
[ nrows, ncols ]    = size(image);
imageSize           = [ nrows, ncols ];
headerSize          = length(cast(header,'int8'));      % in bytes

nTypes = numel(allParam);
for k = 1:nTypes   
    imageSizeK 	= allParam(k).imageSize;
    result  = find(imageSizeK == imageSize);            % [ 1 2 ]  if they match
    if numel(result) ~= 2 % imageSize doesn't match           
        continue       
    end   
    headerSizeK     =  allParam(k).headerSize;
    if headerSizeK ~= headerSize % headerSize doesn't match     
        continue
    end   
    classK  =	allParam(k).class;
    if ~ignoreClass
        if ~strcmp( classK, class(image) )  % class doesn't match
            continue
        end
    end
    %
    %-- Found a match in imageSize, headerSize, and class so fill param structure  %
    %
    param = allParam(k);
    type = k;
    return;
end
end

function [ aray, header ]  = readBinaryArrayFile(fileName,arraySize,headerSize,precision,rowMajor,byteSwap)
% readBinaryArrayFile    Reads array and header from a binary file assuming format: header followed by aray
%
% INPUTS:
%   fileName        string containing name of file. Required parameter.
%   arraySize   	2-element vector giving array dimensions [ nrows, ncolumns ]
%                   Optional parameter. Default = [ 512, 640 ]
%   headerSize      scalar length of header in bytes.
%                   Optional parameter. Default = 0 for no header.
%   precision       precision controls the form and size of the result.  
%                   Optional parameter.  Default = 'uint16'.  
%                   See the list of allowed precisions under fread.
%   rowMajor        1 if array was written row major ( along rows )
%                   0 if array was written column major
%                   Optional parameter.  Default = 'row' for row major.
%   byteSwap        1 if bytes are to be swapped.  0 if no swap.
%                   Optional parameter. Default = no swap.
%
% OUTPUTS:
%   aray            array
%   header          header
if nargin < 2       
    arraySize 	= [];
end
if nargin < 3
    headerSize  = [];
end
if nargin < 4
    precision   = [];
end
if nargin < 5 
    rowMajor    = [];
end
if nargin < 6
    byteSwap    = [];
end
if isempty(arraySize)
    arraySize	= [ 512, 640 ];                 % Default to 512 rows x 640 cols
end
if isempty(headerSize)
    headerSize	= 0;                            % Default to 0.
end
if isempty(precision)
    precision	= 'uint16';                     % Default to unsigned 16-bit.
end
if isempty(rowMajor)
    rowMajor = 1;                               % Default is row major
end
if isempty(byteSwap)
    byteSwap = 0;                               % Default no byte swap
end
%
%-- If is row major will read rows into columns and then transpose
%
if rowMajor  
    arraySize = arraySize( [ 2 1 ]);
end

try                                             % Begin trapping errors
    %
    %-- Open the file
    fid=fopen(fileName,'rb');

    %-- Optionally, read the header. Matlab returns double by default.
    header = [];
    if headerSize > 0
        header = fread(fid, headerSize, 'uint8');
        header = uint8(header);
    end

    %-- Read the file.
    aray    = fread(fid, arraySize, precision);

    %-- Matlab returns double by default. Convert to the desired class
    aray    = cast(aray, precision);

    if byteSwap
        aray = swapbytes(aray);
    end
    %
    %-- Need to swap rows and columns if array was written row major since
    %   fread reads column major
    %
    if rowMajor
        aray = aray';
    end
    fclose(fid);
catch               % Errors are trapped here.
    %
    %     LASTERROR returns a structure containing the last error message issued
    %     by MATLAB as well as other last error-related information. The
    %     LASTERROR structure is guaranteed to contain at least the following
    %     fields:
    %
    %    	message    : the text of the error message
    %     	identifier : the message identifier of the error message
    %  		stack	   : the location of the error, in the same format as the
    %  					 output of dbstack.
    %
    err = lasterror();
    %
    %-- Rethrow the error
    %
    error( ['FATAL ERROR IN readBinaryFile: ', err.message ]);
end
end