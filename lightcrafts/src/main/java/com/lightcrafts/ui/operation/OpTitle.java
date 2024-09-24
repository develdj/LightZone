/* Copyright (C) 2005-2011 Fabio Riccardi */
/* Copyright (C) 2024-     Masahiro Kitagawa */

package com.lightcrafts.ui.operation;

import com.formdev.flatlaf.icons.FlatInternalFrameCloseIcon;
import com.lightcrafts.model.Operation;
import static com.lightcrafts.ui.operation.Locale.LOCALE;
import com.lightcrafts.utils.xml.XMLException;
import com.lightcrafts.utils.xml.XmlDocument;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.Dimension;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.util.prefs.Preferences;

/**
 * A title bar for OpControls, including a label for the Operation and
 * standard controls like show/hide, enable/disable, and remove.
 */

class OpTitle extends SelectableTitle {

    // Preferences are used to remember OpControl presets:
    private final static Preferences Prefs =
        Preferences.userNodeForPackage(OpTitle.class);
    private final static String PresetsKey = "Presets";

    private final static Dimension removeButtonSize = new Dimension(16, 16);

    private OpControl control;
    private JCheckBox activeCheckBox;
    private JButton removeButton;
    private OpTitleEditor editor;

    OpTitle(final OpControl control, final OpStack stack) {
        super(control);
        this.control = control;

        editor = new OpTitleEditor(this, control.undoSupport);
        editor.setLabel(label);

        Operation op = control.getOperation();
        BufferedImage image = OpActions.getIcon(op);
        setIcon(image);

        activeCheckBox = new JCheckBox("", true);
        activeCheckBox.setToolTipText(LOCALE.get("DisableToolTip"));
        activeCheckBox.setRolloverEnabled(true);
        activeCheckBox.setSelected(true);
        activeCheckBox.addActionListener(event -> {
            boolean active = activeCheckBox.isSelected();
            String tip = active ? LOCALE.get("DisableToolTip") : LOCALE.get("EnableToolTip");
            activeCheckBox.setToolTipText(tip);
            control.setActivated(activeCheckBox.isSelected());
        });

        removeButton = new JButton(new FlatInternalFrameCloseIcon());
        removeButton.setToolTipText(LOCALE.get("RemoveToolTip"));
        removeButton.setPreferredSize(removeButtonSize);
        removeButton.setMaximumSize(removeButtonSize);
        removeButton.setContentAreaFilled(false);
        removeButton.setBorder(null);
        removeButton.addActionListener(event -> stack.removeControl(control));

        if (! control.isRawCorrection()) {
            buttonBox.add(activeCheckBox);
            // buttonBox.add(Box.createHorizontalStrut(ButtonSpace));
            buttonBox.add(removeButton);
            // buttonBox.add(Box.createHorizontalStrut(ButtonSpace));
        }
    }

    OpControl getControl() {
        return control;
    }

    void setActive(boolean active) {
        // Won't generate an ActionEvent, so no risk of recursion with the
        // activeButton ActionListener:
        activeCheckBox.setSelected(active);
    }

    void resetTitle(String title) {
        super.resetTitle(title);
        if (editor != null) {
            // (Called from base class constructor, when editor may be null)
            editor.setLabel(label);
        }
    }

    JPopupMenu getPopupMenu() {
        JPopupMenu menu = super.getPopupMenu();

        final OpStack stack = findOpStack();

        boolean isLocked = control.isLocked();

        if (! control.isRawCorrection()) {
            if (! control.isActivated()) {
                JMenuItem enableItem = new JMenuItem(
                    LOCALE.get("EnableMenuItem")
                );
                enableItem.addActionListener(
                    new ActionListener() {
                        public void actionPerformed(ActionEvent event) {
                            control.setActivated(true);
                        }
                    }
                );
                enableItem.setEnabled(! isLocked);
                menu.add(enableItem, 0);
            }
            else {
                JMenuItem disableItem = new JMenuItem(
                    LOCALE.get("DisableMenuItem")
                );
                disableItem.addActionListener(
                    new ActionListener() {
                        public void actionPerformed(ActionEvent event) {
                            control.setActivated(false);
                        }
                    }
                );
                disableItem.setEnabled(! isLocked);
                menu.add(disableItem, 0);
            }
            menu.add(new JSeparator(), 1);
        }
        if (! isLocked) {
            JMenuItem lockItem = new JMenuItem(
                LOCALE.get("LockMenuItem")
            );
            lockItem.addActionListener(
                new ActionListener() {
                    public void actionPerformed(ActionEvent event) {
                        control.setLocked(true);
                    }
                }
            );
            menu.add(lockItem, 2);
        }
        else {
            JMenuItem unlockItem = new JMenuItem(
                LOCALE.get("UnlockMenuItem")
            );
            unlockItem.addActionListener(
                new ActionListener() {
                    public void actionPerformed(ActionEvent event) {
                        control.setLocked(false);
                    }
                }
            );
            menu.add(unlockItem, 2);
        }
        menu.add(new JSeparator(), 3);

        JMenuItem savePreset = new JMenuItem(
            LOCALE.get("RememberPresetMenuItem")
        );
        savePreset.addActionListener(
            new ActionListener() {
                public void actionPerformed(ActionEvent event) {
                    XmlDocument preset = new XmlDocument("Preset");
                    control.save(preset.getRoot());
                    writePreset(preset);
                }
            }
        );
        menu.add(savePreset, 4);

        JMenuItem applyPreset = new JMenuItem(
            LOCALE.get("ApplyPresetMenuItem")
        );
        final XmlDocument preset = readPreset();
        applyPreset.addActionListener(
            new ActionListener() {
                public void actionPerformed(ActionEvent event) {
                    try {
                        // Like control.restore(), but with undo:
                        control.restorePresets(preset.getRoot());
                    }
                    catch (XMLException e) {
                        // No way to back out of this, so leave things as
                        // they are and hope the user can recover.
                        System.err.println(
                            "Error in preset restore: " + e.getMessage()
                        );
                    }
                }
            }
        );
        if ((preset == null) || isLocked) {
            applyPreset.setEnabled(false);
        }
        menu.add(applyPreset, 5);

        if (! control.isRawCorrection()) {
            JMenuItem deleteItem = new JMenuItem(LOCALE.get("DeleteMenuItem"));
            deleteItem.addActionListener(
                new ActionListener() {
                    public void actionPerformed(ActionEvent event) {
                        stack.removeControl(control);
                    }
                }
            );
            deleteItem.setEnabled(! isLocked);

            menu.add(new JSeparator());

            menu.add(deleteItem);
        }
        return menu;
    }

    // Read in the preset for the current OpControl type from Preferences,
    // or null if no such preset exists.
    private XmlDocument readPreset() {
        String key = getPresetsKey();
        String text = Prefs.get(key, "");
        try {
            ByteArrayInputStream in =
                new ByteArrayInputStream(text.getBytes("UTF-8"));
            return new XmlDocument(in);
        }
        catch (Exception e) {   // IOException or XMLException
            return null;
        }
    }

    // Save the given preset in Preferences for the current OpControl type.
    private void writePreset(XmlDocument preset) {
        String key = getPresetsKey();
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            preset.write(out);
            String text = out.toString("UTF-8");
            Prefs.put(key, text);
            Prefs.sync();
        }
        catch (Exception e) {   // IOException or BackingStoreException
            // Make sure the "Apply Preset" item doesn't get enabled:
            Prefs.remove(key);
        }
    }

    private String getPresetsKey() {
        String name = control.getOperation().getType().getName();
        return PresetsKey + name;
    }
}
