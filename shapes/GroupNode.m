classdef GroupNode < SceneNode
%GROUPNODE Contatenates a group of nodes
%
%   Class GroupNode
%
%   Example
%   GroupNode
%
%   See also
%

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2019-04-03,    using Matlab 9.5.0.944444 (R2018b)
% Copyright 2019 INRA - BIA-BIBS.


%% Properties
properties
    % the list of children, as a cell array containing SceneNode instances
    Children
    
end % end properties


%% Constructor
methods
    function obj = GroupNode(varargin)
    % Constructor for GroupNode class

    end

end % end constructors


%% Methods
methods
    function add(obj, node)
        if ~isa(node, 'SceneNode')
            error('Requires a SceneNode object');
        end
        obj.Children = [obj.Children {node}];
    end
    
end % end methods


%% Methods specializing the SceneNode superclass
methods
    function b = isLeaf(obj)
        % returns true only if this node contains no children
        b = isempty(obj.Children);
    end
end


end % end classdef

