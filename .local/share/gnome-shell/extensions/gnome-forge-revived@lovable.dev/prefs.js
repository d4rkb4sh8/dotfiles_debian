
'use strict';

const Gio = imports.gi.Gio;
const Gtk = imports.gi.Gtk;
const GObject = imports.gi.GObject;
const ExtensionUtils = imports.misc.extensionUtils;
const Me = ExtensionUtils.getCurrentExtension();

function init() {
}

function buildPrefsWidget() {
    // Get the settings schema
    const settings = ExtensionUtils.getSettings(
        'org.gnome.shell.extensions.gnome-forge-revived'
    );
    
    // Create the preferences widget
    let prefsWidget = new Gtk.Grid({
        margin_top: 18,
        margin_bottom: 18,
        margin_start: 18,
        margin_end: 18,
        row_spacing: 12,
        column_spacing: 18,
        visible: true
    });
    
    // Layout selector section
    let layoutLabel = new Gtk.Label({
        label: 'Default Layout:',
        halign: Gtk.Align.START,
        visible: true
    });
    prefsWidget.attach(layoutLabel, 0, 0, 1, 1);
    
    let layoutCombo = new Gtk.ComboBoxText({
        halign: Gtk.Align.START,
        visible: true
    });
    layoutCombo.append('grid', 'Grid');
    layoutCombo.append('columns', 'Columns');
    layoutCombo.append('rows', 'Rows');
    layoutCombo.append('maximized', 'Maximized');
    layoutCombo.append('centered', 'Centered');
    prefsWidget.attach(layoutCombo, 1, 0, 1, 1);
    
    settings.bind(
        'default-layout',
        layoutCombo,
        'active-id',
        Gio.SettingsBindFlags.DEFAULT
    );
    
    // Gap size adjustment
    let gapLabel = new Gtk.Label({
        label: 'Window Gap Size:',
        halign: Gtk.Align.START,
        visible: true
    });
    prefsWidget.attach(gapLabel, 0, 1, 1, 1);
    
    let gapAdjustment = new Gtk.Adjustment({
        lower: 0,
        upper: 64,
        step_increment: 1
    });
    
    let gapSpinner = new Gtk.SpinButton({
        adjustment: gapAdjustment,
        numeric: true,
        snap_to_ticks: true,
        value: 8,
        visible: true
    });
    prefsWidget.attach(gapSpinner, 1, 1, 1, 1);
    
    settings.bind(
        'gap-size',
        gapSpinner,
        'value',
        Gio.SettingsBindFlags.DEFAULT
    );
    
    // Excluded applications section
    let excludedLabel = new Gtk.Label({
        label: 'Excluded Applications:',
        halign: Gtk.Align.START,
        visible: true
    });
    prefsWidget.attach(excludedLabel, 0, 2, 2, 1);
    
    let excludedScroll = new Gtk.ScrolledWindow({
        hexpand: true,
        vexpand: true,
        min_content_height: 200,
        visible: true
    });
    prefsWidget.attach(excludedScroll, 0, 3, 2, 1);
    
    // List for excluded apps
    let excludedStore = new Gtk.ListStore();
    excludedStore.set_column_types([GObject.TYPE_STRING]);
    
    let excludedTreeView = new Gtk.TreeView({
        model: excludedStore,
        headers_visible: false,
        visible: true
    });
    
    let excludedColumn = new Gtk.TreeViewColumn({
        title: 'Applications'
    });
    let excludedCell = new Gtk.CellRendererText();
    excludedColumn.pack_start(excludedCell, true);
    excludedColumn.add_attribute(excludedCell, 'text', 0);
    excludedTreeView.append_column(excludedColumn);
    
    excludedScroll.set_child(excludedTreeView);
    
    // Add/remove buttons for excluded apps
    let buttonBox = new Gtk.Box({
        orientation: Gtk.Orientation.HORIZONTAL,
        spacing: 6,
        homogeneous: true,
        visible: true
    });
    prefsWidget.attach(buttonBox, 0, 4, 2, 1);
    
    let addButton = new Gtk.Button({
        label: 'Add',
        visible: true
    });
    buttonBox.append(addButton);
    
    let removeButton = new Gtk.Button({
        label: 'Remove',
        visible: true
    });
    buttonBox.append(removeButton);
    
    // Initialize the list with current settings
    let excludedApps = settings.get_strv('excluded-apps');
    if (excludedApps) {
        excludedApps.forEach(app => {
            let iter = excludedStore.append();
            excludedStore.set(iter, [0], [app]);
        });
    }
    
    // Add button clicked
    addButton.connect('clicked', () => {
        let dialog = new Gtk.Dialog({
            title: 'Add Application',
            modal: true,
            use_header_bar: true
        });
        
        dialog.add_button('Cancel', Gtk.ResponseType.CANCEL);
        dialog.add_button('Add', Gtk.ResponseType.OK);
        
        let dialogContent = dialog.get_content_area();
        
        let entry = new Gtk.Entry({
            margin_top: 12,
            margin_bottom: 12,
            margin_start: 18,
            margin_end: 18,
            activates_default: true,
            visible: true
        });
        dialogContent.append(entry);
        
        dialog.set_default_response(Gtk.ResponseType.OK);
        
        dialog.connect('response', (dialog, id) => {
            if (id === Gtk.ResponseType.OK) {
                let text = entry.get_text().trim();
                if (text) {
                    // Add to the list
                    let iter = excludedStore.append();
                    excludedStore.set(iter, [0], [text]);
                    
                    // Update the settings
                    let newList = [];
                    let [valid, iter] = excludedStore.get_iter_first();
                    while (valid) {
                        let app = excludedStore.get_value(iter, 0);
                        newList.push(app);
                        valid = excludedStore.iter_next(iter);
                    }
                    
                    settings.set_strv('excluded-apps', newList);
                }
            }
            dialog.destroy();
        });
        
        dialog.show();
    });
    
    // Remove button clicked
    removeButton.connect('clicked', () => {
        let [selection, model, iter] = excludedTreeView.get_selection().get_selected();
        
        if (iter) {
            excludedStore.remove(iter);
            
            // Update the settings
            let newList = [];
            let [valid, iter] = excludedStore.get_iter_first();
            while (valid) {
                let app = excludedStore.get_value(iter, 0);
                newList.push(app);
                valid = excludedStore.iter_next(iter);
            }
            
            settings.set_strv('excluded-apps', newList);
        }
    });
    
    return prefsWidget;
}
