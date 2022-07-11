/* application.vala
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

    public static int main (string[] args) {
        var application = new Application ();
        return application.run (args);
    }
    
    public class Application : Gtk.Application {

        private const string APP_NAME = "VCS Creator";
        private const string VERSION = "0.1.0";
        private const string APP_ID = "com.github.tudo75.vcs-creator";
        private const string APP_LANG_DOMAIN = "vcs-creator";
        private const string APP_INSTALL_PREFIX = "/usr/local";
        private int APP_WIDTH = 428;
        private int APP_HEIGHT = 228;

        private Gtk.ApplicationWindow window;
        private Gtk.HeaderBar headerbar;
        private Gtk.PopoverMenu popover;
        private const Gtk.TargetEntry[] targets = {
            {"text/uri-list", 0, 0}
        };
        private const string[] extensions = {
            ".webm",".mpg", ".mp2", ".mpeg", ".mpe", ".mpv", ".ogg", ".mp4", ".m4p", ".m4v", ".avi", ".wmv", ".mov", ".qt", ".flv", ".swf"
        };
        private Queue<string> files_queue;
        private Gtk.Button btn_start;

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
        }

        construct {
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "preferences", this.on_preferences_action },
                { "quit", this.quit }
            };
            this.add_action_entries (action_entries, this);
            this.set_accels_for_action ("app.quit", {"<primary>q"});
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
            files_queue = new Queue<string> ();
            btn_start.hide ();
        }

        /**
         * init_style:
         *
         * Add custom style sheet to the Application
         */
        private void init_style () {
            Gtk.CssProvider css_provider = new Gtk.CssProvider ();
            css_provider.load_from_resource ("/com/github/tudo75/vcs-creator/style.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
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
            menu_btn.set_image (new Gtk.Image.from_icon_name ("open-menu-symbolic", Gtk.IconSize.LARGE_TOOLBAR));
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

            GLib.MenuItem pref_item = new GLib.MenuItem (_("Preferences"), "app.preferences");
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
            Gtk.Box vboxMain = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            window.add (vboxMain);

            Gtk.Image drop_image = new Gtk.Image.from_resource ("/com/github/tudo75/vcs-creator/drophere.png");

            //layout
            Gtk.Layout layout = new Gtk.Layout(null, null);
            layout.set_size_request (APP_WIDTH, APP_HEIGHT);
            vboxMain.add(layout);
            layout.show();
            layout.put(drop_image, 150, 50);

            //connect drag drop handlers
            Gtk.drag_dest_set (layout, Gtk.DestDefaults.ALL, targets, Gdk.DragAction.COPY);
            layout.drag_data_received.connect(this.on_drag_data_received);

            btn_start = new Gtk.Button.with_label (_("Start"));
            btn_start.clicked.connect (this.on_btn_start_clicked);

            vboxMain.add (btn_start);
        }

    
        private void on_drag_data_received (Gdk.DragContext drag_context, int x, int y, 
                                            Gtk.SelectionData data, uint info, uint time) {
            //loop through list of URIs
            foreach(string uri in data.get_uris ()){
                string file = uri.replace("file://","").replace("file:/","");
                file = Uri.unescape_string (file);

                //add file to tree view
                if (this.is_video (file)) {
                    files_queue.push_tail (file);
                }
            }

            Gtk.drag_finish (drag_context, true, false, time);
            if (files_queue.get_length () > 0) {
                btn_start.show ();
            }
        }

        private void on_btn_start_clicked () {
            while (files_queue.get_length () > 0) {
                try {

                } catch (SpawnError e) {
                    var error_dialog = new Gtk.MessageDialog (this.window, Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK, _("Error"));
                    error_dialog.format_secondary_text (_("Error:") + "\n" + e.message);
                    error_dialog.run ();
                    error_dialog.destroy ();
                }
            }
        }

        /**
         * is_video:
         *
         * Check if the file is a video returning true, false otherwise.
         */      
        private bool is_video (string file) {
            foreach (var extension in extensions) {
                if (file.has_suffix (extension)) {
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

            dialog.authors = {"Nicola Tudino"};
            dialog.artists = {"Nicola Tudino"};
            dialog.documenters = {"Nicola Tudino"};
            dialog.translator_credits = ("Nicola Tudino");

            dialog.program_name = APP_NAME;
            dialog.comments = _("VCS Creator");
            dialog.copyright = _("Copyright");
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

        private void on_preferences_action () {
            message ("app.preferences action activated");
        }
    }
}
