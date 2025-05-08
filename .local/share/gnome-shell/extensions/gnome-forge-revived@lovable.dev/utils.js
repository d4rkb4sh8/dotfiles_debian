
'use strict';

const GLib = imports.gi.GLib;

// Utility function for logging with timestamp
function log(message) {
    let timestamp = new Date().toISOString();
    global.log(`[GnomeForgeRevived][${timestamp}] ${message}`);
}

// Debounce function to prevent excessive calls
function debounce(func, wait) {
    let timeout = null;
    
    return function(...args) {
        let context = this;
        
        if (timeout !== null) {
            GLib.source_remove(timeout);
        }
        
        timeout = GLib.timeout_add(GLib.PRIORITY_DEFAULT, wait, () => {
            func.apply(context, args);
            timeout = null;
            return GLib.SOURCE_REMOVE;
        });
    };
}

// Get the application ID from a window
function getAppIdFromWindow(window) {
    if (!window) {
        return null;
    }
    
    let app = window.get_meta_window().get_gtk_application_id();
    if (!app) {
        // Fallback to WM_CLASS
        app = window.get_meta_window().get_wm_class();
    }
    
    return app;
}

// Export utility functions
var loggingEnabled = true;
var debug = loggingEnabled ? log : function() {};
var exports = {
    log,
    debug,
    debounce,
    getAppIdFromWindow
};
