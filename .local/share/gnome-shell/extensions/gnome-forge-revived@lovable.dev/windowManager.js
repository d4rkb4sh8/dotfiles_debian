
'use strict';

const Main = imports.ui.main;
const Meta = imports.gi.Meta;
const Shell = imports.gi.Shell;
const Clutter = imports.gi.Clutter;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const Utils = Me.imports.utils;
const Layouts = Me.imports.layouts;

var WindowManager = class {
    constructor(settings) {
        this._settings = settings;
        this._windows = new Map();
        this._layouts = new Map();
        this._focusedWindow = null;
        this._ignoredWindows = new Set();
        
        // Initialize layouts
        this._layoutManager = new Layouts.LayoutManager(this._settings);
    }
    
    enable() {
        // Set up initial state
        this._setupInitialState();
        
        // Connect to window focus change
        this._windowFocusId = global.display.connect(
            'notify::focus-window', 
            this._onFocusWindow.bind(this)
        );
        
        // Connect to window size/position changes
        this._windowChangedId = global.window_manager.connect(
            'size-change',
            this._onWindowChanged.bind(this)
        );
    }
    
    disable() {
        // Disconnect signals
        if (this._windowFocusId) {
            global.display.disconnect(this._windowFocusId);
            this._windowFocusId = null;
        }
        
        if (this._windowChangedId) {
            global.window_manager.disconnect(this._windowChangedId);
            this._windowChangedId = null;
        }
        
        // Reset all windows to their original state
        this._restoreWindows();
        
        // Clear window tracking
        this._windows.clear();
        this._layouts.clear();
        this._ignoredWindows.clear();
        this._focusedWindow = null;
    }
    
    _setupInitialState() {
        // Process existing windows
        this._getWindows().forEach(window => {
            this.handleWindow(window);
        });
    }
    
    _restoreWindows() {
        // Restore all managed windows to normal state
        this._windows.forEach((info, window) => {
            if (!window.is_destroyed()) {
                window.unmake_fullscreen();
                window.unmaximize(Meta.MaximizeFlags.BOTH);
            }
        });
    }
    
    _getWindows() {
        // Get all windows from all workspaces
        let windows = [];
        let workspaceManager = global.workspace_manager;
        let n_workspaces = workspaceManager.get_n_workspaces();
        
        for (let i = 0; i < n_workspaces; i++) {
            let workspace = workspaceManager.get_workspace_by_index(i);
            windows = windows.concat(workspace.list_windows());
        }
        
        return windows.filter(this._isWindowValid.bind(this));
    }
    
    _getWindowsForWorkspace(workspace) {
        // Get all windows for a specific workspace
        let windows = workspace.list_windows();
        return windows.filter(this._isWindowValid.bind(this));
    }
    
    _isWindowValid(window) {
        // Check if a window should be managed by the extension
        if (this._ignoredWindows.has(window)) {
            return false;
        }
        
        // Skip windows that shouldn't be tiled
        let windowType = window.get_window_type();
        if (windowType !== Meta.WindowType.NORMAL) {
            return false;
        }
        
        // Skip windows with skip-taskbar hint
        if (window.is_skip_taskbar()) {
            return false;
        }
        
        return true;
    }
    
    handleWindow(window) {
        // Process a window and add it to management
        
        if (!this._isWindowValid(window)) {
            return;
        }
        
        // Store window info
        if (!this._windows.has(window)) {
            this._windows.set(window, {
                originalRect: this._getWindowRect(window),
                floating: false
            });
            
            // Connect to window signals
            let signalIds = [];
            signalIds.push(window.connect('unmanaging', () => {
                this._onWindowUnmanaged(window);
            }));
            
            this._windows.get(window).signalIds = signalIds;
        }
        
        // Apply the current layout to this window
        this._applyLayout();
    }
    
    _onWindowUnmanaged(window) {
        // Clean up when a window is closed
        if (this._windows.has(window)) {
            // Disconnect signals
            let info = this._windows.get(window);
            if (info.signalIds) {
                info.signalIds.forEach(id => {
                    if (window.is_destroyed()) return;
                    window.disconnect(id);
                });
            }
            
            // Remove from tracking
            this._windows.delete(window);
            
            // Re-tile remaining windows
            this._applyLayout();
        }
    }
    
    _onFocusWindow() {
        // Handle window focus changes
        let window = global.display.get_focus_window();
        
        if (window && this._windows.has(window)) {
            this._focusedWindow = window;
        }
    }
    
    _onWindowChanged(wm, window) {
        // Handle window size/position changes
        if (!window || !this._windows.has(window)) {
            return;
        }
        
        // Check if the user is manually resizing/moving
        let info = this._windows.get(window);
        let rect = this._getWindowRect(window);
        
        // If manually moved/resized and not already floating, mark as floating
        if (!info.floating && !this._isRectEqual(rect, info.lastTiledRect)) {
            info.floating = true;
            info.originalRect = rect;
        }
    }
    
    _getWindowRect(window) {
        // Get the window's rectangle
        let rect = window.get_frame_rect();
        return {
            x: rect.x,
            y: rect.y,
            width: rect.width,
            height: rect.height
        };
    }
    
    _isRectEqual(rect1, rect2) {
        // Compare two rectangles
        if (!rect1 || !rect2) return false;
        
        return rect1.x === rect2.x &&
               rect1.y === rect2.y &&
               rect1.width === rect2.width &&
               rect1.height === rect2.height;
    }
    
    _moveWindowToRect(window, rect) {
        // Move a window to the specified rectangle
        if (!window || window.is_destroyed()) {
            return;
        }
        
        // Apply gaps if configured
        let gaps = this._settings.getGapSize();
        let gapRect = {
            x: rect.x + gaps,
            y: rect.y + gaps,
            width: Math.max(1, rect.width - (gaps * 2)),
            height: Math.max(1, rect.height - (gaps * 2))
        };
        
        // Store the target rectangle for later comparison
        let info = this._windows.get(window);
        if (info) {
            info.lastTiledRect = gapRect;
        }
        
        // Move the window
        window.move_resize_frame(true, gapRect.x, gapRect.y, gapRect.width, gapRect.height);
    }
    
    _applyLayout() {
        // Apply the current layout to all windows in the current workspace
        let workspace = global.workspace_manager.get_active_workspace();
        let windows = this._getWindowsForWorkspace(workspace);
        
        // Filter out floating windows
        let tilingWindows = windows.filter(window => {
            let info = this._windows.get(window);
            return info && !info.floating;
        });
        
        // Get the workspace area
        let workspaceArea = this._getWorkspaceArea();
        
        // Get the current layout for this workspace
        let workspaceIndex = workspace.index();
        if (!this._layouts.has(workspaceIndex)) {
            // Default to grid layout
            this._layouts.set(workspaceIndex, 'grid');
        }
        let layoutName = this._layouts.get(workspaceIndex);
        
        // Apply the layout
        let layout = this._layoutManager.getLayout(layoutName);
        if (layout) {
            let windowRects = layout.apply(tilingWindows, workspaceArea);
            
            // Move windows to their calculated positions
            windowRects.forEach((rect, i) => {
                this._moveWindowToRect(tilingWindows[i], rect);
            });
        }
    }
    
    _getWorkspaceArea() {
        // Get the usable area of the current workspace
        let workspace = global.workspace_manager.get_active_workspace();
        let monitor = Main.layoutManager.primaryMonitor;
        
        // Account for panels and docks
        let workArea = workspace.get_work_area_for_monitor(monitor.index);
        
        return {
            x: workArea.x,
            y: workArea.y,
            width: workArea.width,
            height: workArea.height
        };
    }
    
    onWorkspaceSwitched(oldIndex, newIndex) {
        // Update layout when switching workspaces
        this._applyLayout();
    }
    
    // Public API methods for key bindings and other components to use
    
    toggleFloating(window = null) {
        // Toggle floating state for a window
        window = window || this._focusedWindow;
        if (!window || !this._windows.has(window)) {
            return;
        }
        
        let info = this._windows.get(window);
        info.floating = !info.floating;
        
        if (info.floating) {
            // Restore original size/position if available
            if (info.originalRect) {
                this._moveWindowToRect(window, info.originalRect);
            }
        } else {
            // Re-tile the window
            this._applyLayout();
        }
    }
    
    maximizeWindow(window = null) {
        // Maximize a window
        window = window || this._focusedWindow;
        if (!window || !this._windows.has(window)) {
            return;
        }
        
        if (window.get_maximized() === Meta.MaximizeFlags.BOTH) {
            window.unmaximize(Meta.MaximizeFlags.BOTH);
        } else {
            window.maximize(Meta.MaximizeFlags.BOTH);
        }
    }
    
    moveWindowToWorkspace(window, workspaceIndex) {
        // Move a window to a different workspace
        window = window || this._focusedWindow;
        if (!window || !this._windows.has(window)) {
            return;
        }
        
        let workspace = global.workspace_manager.get_workspace_by_index(workspaceIndex);
        if (workspace) {
            window.change_workspace(workspace);
            
            // Focus the moved window on its new workspace
            workspace.activate_with_focus(window, global.get_current_time());
        }
    }
    
    switchLayout(layoutName) {
        // Switch to a different layout for the current workspace
        let workspace = global.workspace_manager.get_active_workspace();
        let workspaceIndex = workspace.index();
        
        if (this._layoutManager.hasLayout(layoutName)) {
            this._layouts.set(workspaceIndex, layoutName);
            this._applyLayout();
        }
    }
    
    focusWindow(direction) {
        // Focus the window in the given direction
        if (!this._focusedWindow) {
            return;
        }
        
        let windows = this._getWindowsForCurrentWorkspace();
        if (windows.length <= 1) {
            return;
        }
        
        let currentWindow = this._focusedWindow;
        let currentRect = this._getWindowRect(currentWindow);
        
        // Find the closest window in the specified direction
        let candidate = null;
        let minDistance = Infinity;
        
        windows.forEach(window => {
            if (window === currentWindow) {
                return;
            }
            
            let rect = this._getWindowRect(window);
            let distance = this._getDistanceInDirection(currentRect, rect, direction);
            
            if (distance >= 0 && distance < minDistance) {
                minDistance = distance;
                candidate = window;
            }
        });
        
        // Focus the candidate window
        if (candidate) {
            candidate.activate(global.get_current_time());
        }
    }
    
    _getWindowsForCurrentWorkspace() {
        // Get windows on the current workspace
        let workspace = global.workspace_manager.get_active_workspace();
        return this._getWindowsForWorkspace(workspace);
    }
    
    _getDistanceInDirection(rect1, rect2, direction) {
        // Calculate distance between rectangles in a specific direction
        let center1 = { x: rect1.x + rect1.width / 2, y: rect1.y + rect1.height / 2 };
        let center2 = { x: rect2.x + rect2.width / 2, y: rect2.y + rect2.height / 2 };
        
        switch (direction) {
            case 'left':
                if (center2.x >= center1.x) return -1;
                return center1.x - center2.x;
                
            case 'right':
                if (center2.x <= center1.x) return -1;
                return center2.x - center1.x;
                
            case 'up':
                if (center2.y >= center1.y) return -1;
                return center1.y - center2.y;
                
            case 'down':
                if (center2.y <= center1.y) return -1;
                return center2.y - center1.y;
        }
        
        return -1;
    }
};
