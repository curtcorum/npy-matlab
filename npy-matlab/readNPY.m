

function data = readNPY(filename)
% Function to read NPY files into matlab.
% *** Only reads a subset of all possible NPY files, specifically N-D arrays of certain data types.
% See https://github.com/kwikteam/npy-matlab/blob/master/tests/npy.ipynb for
% more.
%

[shape, dataType, fortranOrder, littleEndian, totalHeaderLength, ~] = readNPYheader(filename);

if littleEndian
    fid = fopen(filename, 'r', 'l');
else
    fid = fopen(filename, 'r', 'b');
end

try

    [~] = fread(fid, totalHeaderLength, 'uint8');

    % read the data
    %data = fread(fid, prod(shape), [dataType '=>' dataType]);
    % modifications from https://github.com/kwikteam/npy-matlab/issues/9
    if strcmp(dataType, "complex8") == 1
       data = fread(fid, prod(shape)*2, 'single=>single');
       data = data(1:2:end) + 1j * data(2:2:end);
    elseif strcmp(dataType, "complex16") == 1
       data = fread(fid, prod(shape)*2, 'double=>double');
       data = data(1:2:end) + 1j * data(2:2:end);
    else
       data = fread(fid, prod(shape), [dataType '=>' dataType]);
    end

    if length(shape)>1 && ~fortranOrder
        data = reshape(data, shape(end:-1:1));
        data = permute(data, [length(shape):-1:1]);
    elseif length(shape)>1
        data = reshape(data, shape);
    end

    fclose(fid);

catch me
    fclose(fid);
    rethrow(me);
end
