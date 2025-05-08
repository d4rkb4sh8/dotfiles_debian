
'use strict';

const Gio = imports.gi.Gio;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

var ForgeSettings = class {
    constructor() {
        this._schema = null;
        
        // Try to get the schema
        try {
            this._schema = this._loadSchema();
            
            if (!this._schema) {
                // Create default settings if schema not found
                this._createDefaultSettings();
            }
        } catch (e) {
            console.error(`Failed to load settings: ${e}`);
            this._createDefaultSettings();
        }
    }
    
    _loadSchema() {
        // Load the settings schema
        const schemaDir = Me.dir.get_child('schemas');
        let schemaSource;
        
        if (schemaDir.query_exists(null)) {
            schemaSource = Gio.SettingsSchemaSource.new_from_directory(
                schemaDir.get_path(),
                Gio.SettingsSchemaSource.get_default(),
                false
            );
        } else {
            schemaSource = Gio.SettingsSchemaSource.get_default();
        }
        
        const schemaObj = schemaSource.lookup(
            'org.gnome.shell.extensions.gnome-forge-revived',
            true
        );
        
        if (schemaObj) {
            return new Gio.Settings({ settings_schema: schemaObj });
        }
        
        return null;
    }
    
    _createDefaultSettings() {
        // Create default settings object when schema is not found
        this._defaults = {
            'gap-size': 8,
            'default-layout': 'grid',
            'excluded-apps': []
        };
    }
    
    getSchema() {
        return this._schema;
    }
    
    getGapSize() {
        if (this._schema) {
            return this._schema.get_int('gap-size');
        }
        return this._defaults['gap-size'];
    }
    
    getDefaultLayout() {
        if (this._schema) {
            return this._schema.get_string('default-layout');
        }
        return this._defaults['default-layout'];
    }
    
    getExcludedApps() {
        if (this._schema) {
            return this._schema.get_strv('excluded-apps');
        }
        return this._defaults['excluded-apps'];
    }
    
    destroy() {
        this._schema = null;
        this._defaults = null;
    }
};
