%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=EqArrayAndScalars(varargin)
%function varargout=EqArrayAndScalars(varargin)
%
% This will compare a collection of inputs that must be either scalars or 
% arrays of the same size. If there is at least one array input, all scalar
% inputs will be replicated to be the array of that same size. If there are
% two or more array inputs that have different sizes, this will return an
% error.
%
% created by Matthew Nelson on April 13th, 2010
% matthew.j.nelson.vumail@gmail.com                        
d=zeros(nargin,1);
for ia=1:nargin    
    d(ia)=ndims(varargin{ia});
end
maxnd=max(d);
s=ones(nargin,maxnd);
    
for ia=1:nargin
    s(ia,1:d(ia))=size(varargin{ia});
end
maxs=max(s);
varargout=cell(nargin,1);
for ia=1:nargin
    if ~all(s(ia,:)==maxs)
        if ~all(s(ia,:)==1)
            error(['Varargin{' num2str(ia) '} needs to be a scalar or equal to the array size of other array inputs.'])
        else
            varargout{ia}=repmat(varargin{ia},maxs);
        end
    else
        varargout{ia}=varargin{ia};
    end
end