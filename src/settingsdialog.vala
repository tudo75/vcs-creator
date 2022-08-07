/* settingsdialog.vala
 *
 * Copyright 2022 Nicola tudo75 Tudino
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace VcsCreator {

    public class SettingsDialog : Gtk.Dialog {

        private KeyFile _keyfile;
        private string conf_file = GLib.Environment.get_home_dir () + "/.vcs.conf";

        private Gtk.RadioButton capture_mode_interval;
        private Gtk.RadioButton capture_mode_numcaps;
        private Gtk.RadioButton format_png;
        private Gtk.RadioButton format_jpg;

        private Gtk.Switch signature_switch;
        private Gtk.Switch shadows_switch;
        private Gtk.Switch timestamps_switch;

        private Gtk.SpinButton interval_spin;
        private Gtk.SpinButton numcaps_spin;
        private Gtk.SpinButton quality_spin;
        private Gtk.SpinButton columns_spin;
        private Gtk.SpinButton padding_spin;
        private Gtk.SpinButton capture_height_spin;

        private Gtk.Entry signature_prefix_entry;

        private Gtk.ColorButton bg_heading_btn;
        private Gtk.ColorButton fg_heading_btn;
        private Gtk.ColorButton bg_sign_btn;
        private Gtk.ColorButton fg_sign_btn;
        private Gtk.ColorButton bg_title_btn;
        private Gtk.ColorButton fg_title_btn;
        private Gtk.ColorButton bg_tstamps_btn;
        private Gtk.ColorButton fg_tstamps_btn;
        private Gtk.ColorButton bg_contact_btn;

        public SettingsDialog (KeyFile keyfile) {

            this._keyfile = keyfile;

            this.set_border_width (6);
            this.set_decorated (true);
            this.set_deletable (true);
            this.set_resizable (false);
            this.set_modal (true);
            this.set_destroy_with_parent (true);
            this.set_title (_("Settings"));

            this.response.connect (this.on_response);

            int grid_row = 0;

            var main_grid = new Gtk.Grid ();
            main_grid.set_halign (Gtk.Align.START);
            main_grid.set_valign (Gtk.Align.START);
            main_grid.set_margin_top (10);
            main_grid.set_margin_bottom (10);
            main_grid.set_margin_start (10);
            main_grid.set_margin_end (10);
            main_grid.set_row_spacing (12);
            main_grid.set_column_spacing (12);
            main_grid.set_column_homogeneous (false);
            main_grid.set_row_homogeneous (false);
            main_grid.set_vexpand (true);

            Gtk.Label lbl_title = new Gtk.Label ("");
            lbl_title.set_markup ("<big>" + _("General") + "</big>");
            lbl_title.set_margin_top (5);
            lbl_title.set_margin_bottom (10);
            lbl_title.set_margin_start (5);
            lbl_title.set_margin_end (5);
            lbl_title.set_halign (Gtk.Align.CENTER);
            main_grid.attach (lbl_title, 0, grid_row, 5, 1);
            grid_row++;

            try {

                Gtk.Label interval_lbl = new Gtk.Label (_("Capture interval"));
                interval_lbl.set_halign (Gtk.Align.START);
                interval_spin = new Gtk.SpinButton (new Gtk.Adjustment (50.0, 0.0, 6000.0, 1.0, 60.0, 0.0), 1.0, 0);
                interval_spin.set_value (_keyfile.get_integer ("vcs", "interval"));
                interval_spin.set_tooltip_text (_("Capture time interval in seconds"));

                Gtk.Label numcaps_lbl = new Gtk.Label (_("Number of captures"));
                numcaps_lbl.set_halign (Gtk.Align.START);
                numcaps_spin = new Gtk.SpinButton (new Gtk.Adjustment (50.0, 0.0, 100.0, 1.0, 5.0, 0.0), 1.0, 0);
                numcaps_spin.set_value (_keyfile.get_integer ("vcs", "numcaps"));
                numcaps_spin.set_tooltip_text (_("Number of captures to compose in the sheet"));

                Gtk.Label capture_mode_lbl = new Gtk.Label (_("Capture mode"));
                capture_mode_lbl.set_halign (Gtk.Align.START);
                Gtk.Box capture_mode_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
                capture_mode_box.set_tooltip_text (
                    _("Screenshots capture mode:\nruled by time interval or by total number of captures")
                );
                GLib.SList<Gtk.RadioButton> capture_mode_slist = new GLib.SList<Gtk.RadioButton> ();
                capture_mode_interval = new Gtk.RadioButton.with_label (capture_mode_slist, "Interval");
                capture_mode_numcaps = new Gtk.RadioButton.with_label_from_widget (capture_mode_interval, "Captures");
                if (_keyfile.get_string ("vcs-cmd", "capture_mode") == "i") {
                    capture_mode_interval.set_active (true);
                    interval_lbl.set_sensitive (true);
                    interval_spin.set_sensitive (true);
                    numcaps_lbl.set_sensitive (false);
                    numcaps_spin.set_sensitive (false);
                } else {
                    capture_mode_numcaps.set_active (true);
                    interval_lbl.set_sensitive (false);
                    interval_spin.set_sensitive (false);
                    numcaps_lbl.set_sensitive (true);
                    numcaps_spin.set_sensitive (true);
                }
                capture_mode_box.pack_start (capture_mode_interval, true, true, 8);
                capture_mode_box.pack_start (capture_mode_numcaps, true, true, 8);


                Gtk.Label format_lbl = new Gtk.Label (_("Image format"));
                format_lbl.set_halign (Gtk.Align.START);
                Gtk.Box format_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
                format_box.set_tooltip_text (_("Image format for the sheet"));
                GLib.SList<Gtk.RadioButton> format_slist = new GLib.SList<Gtk.RadioButton> ();
                format_png = new Gtk.RadioButton.with_label (format_slist, "PNG");
                format_jpg = new Gtk.RadioButton.with_label_from_widget (format_png, "JPG");
                if (_keyfile.get_string ("vcs", "format") == "png") {
                    format_png.set_active (true);
                } else {
                    format_jpg.set_active (true);
                }
                format_box.pack_start (format_png, true, true, 0);
                format_box.pack_start (format_jpg, true, true, 0);

                main_grid.attach (capture_mode_lbl, 0, grid_row, 1, 1);
                main_grid.attach (capture_mode_box, 1, grid_row, 1, 1);
                main_grid.attach (new Gtk.Label ("    "), 2, grid_row, 1, 1);
                main_grid.attach (format_lbl, 3, grid_row, 1, 1);
                main_grid.attach (format_box, 4, grid_row, 1, 1);
                grid_row++;


                Gtk.Label quality_lbl = new Gtk.Label (_("Image quality"));
                quality_lbl.set_halign (Gtk.Align.START);
                quality_spin = new Gtk.SpinButton (new Gtk.Adjustment (50.0, 0.0, 100.0, 1.0, 5.0, 0.0), 1.0, 0);
                quality_spin.set_value (_keyfile.get_integer ("vcs", "quality"));
                quality_spin.set_tooltip_text (_("Quality level for the sheet: 0 to 100"));

                main_grid.attach (interval_lbl, 0, grid_row, 1, 1);
                main_grid.attach (interval_spin, 1, grid_row, 1, 1);
                main_grid.attach (quality_lbl, 3, grid_row, 1, 1);
                main_grid.attach (quality_spin, 4, grid_row, 1, 1);
                grid_row++;

                Gtk.Label signature_prefix_lbl = new Gtk.Label (_("Signature prefix"));
                signature_prefix_lbl.set_halign (Gtk.Align.START);
                signature_prefix_entry = new Gtk.Entry ();
                signature_prefix_entry.set_text (_keyfile.get_string ("vcs", "signature"));
                signature_prefix_entry.set_tooltip_text (_("Prefix for the user signature in the footer"));

                Gtk.Label signature_lbl = new Gtk.Label (_("Signature"));
                signature_lbl.set_halign (Gtk.Align.START);
                signature_switch = new Gtk.Switch ();
                signature_switch.set_halign (Gtk.Align.START);
                if (_keyfile.get_integer ("vcs-cmd", "signature_mode") == 0) {
                    signature_switch.set_active (false);
                    signature_prefix_lbl.set_sensitive (false);
                    signature_prefix_entry.set_sensitive (false);
                } else {
                    signature_switch.set_active (true);
                    signature_prefix_lbl.set_sensitive (true);
                    signature_prefix_entry.set_sensitive (true);
                }
                signature_switch.set_tooltip_text (_("Enable the user signature in the sheet footer"));

                main_grid.attach (numcaps_lbl, 0, grid_row, 1, 1);
                main_grid.attach (numcaps_spin, 1, grid_row, 1, 1);
                main_grid.attach (signature_lbl, 3, grid_row, 1, 1);
                main_grid.attach (signature_switch, 4, grid_row, 1, 1);
                grid_row++;

                Gtk.Label columns_lbl = new Gtk.Label (_("Number of columns"));
                columns_lbl.set_halign (Gtk.Align.START);
                columns_spin = new Gtk.SpinButton (new Gtk.Adjustment (50.0, 0.0, 10.0, 1.0, 5.0, 0.0), 1.0, 0);
                columns_spin.set_value (_keyfile.get_integer ("vcs", "columns"));
                columns_spin.set_tooltip_text (_("Number of columns in the sheet"));

                main_grid.attach (columns_lbl, 0, grid_row, 1, 1);
                main_grid.attach (columns_spin, 1, grid_row, 1, 1);
                main_grid.attach (signature_prefix_lbl, 3, grid_row, 1, 1);
                main_grid.attach (signature_prefix_entry, 4, grid_row, 1, 1);
                grid_row++;

                Gtk.Label padding_lbl = new Gtk.Label (_("Padding"));
                padding_lbl.set_halign (Gtk.Align.START);
                padding_spin = new Gtk.SpinButton (new Gtk.Adjustment (50.0, 0.0, 50.0, 1.0, 5.0, 0.0), 1.0, 0);
                padding_spin.set_value (_keyfile.get_integer ("vcs", "padding"));
                padding_spin.set_tooltip_text (_("Padding space between images"));

                //Disables drop shadows when 1
                Gtk.Label shadows_lbl = new Gtk.Label (_("Show shadows"));
                shadows_lbl.set_halign (Gtk.Align.START);
                shadows_switch = new Gtk.Switch ();
                shadows_switch.set_halign (Gtk.Align.START);
                if (_keyfile.get_integer ("vcs", "disable_shadows") == 0) {
                    shadows_switch.set_active (true);
                } else {
                    shadows_switch.set_active (false);
                }
                shadows_switch.set_tooltip_text (_("Enable drop shadows"));

                main_grid.attach (padding_lbl, 0, grid_row, 1, 1);
                main_grid.attach (padding_spin, 1, grid_row, 1, 1);
                main_grid.attach (shadows_lbl, 3, grid_row, 1, 1);
                main_grid.attach (shadows_switch, 4, grid_row, 1, 1);
                grid_row++;

                // Height of the single capture frame
                Gtk.Label capture_height_lbl = new Gtk.Label (_("Capture height"));
                capture_height_lbl.set_halign (Gtk.Align.START);
                capture_height_spin = new Gtk.SpinButton (
                    new Gtk.Adjustment (200.0, 100.0, 5000.0, 1.0, 10.0, 0.0),
                    1.0,
                    0
                );
                capture_height_spin.set_value (_keyfile.get_integer ("vcs-cmd", "capture_height"));
                capture_height_spin.set_tooltip_text (_("Height of the single capture frame"));

                //Disables timestamps on captures when 1
                Gtk.Label timestamps_lbl = new Gtk.Label (_("Show timestamps"));
                timestamps_lbl.set_halign (Gtk.Align.START);
                timestamps_switch = new Gtk.Switch ();
                timestamps_switch.set_halign (Gtk.Align.START);
                if (_keyfile.get_integer ("vcs", "disable_timestamps") == 0) {
                    timestamps_switch.set_active (true);
                } else {
                    timestamps_switch.set_active (false);
                }
                timestamps_switch.set_tooltip_text (_("Diplay timestamps on captures"));
                main_grid.attach (capture_height_lbl, 0, grid_row, 1, 1);
                main_grid.attach (capture_height_spin, 1, grid_row, 1, 1);
                main_grid.attach (timestamps_lbl, 3, grid_row, 1, 1);
                main_grid.attach (timestamps_switch, 4, grid_row, 1, 1);
                grid_row++;

                Gtk.Label lbl_colors = new Gtk.Label ("");
                lbl_colors.set_markup ("<big>" + _("Colors") + "</big>");
                lbl_colors.set_margin_top (5);
                lbl_colors.set_margin_bottom (10);
                lbl_colors.set_margin_start (5);
                lbl_colors.set_margin_end (5);
                lbl_colors.set_halign (Gtk.Align.CENTER);
                main_grid.attach (lbl_colors, 0, grid_row, 5, 1);
                grid_row++;

                Gtk.Label bg_heading_lbl = new Gtk.Label (_("Header background"));
                bg_heading_lbl.set_halign (Gtk.Align.START);
                bg_heading_btn = new Gtk.ColorButton ();
                bg_heading_btn.set_tooltip_text (_("Background color for the header section"));
                Gdk.RGBA bg_heading = Gdk.RGBA ();
                bg_heading.parse (_keyfile.get_string ("vcs", "bg_heading"));
                bg_heading_btn.set_rgba (bg_heading);

                Gtk.Label fg_heading_lbl = new Gtk.Label (_("Header font color"));
                fg_heading_lbl.set_halign (Gtk.Align.START);
                fg_heading_btn = new Gtk.ColorButton ();
                fg_heading_btn.set_tooltip_text (_("Font color for the header section"));
                Gdk.RGBA fg_heading = Gdk.RGBA ();
                fg_heading.parse (_keyfile.get_string ("vcs", "fg_heading"));
                fg_heading_btn.set_rgba (fg_heading);

                main_grid.attach (bg_heading_lbl, 0, grid_row, 1, 1);
                main_grid.attach (bg_heading_btn, 1, grid_row, 1, 1);
                main_grid.attach (fg_heading_lbl, 3, grid_row, 1, 1);
                main_grid.attach (fg_heading_btn, 4, grid_row, 1, 1);
                grid_row++;

                Gtk.Label bg_sign_lbl = new Gtk.Label (_("Signature background"));
                bg_sign_lbl.set_halign (Gtk.Align.START);
                bg_sign_btn = new Gtk.ColorButton ();
                bg_sign_btn.set_tooltip_text (_("Background color for the signature section"));
                Gdk.RGBA bg_sign = Gdk.RGBA ();
                bg_sign.parse (_keyfile.get_string ("vcs", "bg_sign"));
                bg_sign_btn.set_rgba (bg_sign);

                Gtk.Label fg_sign_lbl = new Gtk.Label (_("Signature font color"));
                fg_sign_lbl.set_halign (Gtk.Align.START);
                fg_sign_btn = new Gtk.ColorButton ();
                fg_sign_btn.set_tooltip_text (_("Font color for the signature section"));
                Gdk.RGBA fg_sign = Gdk.RGBA ();
                fg_sign.parse (_keyfile.get_string ("vcs", "fg_sign"));
                fg_sign_btn.set_rgba (fg_sign);

                main_grid.attach (bg_sign_lbl, 0, grid_row, 1, 1);
                main_grid.attach (bg_sign_btn, 1, grid_row, 1, 1);
                main_grid.attach (fg_sign_lbl, 3, grid_row, 1, 1);
                main_grid.attach (fg_sign_btn, 4, grid_row, 1, 1);
                grid_row++;

                Gtk.Label bg_title_lbl = new Gtk.Label (_("Title background"));
                bg_title_lbl.set_halign (Gtk.Align.START);
                bg_title_btn = new Gtk.ColorButton ();
                bg_title_btn.set_tooltip_text (_("Background color for the title section"));
                Gdk.RGBA bg_title = Gdk.RGBA ();
                bg_title.parse (_keyfile.get_string ("vcs", "bg_title"));
                bg_title_btn.set_rgba (bg_title);

                Gtk.Label fg_title_lbl = new Gtk.Label (_("Title font color"));
                fg_title_lbl.set_halign (Gtk.Align.START);
                fg_title_btn = new Gtk.ColorButton ();
                fg_title_btn.set_tooltip_text (_("Font color for the title section"));
                Gdk.RGBA fg_title = Gdk.RGBA ();
                fg_title.parse (_keyfile.get_string ("vcs", "fg_title"));
                fg_title_btn.set_rgba (fg_title);

                main_grid.attach (bg_title_lbl, 0, grid_row, 1, 1);
                main_grid.attach (bg_title_btn, 1, grid_row, 1, 1);
                main_grid.attach (fg_title_lbl, 3, grid_row, 1, 1);
                main_grid.attach (fg_title_btn, 4, grid_row, 1, 1);
                grid_row++;

                Gtk.Label bg_tstamps_lbl = new Gtk.Label (_("Timestamps background"));
                bg_tstamps_lbl.set_halign (Gtk.Align.START);
                bg_tstamps_btn = new Gtk.ColorButton ();
                bg_tstamps_btn.set_tooltip_text (_("Background color for the timestamps box"));
                Gdk.RGBA bg_tstamps = Gdk.RGBA ();
                bg_tstamps.parse (_keyfile.get_string ("vcs", "bg_tstamps"));
                bg_tstamps_btn.set_rgba (bg_tstamps);

                Gtk.Label fg_tstamps_lbl = new Gtk.Label (_("Timestamps font color"));
                fg_tstamps_lbl.set_halign (Gtk.Align.START);
                fg_tstamps_btn = new Gtk.ColorButton ();
                fg_tstamps_btn.set_tooltip_text (_("Font color for the timestamps box"));
                Gdk.RGBA fg_tstamps = Gdk.RGBA ();
                fg_tstamps.parse (_keyfile.get_string ("vcs", "fg_tstamps"));
                fg_tstamps_btn.set_rgba (fg_tstamps);

                main_grid.attach (bg_tstamps_lbl, 0, grid_row, 1, 1);
                main_grid.attach (bg_tstamps_btn, 1, grid_row, 1, 1);
                main_grid.attach (fg_tstamps_lbl, 3, grid_row, 1, 1);
                main_grid.attach (fg_tstamps_btn, 4, grid_row, 1, 1);
                grid_row++;

                Gtk.Label bg_contact_lbl = new Gtk.Label (_("Captures background"));
                bg_contact_lbl.set_halign (Gtk.Align.START);
                bg_contact_btn = new Gtk.ColorButton ();
                bg_contact_btn.set_tooltip_text (_("Background color for the captures section"));
                Gdk.RGBA bg_contact = Gdk.RGBA ();
                bg_contact.parse (_keyfile.get_string ("vcs", "bg_contact"));
                bg_contact_btn.set_rgba (bg_contact);
                main_grid.attach (bg_contact_lbl, 0, grid_row, 1, 1);
                main_grid.attach (bg_contact_btn, 1, grid_row, 1, 1);
                grid_row++;


                // signal handlers
                capture_mode_interval.toggled.connect (() => {
                    interval_lbl.set_sensitive (true);
                    interval_spin.set_sensitive (true);
                    numcaps_lbl.set_sensitive (false);
                    numcaps_spin.set_sensitive (false);
                });
                capture_mode_numcaps.toggled.connect (() => {
                    interval_lbl.set_sensitive (false);
                    interval_spin.set_sensitive (false);
                    numcaps_lbl.set_sensitive (true);
                    numcaps_spin.set_sensitive (true);
                });
                signature_switch.state_set.connect ((state) => {
                    if (state) {
                        signature_prefix_lbl.set_sensitive (true);
                        signature_prefix_entry.set_sensitive (true);
                    } else {
                        signature_prefix_lbl.set_sensitive (false);
                        signature_prefix_entry.set_sensitive (false);
                    }
                    signature_switch.set_state (state);
                    signature_switch.set_active (state);
                    return state;
                });
            } catch (KeyFileError e) {
                error (e.message);
            }


            main_grid.show_all ();
            get_content_area ().add (main_grid);

            // Add buttons to button area at the bottom
            add_button (_("Save"), Gtk.ResponseType.OK);
            add_button (_("Apply"), Gtk.ResponseType.APPLY);
            add_button (_("Close"), Gtk.ResponseType.CLOSE);
            /*
            bg_heading_btn.color_set.connect (() => {
                Gdk.RGBA c = bg_heading_btn.get_rgba ();
                message (c.to_string ());
                message (this.rgb_to_hex (c));
            });
            */
        }

        private void on_response (Gtk.Dialog source, int response_id) {
            switch (response_id) {
                case Gtk.ResponseType.OK:
                    on_apply_clicked (false);
                    destroy ();
                    break;
                case Gtk.ResponseType.APPLY:
                    on_apply_clicked (true);
                    break;
                case Gtk.ResponseType.CLOSE:
                    destroy ();
                    break;
            }
        }

        private string rgb_to_hex (Gdk.RGBA rgba) {
            string s =
                "#%02x%02x%02x"
                .printf ((uint) (Math.round (rgba.red * 255)),
                        (uint) (Math.round (rgba.green * 255)),
                        (uint) (Math.round (rgba.blue * 255)))
                .up ();
                return s;
        }

        private void on_apply_clicked (bool show_dialog) {
            string capture_mode = "n", format = "png";
            int signature_mode = 0, disable_shadows = 0, disable_timestamps = 0;

            if (capture_mode_interval.get_active ()) capture_mode = "i";
            if (signature_switch.get_active ()) signature_mode = 1;
            if (!shadows_switch.get_active ()) disable_shadows = 1;
            if (!timestamps_switch.get_active ()) disable_timestamps = 1;
            if (format_jpg.get_active ()) format = "jpg";

            _keyfile.set_string ("vcs-cmd", "capture_mode", capture_mode); //Interval i or captures n 
            _keyfile.set_integer ("vcs-cmd", "signature_mode", signature_mode); //None 0 or 1
            _keyfile.set_integer ("vcs-cmd", "capture_height", capture_height_spin.get_value_as_int ()); //Height of the single capture frame

            _keyfile.set_integer ("vcs", "interval", interval_spin.get_value_as_int ()); //Default capture interval 
            _keyfile.set_integer ("vcs", "numcaps", numcaps_spin.get_value_as_int ()); //Default number of captures 
            _keyfile.set_integer ("vcs", "columns", columns_spin.get_value_as_int ()); //Default number of columns 
            _keyfile.set_integer ("vcs", "padding", padding_spin.get_value_as_int ()); //Padding between captures 
            _keyfile.set_integer ("vcs", "quality", quality_spin.get_value_as_int ()); //Image quality for output in lossy formats 
            _keyfile.set_integer ("vcs", "disable_shadows", disable_shadows); //Disables drop shadows when 1
            _keyfile.set_integer ("vcs", "disable_timestamps", disable_timestamps);//Disables timestamps on captures when 1

            _keyfile.set_string ("vcs", "signature", signature_prefix_entry.get_text ()); //Text before the user name in the signature 
            _keyfile.set_string ("vcs", "format", format); //Sets the output format 
            _keyfile.set_string ("vcs", "bg_heading", this.rgb_to_hex (bg_heading_btn.get_rgba ())); //Background for meta info (size, codec…) 
            _keyfile.set_string ("vcs", "bg_sign", this.rgb_to_hex (bg_sign_btn.get_rgba ())); //Background for signature 
            _keyfile.set_string ("vcs", "bg_title", this.rgb_to_hex (bg_title_btn.get_rgba ())); //Background for the title (see -T)
            _keyfile.set_string ("vcs", "bg_contact", this.rgb_to_hex (bg_contact_btn.get_rgba ())); //Background for the captures 
            _keyfile.set_string ("vcs", "bg_tstamps", this.rgb_to_hex ( bg_tstamps_btn.get_rgba ())); //Background for the timestamps box
            _keyfile.set_string ("vcs", "fg_heading", this.rgb_to_hex (fg_heading_btn.get_rgba ())); //Font colour for meta info box
            _keyfile.set_string ("vcs", "fg_sign", this.rgb_to_hex (fg_sign_btn.get_rgba ())); //Font colour for signature
            _keyfile.set_string ("vcs", "fg_tstamps", this.rgb_to_hex (fg_tstamps_btn.get_rgba ())); //Font colour for timestamps
            _keyfile.set_string ("vcs", "fg_title", this.rgb_to_hex (fg_title_btn.get_rgba ())); //Font colour for the title
            try {
                _keyfile.save_to_file (conf_file);
                if (show_dialog) {
                    Gtk.MessageDialog popup = new Gtk.MessageDialog (
                        this,
                        Gtk.DialogFlags.MODAL,
                        Gtk.MessageType.INFO,
                        Gtk.ButtonsType.CLOSE,
                        _("Preferences saved!")
                    );
                    popup.format_secondary_text (_("All the preferences are saved.\nNow you can close this window."));
                    popup.run ();
                    popup.destroy ();
                }
            } catch (FileError e) {
                Gtk.MessageDialog error_dialog = new Gtk.MessageDialog (
                    this,
                    Gtk.DialogFlags.MODAL,
                    Gtk.MessageType.ERROR,
                    Gtk.ButtonsType.CLOSE,
                    _("Error")
                );
                error_dialog.format_secondary_text (_("Error") + ":\n" + e.message);
                error_dialog.run ();
                error_dialog.destroy ();
                error (e.message);
            }

        }
    }
}
