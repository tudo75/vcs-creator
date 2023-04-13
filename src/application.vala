/* application.vala
 *
 * Copyright 2022-2023 Nicola tudo75 Tudino
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

    public static int main (string[] args) {
        var application = new Application ();
        return application.run (args);
    }

    public class Application : Gtk.Application {

        private const string APP_NAME = "VCS Creator";
        private const string VERSION = Constants.VERSION;
        private const string APP_ID = Constants.PROJECT_NAME;
        private const string APP_LANG_DOMAIN = Constants.GETTEXT_PACKAGE;
        private const string APP_INSTALL_PREFIX = Constants.PREFIX;
        private const int APP_WIDTH = 428;
        private const int APP_HEIGHT = 228;

        private Gtk.ApplicationWindow window;
        private Gtk.HeaderBar headerbar;
        private Gtk.PopoverMenu popover;
        private Gtk.Button btn_start;

        private const Gtk.TargetEntry[] TARGETS = {
            {"text/uri-list", 0, 0}
        };

        private const string[] EXTENSIONS = {
            ".webm", ".mpg", ".mp2", ".mpeg", ".mpe", ".mpv", ".ogg", ".ogv", ".mp4",
            ".m4p", ".m4v", ".avi", ".wmv", ".mov", ".qt", ".flv", ".swf", ".mkv",
            ".vob", ".ts", ".m2ts", ".mts", ".rm", ".rmvb", ".asf", ".3gp"
        };

        private string conf_file = GLib.Environment.get_home_dir () + "/.vcs.conf";
        private KeyFile keyfile;

        private FilesDialog files_dialog;

        private bool is_in_progress = false;

        public Application () {
            Object (
                application_id: APP_ID,
                flags: ApplicationFlags.FLAGS_NONE
            );

            // For Wayland: must be the same name of the exec in *.desktop file
            GLib.Environment.set_prgname (APP_ID);

            // congfigure i18n localization
            Intl.setlocale (LocaleCategory.ALL, "");
            string langpack_dir = Path.build_filename (APP_INSTALL_PREFIX, "share", "locale");
            Intl.bindtextdomain (APP_ID, langpack_dir);
            Intl.bind_textdomain_codeset (APP_ID, "UTF-8");
            Intl.textdomain (APP_ID);
            /*
            print (
                Constants.PROJECT_NAME + "\n" + 
                Constants.GETTEXT_PACKAGE + "\n" + 
                Constants.VERSION + "\n" + 
                Constants.PREFIX + "\n"
            );
            */
        }

        construct {
            ActionEntry[] action_entries = {
                { "show_files_dialog", this.show_files_dialog },
                { "hide_files_dialog", this.hide_files_dialog },
                { "about", this.on_about_action },
                { "settings", this.on_settings_action },
                { "quit", this.quit }
            };
            this.add_action_entries (action_entries, this);
            //this.set_accels_for_action ("app.quit", {"<primary>q"});
        }

        public override void activate () {
            base.activate ();
            window = new Gtk.ApplicationWindow (this);
            window.set_default_size (APP_WIDTH, APP_HEIGHT);
            window.set_resizable (false);
            window.window_position = Gtk.WindowPosition.CENTER;
            Gtk.Window.set_default_icon_name (APP_LANG_DOMAIN);
            this.init_style ();
            this.init_headerbar ();
            this.init_window ();
            window.show_all ();
            window.show ();
            window.present ();
            
            btn_start.hide ();

            this.load_keyfile ();
            files_dialog = new FilesDialog ();
            files_dialog.set_transient_for (this.active_window);
        }

        /**
         * init_style:
         *
         * Add custom style sheet to the Application
         */
        private void init_style () {
            Gtk.CssProvider css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/tudo75/vcs-creator/style.css");
            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );
        }

        /**
         * init_headerbar:
         *
         * #Gtk.HeaderBar constructor for the Application
         */
        private void init_headerbar () {
            headerbar = new Gtk.HeaderBar ();
            headerbar.set_title (APP_NAME);
            headerbar.set_hexpand (true);
            headerbar.set_show_close_button (true);

            popover = new Gtk.PopoverMenu ();
            this.init_popover ();

            Gtk.MenuButton menu_btn = new Gtk.MenuButton ();
            menu_btn.set_use_popover (true);
            //menu_btn.set_active (true);
            menu_btn.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.MENU));
            menu_btn.set_popover (popover);
            headerbar.pack_end (menu_btn);

            window.set_titlebar (headerbar);
        }

        /**
         * init_popover:
         *
         * Initialize PopoverMenu for the HeaderBar
         */
        private void init_popover () {
            GLib.Menu menu = new GLib.Menu ();

            GLib.MenuItem show_files_dialog_item = new GLib.MenuItem (_("Show files list"), "app.show_files_dialog");
            menu.append_item (show_files_dialog_item);

            GLib.MenuItem hide_files_dialog_item = new GLib.MenuItem (_("Hide files list"), "app.hide_files_dialog");
            menu.append_item (hide_files_dialog_item);

            GLib.MenuItem pref_item = new GLib.MenuItem (_("Settings"), "app.settings");
            menu.append_item (pref_item);

            GLib.MenuItem about_item = new GLib.MenuItem (_("About"), "app.about");
            menu.append_item (about_item);

            GLib.MenuItem close_item = new GLib.MenuItem (_("Close"), "app.quit");
            menu.append_item (close_item);

            popover.bind_model (menu, null);
        }

        /**
         * init_window:
         * 
         * Initialize main window content
         */
        private void init_window () {
            Gtk.Box vbox_main = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            window.add (vbox_main);

            Gtk.Image drop_image = new Gtk.Image.from_resource ("/com/github/tudo75/vcs-creator/drophere.png");

            //layout
            Gtk.Layout layout = new Gtk.Layout ( null, null);
            layout.set_size_request (APP_WIDTH, APP_HEIGHT);
            vbox_main.add (layout);
            layout.show ();
            layout.put (drop_image, 150, 50);

            //connect drag drop handlers
            Gtk.drag_dest_set (layout, Gtk.DestDefaults.ALL, TARGETS, Gdk.DragAction.COPY);
            layout.drag_data_received.connect (this.on_drag_data_received);

            btn_start = new Gtk.Button.with_label (_("Start"));
            btn_start.clicked.connect (this.on_btn_start_clicked);

            vbox_main.add (btn_start);
        }

        /**
         * on_drag_data_received:
         * 
         * Handle the files draggegged inside the drop window
         */
        private void on_drag_data_received (Gdk.DragContext drag_context, int x, int y,
                                            Gtk.SelectionData data, uint info, uint time) {
            this.show_files_dialog ();
            //loop through list of URIs
            foreach (string uri in data.get_uris ()) {
                string file = uri.replace ("file://", "").replace ("file:/", "");
                file = Uri.unescape_string (file);

                //add file to tree view
                if (this.is_video (file) && !files_dialog.find_file (file)) {
                    files_dialog.add_file (file);
                }
            }

            Gtk.drag_finish (drag_context, true, false, time);
            
            if (!is_in_progress)
                btn_start.show ();
        }

        /**
         * on_btn_start_clicked:
         * 
         * Start the creation of the contact sheets from the videos
         */
        private async void on_btn_start_clicked () {
            is_in_progress = true;
            btn_start.hide ();
            files_dialog.show_spinner ();
            this.show_files_dialog ();
            string[] argv= {"vcs", "", "-A", "-Wc"};
            try {
                //read the settings from the keyfile
                argv += "-H";
                argv += keyfile.get_integer ("vcs-cmd", "capture_height").to_string ();
                argv += "-c";
                argv += keyfile.get_integer ("vcs", "columns").to_string ();

                if (keyfile.get_string ("vcs-cmd", "capture_mode") == "i") {
                    argv += "-i";
                    argv += keyfile.get_integer ("vcs", "interval").to_string ();
                } else {
                    argv += "-n";
                    argv += keyfile.get_integer ("vcs", "numcaps").to_string ();
                }
                if (keyfile.get_integer ("vcs-cmd", "signature_mode") == 0) {
                    argv += "-U0";
                }
                SubprocessLauncher launcher = new SubprocessLauncher (GLib.SubprocessFlags.INHERIT_FDS);
                launcher.set_environ (Environ.get ());
                Gtk.ListStore list_store = files_dialog.get_list ();
                Gtk.TreeIter iter;
                //ierate through the liststore model
                for (bool next = list_store.get_iter_first (out iter); next; next = list_store.iter_next (ref iter)) {
                    try {
                        string[] argv1 = argv.copy ();
                        // verify if the contact sheet was previously created
                        GLib.Value check;
                        list_store.get_value (iter, 0, out check);
                        if (!check.get_boolean ()) {
                            check.unset ();

                            GLib.Value value;
                            list_store.get_value (iter, 1, out value);
                            string src_file = value.get_string ();
                            value.unset ();
                            list_store.set_value (iter, 2, true);

                            argv1[1] = src_file;
                            argv1 += "-o";
                            argv1 += src_file + "." + keyfile.get_string ("vcs", "format");

                            //launch the contact sheet creation asynchrously
                            yield this.exec_proc (src_file, argv1, launcher);
                        } else {
                            check.unset ();
                        }
                    } catch (GLib.Error e) {
                        var error_dialog = new Gtk.MessageDialog (
                            this.window,
                            Gtk.DialogFlags.MODAL,
                            Gtk.MessageType.ERROR,
                            Gtk.ButtonsType.OK,
                            _("Error")
                        );
                        error_dialog.format_secondary_text (_("Error") + ":\n" + e.message);
                        error_dialog.run ();
                        error_dialog.destroy ();
                        error (e.message);
                    }
                }
            } catch (KeyFileError e) {
                Gtk.MessageDialog error_dialog = new Gtk.MessageDialog (
                    this.window,
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

            is_in_progress = false;
            btn_start.show ();
            files_dialog.hide_spinner ();
        }

        /**
         * exec_proc:
         * 
         * Launch the vcs async sub process
         */
        private async void exec_proc (string src_file, string[] argv, SubprocessLauncher launcher) {
            SourceFunc callback = exec_proc.callback;
            try {
                // set env param to remove vcs error for process not launched 
                // in a terminal that supoort coloured output
                launcher.setenv ("TERM", "vt100", true);
                Subprocess subp = launcher.spawnv (argv);
                subp.wait_async.begin (null, (obj, res) => {
                    try {
                        subp.wait_check_async.end (res);
                        if (subp.get_if_exited ()) {
                            files_dialog.file_done (src_file);
                        }
                    } catch (Error e) {
                        var error_dialog = new Gtk.MessageDialog (
                            this.window,
                            Gtk.DialogFlags.MODAL,
                            Gtk.MessageType.ERROR,
                            Gtk.ButtonsType.OK,
                            _("Error")
                        );
                        error_dialog.format_secondary_text (_("Error") + ":\n" + e.message);
                        error_dialog.run ();
                        error_dialog.destroy ();

                        // cancelled
                        subp.send_signal (Posix.Signal.INT);
                        subp.send_signal (Posix.Signal.KILL);
                        
                        error (e.message);
                    }
                    Idle.add ((owned) callback);
                });
                yield;
            } catch (GLib.Error e) {
                var error_dialog = new Gtk.MessageDialog (
                    this.window,
                    Gtk.DialogFlags.MODAL,
                    Gtk.MessageType.ERROR,
                    Gtk.ButtonsType.OK,
                    _("Error")
                );
                error_dialog.format_secondary_text (_("Error") + ":\n" + e.message);
                error_dialog.run ();
                error_dialog.destroy ();
                error (e.message);
            }
        }

        /**
         * show_files_dialog:
         * 
         * Display the dialog windows containing the treeview of the video files
         */
        private void show_files_dialog () {
            int x;
            int y;
            this.active_window.get_position (out x, out y);
            files_dialog.move (x - FilesDialog.WIDTH - 50, y - ((FilesDialog.HEIGHT - APP_HEIGHT) / 2));
            files_dialog.show ();
            files_dialog.present ();
        }

        /**
         * show_files_dialog:
         * 
         * Hide the dialog windows containing the treeview of the video files
         */
        private void hide_files_dialog () {
            files_dialog.hide ();
        }

        /**
         * is_video:
         *
         * Check if the file is a video (by extensions) returning true, false otherwise.
         */
        private bool is_video (string file) {
            foreach (var extension in EXTENSIONS) {
                if (file.down ().has_suffix (extension)) {
                    return true;
                }
            }
            return false;
        }

        /**
         * about_dialog:
         *
         * Create and display a #Gtk.AboutDialog window.
         */
        private void on_about_action () {
            // Configure the dialog:
            Gtk.AboutDialog dialog = new Gtk.AboutDialog ();
            dialog.set_destroy_with_parent (true);
            dialog.set_transient_for (this.active_window);
            dialog.set_modal (true);

            dialog.set_logo_icon_name (APP_LANG_DOMAIN);
            dialog.set_logo (new Gtk.Image.from_resource ("/com/github/tudo75/vcs-creator/vcs-creator.svg").pixbuf);

            dialog.authors = {"Nicola \"tudo75\" Tudino"};
            dialog.artists = {"Nicola \"tudo75\" Tudino"};
            dialog.documenters = {"Nicola \"tudo75\" Tudino"};
            dialog.translator_credits = ("Nicola \"tudo75\" Tudino");

            dialog.program_name = APP_NAME;
            dialog.comments = _("VCS Creator");
            dialog.copyright = _("Copyright 2022-2023 Nicola \"tudo75\" Tudino");
            dialog.version = VERSION;

            dialog.set_license_type (Gtk.License.GPL_3_0_ONLY);

            dialog.website = "http://github.com/tudo75/vcs-creator";
            dialog.website_label = "Repository Github";

            dialog.response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.CANCEL || response_id == Gtk.ResponseType.DELETE_EVENT) {
                    dialog.hide_on_delete ();
                }
            });

            // Show the dialog:
            dialog.present ();
        }

        /**
         * on_settings_action:
         *
         * Create and display a #Gtk.Dialog window.
         */
        private void on_settings_action () {
            SettingsDialog settings_dialog = new SettingsDialog (keyfile);
            settings_dialog.set_transient_for (this.active_window);

            // Show the dialog:
            settings_dialog.present ();
        }

        /**
         * load_keyfile:
         *
         * Load a #GLib.KeyFile to handle vcs settings.
         */
        public void load_keyfile () {
            keyfile = new KeyFile ();
            try {
                if (!FileUtils.test (conf_file, FileTest.EXISTS)) {
                        keyfile.set_string ("vcs-cmd", "capture_mode", "n"); //Interval i or captures n 
                        keyfile.set_string ("vcs-cmd", "signature_mode", "0"); //None 0 or 1
                        keyfile.set_string ("vcs-cmd", "capture_height", "200"); //Height of the single capture

                        keyfile.set_integer ("vcs", "interval", 300); //Default capture interval 
                        keyfile.set_integer ("vcs", "numcaps", 16); //Default number of captures 
                        keyfile.set_integer ("vcs", "columns", 2); //Default number of columns 
                        keyfile.set_integer ("vcs", "padding", 2); //Padding between captures 
                        keyfile.set_integer ("vcs", "quality", 92); //Image quality for output in lossy formats 
                        keyfile.set_integer ("vcs", "disable_shadows", 0); //Disables drop shadows when 1
                        keyfile.set_integer ("vcs", "disable_timestamps", 0);//Disables timestamps on captures when 1
                        keyfile.set_integer ("vcs", "pts_tstamps", 14); //Used for the timestamps
                        keyfile.set_integer ("vcs", "pts_meta", 14); //Used for the meta info heading 
                        keyfile.set_integer ("vcs", "pts_sign", 10); //Used for the signature 
                        keyfile.set_integer ("vcs", "pts_title", 33); //Used for the title (see -T)

                        keyfile.set_string ("vcs", "signature", "Preview created by"); //Text before the user name in the signature 
                        keyfile.set_string ("vcs", "format", "png"); //Sets the output format 
                        keyfile.set_string ("vcs", "bg_heading", "#afcd7a"); //Background for meta info (size, codec…) 
                        keyfile.set_string ("vcs", "bg_sign", "SlateGray"); //Background for signature 
                        keyfile.set_string ("vcs", "bg_title", "White"); //Background for the title (see -T)
                        keyfile.set_string ("vcs", "bg_contact", "White"); //Background for the captures 
                        keyfile.set_string ("vcs", "bg_tstamps", "#000000aa"); //Background for the timestamps box
                        keyfile.set_string ("vcs", "fg_heading", "Black"); //Font colour for meta info box
                        keyfile.set_string ("vcs", "fg_sign", "Black"); //Font colour for signature
                        keyfile.set_string ("vcs", "fg_tstamps", "White"); //Font colour for timestamps
                        keyfile.set_string ("vcs", "fg_title", "Black"); //Font colour for the title
                        keyfile.set_string ("vcs", "font_tstamps", "DejaVu-Sans"); //Used for timestamps over the thumbnails
                        keyfile.set_string ("vcs", "font_heading", "DejaVu-Sans"); //Used for the meta info heading 
                        keyfile.set_string ("vcs", "font_sign", "DejaVu-Sans"); //Used for the signature box 
                        keyfile.set_string ("vcs", "font_title", "DejaVu-Sans"); //Used for the title (see -T)

                        keyfile.save_to_file (conf_file);
                } else {
                    keyfile.load_from_file (conf_file, GLib.KeyFileFlags.KEEP_COMMENTS);
                }
            } catch (FileError e) {
                error (e.message);
            } catch (KeyFileError e) {
                error (e.message);
            }
        }
    }
}
