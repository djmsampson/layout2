classdef FigureFixture < matlab.unittest.fixtures.Fixture
    % FigureFixture creates a figure or uifigure in the property FigureHandle. The
    % figure is deleted when the fixture is torn down.
    properties
        FigureHandle
        FigureType
    end
    
    methods  
        function fixture = FigureFixture(type)
            fixture.FigureType = type;
        end
        
        function setup(fixture)
            if strcmp(fixture.FigureType,'uifigure')
                fixture.FigureHandle = uifigure('Visible', 'on');  
            elseif strcmp(fixture.FigureType,'figure')
                fixture.FigureHandle = figure('Visible', 'on');  
            end
        end
        
        function teardown(fixture)     
            if ~isempty(fixture.FigureHandle)&&isvalid(fixture.FigureHandle)
                delete(fixture.FigureHandle)
            end      
        end
    end
    
      methods (Access=protected)
        function bool = isCompatible(fixture, other)
            bool = strcmp(fixture.FigureType, other.FigureType);
        end
    end
end