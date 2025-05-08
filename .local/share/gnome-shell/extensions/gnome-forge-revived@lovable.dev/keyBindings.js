
'use strict';

const Main = imports.ui.main;
const Meta = imports.gi.Meta;
const Shell = imports.gi.Shell;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

var KeyBindingManager = class {
    constructor(windowManager, settings) {
        this._windowManager = windowManager;
        this._settings = settings;
        this._keyBindings = [];
    }
    
    enable() {
        // Set up key bindings
        this._addKeybindings();
    }
    
    disable() {
        // Remove all key bindings
        this._removeKeybindings();
    }
    
    _addKeybindings() {
        // Define all key bindings
        this._keyBindings = [
            {
                name: 'toggle-floating',
                shortcut: '<Super>f',
                callback: () => this._windowManager.toggleFloating()
            },
            {
                name: 'maximize-window',
                shortcut: '<Super>m',
                callback: () => this._windowManager.maximizeWindow()
            },
            {
                name: 'focus-left',
                shortcut: '<Super>h',
                callback: () => this._windowManager.focusWindow('left')
            },
            {
                name: 'focus-right',
                shortcut: '<Super>l',
                callback: () => this._windowManager.focusWindow('right')
            },
            {
                name: 'focus-up',
                shortcut: '<Super>k',
                callback: () => this._windowManager.focusWindow('up')
            },
            {
                name: 'focus-down',
                shortcut: '<Super>j',
                callback: () => this._windowManager.focusWindow('down')
            },
            {
                name: 'layout-grid',
                shortcut: '<Super>g',
                callback: () => this._windowManager.switchLayout('grid')
            },
            {
                name: 'layout-columns',
                shortcut: '<Super>c',
                callback: () => this._windowManager.switchLayout('columns')
            },
            {
                name: 'layout-rows',
                shortcut: '<Super>r',
                callback: () => this._windowManager.switchLayout('rows')
            }
        ];
        
        // Add workspace switching bindings
        for (let i = 0; i < 9; i++) {
            this._keyBindings.push({
                name: `move-to-workspace-${i+1}`,
                shortcut: `<Super><Shift>${i+1}`,
                callback: () => this._windowManager.moveWindowToWorkspace(null, i)
            });
        }
        
        // Register all key bindings
        this._keyBindings.forEach(binding => {
            this._addKeybinding(binding.name, binding.shortcut, binding.callback);
        });
    }
    
    _removeKeybindings() {
        // Unregister all key bindings
        this._keyBindings.forEach(binding => {
            this._removeKeybinding(binding.name);
        });
        
        this._keyBindings = [];
    }
    
    _addKeybinding(name, shortcut, callback) {
        // Add a keybinding
        const fullName = `gnome-forge-revived-${name}`;
        Main.wm.addKeybinding(
            fullName,
            this._settings.getSchema(),
            Meta.KeyBindingFlags.NONE,
            Shell.ActionMode.NORMAL,
            callback
        );
    }
    
    _removeKeybinding(name) {
        // Remove a keybinding
        const fullName = `gnome-forge-revived-${name}`;
        Main.wm.removeKeybinding(fullName);
    }
};
