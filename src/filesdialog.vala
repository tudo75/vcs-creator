/* filesdialog.vala
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

    public class FilesDialog : Gtk.Dialog {

        private Gtk.ScrolledWindow sw_files;
        private Gtk.TreeView tv_files;
        private Gtk.TreeViewColumn col_toggle;
        private Gtk.TreeViewColumn col_name;
        private Gtk.ListStore list_store;
        private Gtk.Spinner spinner;
        private Gtk.Label spinner_lbl;
        private Gtk.Box spinner_area = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);

        public const int WIDTH = 500;
        public const int HEIGHT = 450;

        public FilesDialog () {

            this.set_border_width (0);
            this.set_decorated (true);
            this.set_deletable (false);
            this.set_resizable (true);
            this.set_modal (false);
            this.set_destroy_with_parent (true);
            this.set_title (_("Files"));
            this.set_default_size (WIDTH, HEIGHT);
            get_content_area ().set_spacing (10);

            //tv_files
            list_store = new Gtk.ListStore (2, typeof (bool), typeof (string));
            tv_files = new Gtk.TreeView.with_model (list_store);

            //sw_files
            sw_files = new Gtk.ScrolledWindow (tv_files.get_hadjustment (), tv_files.get_vadjustment ());
            sw_files.set_shadow_type (Gtk.ShadowType.ETCHED_IN);
            sw_files.add (tv_files);
            sw_files.set_size_request (WIDTH, HEIGHT);
            sw_files.show_all ();
            get_content_area ().add (sw_files);

            //toggle column
            col_toggle = new Gtk.TreeViewColumn ();
            col_toggle.title = "";
            col_toggle.expand = false;
            Gtk.CellRendererToggle cell_toggle = new Gtk.CellRendererToggle ();
            col_toggle.pack_start (cell_toggle, false);
            col_toggle.set_attributes (cell_toggle, "active", 0);
            tv_files.append_column (col_toggle);

            //name column
            col_name = new Gtk.TreeViewColumn ();
            col_name.title = _("Files");
            col_name.expand = true;
            Gtk.CellRendererText cell_name = new Gtk.CellRendererText ();
            col_name.pack_start (cell_name, false);
            col_name.set_attributes (cell_name, "text", 1);
            tv_files.append_column (col_name);

            tv_files.set_search_column (1);

            //spinner area
            this.spinner = new Gtk.Spinner ();
            this.spinner.set_size_request (32, 32);
            this.spinner_area.pack_start (spinner, false, false, 10);
            spinner_lbl =new Gtk.Label (_("Generating sheets"));
            this.spinner_area.pack_start (spinner_lbl, false, false, 10);
            get_content_area ().add (this.spinner_area);
            this.hide_spinner ();
        }

        public void add_file (string file) {
            Gtk.TreeIter iter;
            list_store.append (out iter);
            list_store.set (iter, 0, false, 1, file);
        }

        public bool find_file (string file) {
            Gtk.TreeIter iter;
            if (list_store.get_iter_first (out iter)) {
                GLib.Value value;
                list_store.get_value (iter, 1, out value);
                if (file == value.get_string ()) {
                    return true;
                } else {
                    while (list_store.iter_next (ref iter)) {
                        list_store.get_value (iter, 1, out value);
                        if (file == value.get_string ()) {
                            return true;
                        }
                    }
                }
                value.unset ();
            }
            return false;
        }

        public bool file_done (string file) {
            Gtk.TreeIter iter;
            if (list_store.get_iter_first (out iter)) {
                GLib.Value value;
                list_store.get_value (iter, 1, out value);
                if (file == value.get_string ()) {
                    list_store.set (iter, 0, true, 1, file);
                    return true;
                } else {
                    while (list_store.iter_next (ref iter)) {
                        list_store.get_value (iter, 1, out value);
                        if (file == value.get_string ()) {
                            list_store.set (iter, 0, true, 1, file);
                            return true;
                        }
                    }
                }
                value.unset ();
            }
            return false;
        }

        public void show_spinner () {
            this.spinner_area.show_all ();
            this.spinner.start ();
            this.spinner_lbl.show ();
        }

        public void hide_spinner () {
            this.spinner.stop ();
            this.spinner_lbl.hide ();
            this.spinner_area.hide ();
        }

        public int get_list_size () {
            int count = 0;
            list_store.@foreach (() => {
                count++;
                return false;
            });
            return count;
        }
    }
}
