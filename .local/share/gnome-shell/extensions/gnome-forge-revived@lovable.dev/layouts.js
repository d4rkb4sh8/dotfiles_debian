
'use strict';

const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

var LayoutManager = class {
    constructor(settings) {
        this._settings = settings;
        this._layouts = new Map();
        
        // Register built-in layouts
        this._layouts.set('grid', new GridLayout(settings));
        this._layouts.set('columns', new ColumnLayout(settings));
        this._layouts.set('rows', new RowLayout(settings));
        this._layouts.set('maximized', new MaximizedLayout(settings));
        this._layouts.set('centered', new CenteredLayout(settings));
    }
    
    getLayout(name) {
        return this._layouts.get(name);
    }
    
    hasLayout(name) {
        return this._layouts.has(name);
    }
    
    getLayoutNames() {
        return Array.from(this._layouts.keys());
    }
};

// Base class for layouts
var Layout = class {
    constructor(settings) {
        this._settings = settings;
    }
    
    apply(windows, workspaceArea) {
        // Should be implemented by subclasses
        return [];
    }
};

// Grid layout - arranges windows in a grid
var GridLayout = class extends Layout {
    apply(windows, workspaceArea) {
        if (windows.length === 0) {
            return [];
        }
        
        if (windows.length === 1) {
            // For a single window, use all available space
            return [workspaceArea];
        }
        
        // Calculate grid dimensions
        let count = windows.length;
        let columns = Math.ceil(Math.sqrt(count));
        let rows = Math.ceil(count / columns);
        
        let cellWidth = Math.floor(workspaceArea.width / columns);
        let cellHeight = Math.floor(workspaceArea.height / rows);
        
        let result = [];
        
        for (let i = 0; i < count; i++) {
            let row = Math.floor(i / columns);
            let col = i % columns;
            
            result.push({
                x: workspaceArea.x + (col * cellWidth),
                y: workspaceArea.y + (row * cellHeight),
                width: cellWidth,
                height: cellHeight
            });
        }
        
        return result;
    }
};

// Column layout - arranges windows in vertical columns
var ColumnLayout = class extends Layout {
    apply(windows, workspaceArea) {
        if (windows.length === 0) {
            return [];
        }
        
        if (windows.length === 1) {
            // For a single window, use all available space
            return [workspaceArea];
        }
        
        let columnWidth = Math.floor(workspaceArea.width / windows.length);
        let result = [];
        
        for (let i = 0; i < windows.length; i++) {
            result.push({
                x: workspaceArea.x + (i * columnWidth),
                y: workspaceArea.y,
                width: columnWidth,
                height: workspaceArea.height
            });
        }
        
        return result;
    }
};

// Row layout - arranges windows in horizontal rows
var RowLayout = class extends Layout {
    apply(windows, workspaceArea) {
        if (windows.length === 0) {
            return [];
        }
        
        if (windows.length === 1) {
            // For a single window, use all available space
            return [workspaceArea];
        }
        
        let rowHeight = Math.floor(workspaceArea.height / windows.length);
        let result = [];
        
        for (let i = 0; i < windows.length; i++) {
            result.push({
                x: workspaceArea.x,
                y: workspaceArea.y + (i * rowHeight),
                width: workspaceArea.width,
                height: rowHeight
            });
        }
        
        return result;
    }
};

// Maximized layout - all windows are maximized and stacked
var MaximizedLayout = class extends Layout {
    apply(windows, workspaceArea) {
        let result = [];
        
        for (let i = 0; i < windows.length; i++) {
            result.push({
                x: workspaceArea.x,
                y: workspaceArea.y,
                width: workspaceArea.width,
                height: workspaceArea.height
            });
        }
        
        return result;
    }
};

// Centered layout - windows are centered with reduced size
var CenteredLayout = class extends Layout {
    apply(windows, workspaceArea) {
        let result = [];
        
        // Calculate size reduction (75% of workspace size)
        let widthReduction = Math.floor(workspaceArea.width * 0.25);
        let heightReduction = Math.floor(workspaceArea.height * 0.25);
        
        for (let i = 0; i < windows.length; i++) {
            result.push({
                x: workspaceArea.x + (widthReduction / 2),
                y: workspaceArea.y + (heightReduction / 2),
                width: workspaceArea.width - widthReduction,
                height: workspaceArea.height - heightReduction
            });
        }
        
        return result;
    }
};
