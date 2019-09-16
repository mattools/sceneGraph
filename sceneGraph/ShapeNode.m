classdef ShapeNode < SceneNode
% Contains information to draw a 2D or 3D shape.
%
%   The shape class encapsulates information about the Geometry of the
%   shape (as an instance of Geometry class) and drawing options (as an
%   instance of the Style class).
%
%   Example
%     poly = Polygon2D([10 10; 20 10; 20 20; 10 20]);
%     shape = ShapeNode(poly);
%     figure; hold on; axis equal; axis([0 50 0 50]);
%     draw(shape);
%
%   See also
%     SceneNode, Geometry, Style

% ------
% Author: David Legland
% e-mail: david.legland@inra.fr
% Created: 2018-08-13,    using Matlab 8.6.0.267246 (R2015b)
% Copyright 2018 INRA - BIA-BIBS.


%% Properties
properties
    % The geometry of the shape, as an instance of Geometry
    Geometry;
    
    % The options for drawing the shape, as an instance of Style
    Style;
    
end % end properties


%% Constructor
methods
    function obj = ShapeNode(varargin)
        % Constructor for ShapeNode class
        %
        %   usage:
        %   shape = ShapeNode(geom)
        %   shape = ShapeNode(geom, Style)
        %

        if nargin == 0
            error('Requires at least one input argument');
        end
        
        var1 = varargin{1};
        if isa(var1, 'ShapeNode')
            % copy constructor
            obj.Geometry = var1.Geometry; % Geometry is not duplicated
            obj.Style = Style(var1.Style);
            obj.Visible = var1.Visible;
            obj.Name = var1.Name;
            return;
        end
        if isa(var1, 'Shape')
            % Conversion from old "Scene" class
            obj.Geometry = var1.Geometry; % Geometry is not duplicated
            obj.Style = Style(var1.Style);
            obj.Visible = var1.Visible;
            obj.Name = var1.Name;
            return;
        end
        
        if ~isa(var1, 'Geometry')
            error('First argument must be a Geometry or a ShapeNode');
        end
        
        % initialisation of geometry
        obj.Geometry = varargin{1};
        obj.Style = createDefaultStyle(obj.Geometry);
        varargin(1) = [];
        
        % process optionnal style
        if ~isempty(varargin) && isa(varargin{1}, 'Style')
            obj.Style = varargin{1};
            varargin(1) = [];
        end

        % process additionnal parameter name-value pairs
        while length(varargin) > 1
            name = varargin{1};
            switch lower(name)
                case 'name'
                    obj.Name = varargin{2};
                case 'style'
                    obj.Style = varargin{2};
                case 'visible'
                    obj.Visible = varargin{2};
                otherwise
                    error(['Unknown argument name: ' name]);
            end
            varargin(1:2) = [];
        end
        
        function style = createDefaultStyle(geom)
        % inner function for creating default style
            if isa(geom, 'Point2D') || isa(geom, 'MultiPoint2D')
                style = Style('MarkerVisible', true, 'LineVisible', false);
            elseif isa(geom, 'Mesh3D')
                style = Style('FaceVisible', true);
            else
                % default style
                style = Style();
            end
        end
    end

end % end constructors


%% Methods
methods
    function varargout = draw(obj)
        % Draws obj shape on the current axis
        h = draw(obj.Geometry, obj.Style);
        if nargout > 0
            varargout = {h};
        end
    end
    
end % end methods


%% Methods specializing the SceneNode superclass
methods
    function node = transform(obj, transfo)
        geom = transform(obj.Geometry, transfo);
        node = ShapeNode(geom, obj.Style);
    end
    
    function box = boundingBox(obj)
        % Converts the bounding box ot the inner geometry to a 1-by-6 vector
        geom = obj.Geometry;
        if isa(geom, 'Geometry2D')
            box2d = boundingBox(geom);
            box = [box2d.XMin box2d.XMax box2d.YMin box2d.YMax 0 0];
        elseif isa(geom, 'Geometry3D')
            box3d = boundingBox(geom);
            box = [box3d.XMin box3d.XMax box3d.YMin box3d.YMax box3d.ZMin box3d.ZMax];
        else
            error(['instance of Geometry2D or Geometry3D is expected, not ' class(geom)]);
        end
    end
    
    function printTree(obj, nIndents)
        str = [repmat('  ', 1, nIndents) '[ShapeNode] (' class(obj.Geometry) ')'];
        disp(str);
    end

    function b = isLeaf(obj) %#ok<MANU>
        b = true;
    end
end


%% Serialization methods
methods
    function str = toStruct(obj)
        % Convert to a structure to facilitate serialization

        str.Type = 'Shape';
        
        % call scene node method
        str = convertSceneNodeFields(obj, str);
        
        % add optional Style
        if ~isempty(obj.Style)
            str.Style = toStruct(obj.Style);
        end

        % creates a structure for Geometry, including class Name
        str.Geometry = toStruct(obj.Geometry);
        if ~isfield(str.Geometry, 'Type')
            type = classname(obj.Geometry);
            warning(['Geometry type not specified, use class Name: ' type]);
            str.Geometry.Type = type;
        end
    end
    
    function write(obj, fileName, varargin)
        % Write into a JSON file
        savejson('', toStruct(obj), 'FileName', fileName, varargin{:});
    end
end

methods (Static)
    function node = fromStruct(str)
        % Creates a new instance from a structure
        
        % parse Geometry
        type = str.Geometry.Type;
        geom = eval([type '.fromStruct(str.Geometry)']);
        node = ShapeNode(geom);
        
        % parse the optionnal Name
        parseSceneNodeFields(node, str);

        % eventually parse Style
        if isfield(str, 'Style') && ~isempty(str.Style)
            node.Style = Style.fromStruct(str.Style);
        end
    end
    
    function shape = read(fileName)
        % Read a shape from a file in JSON format
        shape = ShapeNode.fromStruct(loadjson(fileName));
    end
end

end % end classdef

