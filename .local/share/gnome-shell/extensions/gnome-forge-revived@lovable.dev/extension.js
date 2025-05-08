
'use strict';

const Main = imports.ui.main;
const Meta = imports.gi.Meta;
const Shell = imports.gi.Shell;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();
const WindowManager = Me.imports.windowManager;
const KeyBindings = Me.imports.keyBindings;
const Settings = Me.imports.settings;
const Utils = Me.imports.utils;

class Extension {
    constructor() {
        this._windowManager = null;
        this._keyBindings = null;
        this._settings = null;
    }

    enable() {
        console.log(`Enabling ${Me.metadata.name} extension`);
        
        // Initialize settings
        this._settings = new Settings.ForgeSettings();
        
        // Initialize window manager
        this._windowManager = new WindowManager.WindowManager(this._settings);
        this._windowManager.enable();
        
        // Initialize key bindings
        this._keyBindings = new KeyBindings.KeyBindingManager(this._windowManager, this._settings);
        this._keyBindings.enable();
        
        // Connect signals
        this._connectSignals();
        
        console.log(`${Me.metadata.name} extension enabled`);
    }
    
    disable() {
        console.log(`Disabling ${Me.metadata.name} extension`);
        
        // Disconnect signals
        this._disconnectSignals();
        
        // Disable key bindings
        if (this._keyBindings) {
            this._keyBindings.disable();
            this._keyBindings = null;
        }
        
        // Disable window manager
        if (this._windowManager) {
            this._windowManager.disable();
            this._windowManager = null;
        }
        
        // Clean up settings
        if (this._settings) {
            this._settings.destroy();
            this._settings = null;
        }
        
        console.log(`${Me.metadata.name} extension disabled`);
    }
    
    _connectSignals() {
        // Connect to window creation signals to automatically manage new windows
        this._windowCreatedId = global.display.connect(
            'window-created', 
            this._onWindowCreated.bind(this)
        );
        
        // Connect to workspace signals
        this._workspaceSwitchedId = global.workspace_manager.connect(
            'workspace-switched',
            this._onWorkspaceSwitched.bind(this)
        );
    }
    
    _disconnectSignals() {
        // Disconnect all signals
        if (this._windowCreatedId) {
            global.display.disconnect(this._windowCreatedId);
            this._windowCreatedId = null;
        }
        
        if (this._workspaceSwitchedId) {
            global.workspace_manager.disconnect(this._workspaceSwitchedId);
            this._workspaceSwitchedId = null;
        }
    }
    
    _onWindowCreated(display, metaWindow) {
        // Let the window manager handle the new window
        if (this._windowManager) {
            this._windowManager.handleWindow(metaWindow);
        }
    }
    
    _onWorkspaceSwitched(workspaceManager, oldIndex, newIndex) {
        // Let the window manager handle workspace switching
        if (this._windowManager) {
            this._windowManager.onWorkspaceSwitched(oldIndex, newIndex);
        }
    }
}

function init() {
    console.log(`Initializing ${Me.metadata.name} extension`);
    return new Extension();
}
