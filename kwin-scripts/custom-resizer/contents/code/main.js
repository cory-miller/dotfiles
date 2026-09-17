// Register a global keyboard shortcut
registerShortcut(
    "ResizeToPreset", 
    "Resize Active Window to 1792x1008", 
    "Meta+Alt+C", 
    function() {
        var window = workspace.activeWindow;

        if (!window) return;

        if (window.maximizeMode !== 0 || window.maximized) {
            const vertically = false;
            const horizontally = false;
            window.setMaximize(false, false);
        }

        window.frameGeometry = {
            x: window.frameGeometry.x,
            y: window.frameGeometry.y,
            width: 1792,
            height: 1008,
        };
    }
);

