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
        private int APP_WIDTH = 550;
        private int APP_HEIGHT = 450;

        private Gtk.ApplicationWindow window;
        private Gtk.HeaderBar headerbar;
        private Gtk.PopoverMenu popover;

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
            window.show_all ();
            window.show ();
            window.present ();
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
            menu_btn.set_active (true);
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

            GLib.MenuItem about_item = new GLib.MenuItem (_("About"), "app.about");
            menu.append_item (about_item);

            GLib.MenuItem close_item = new GLib.MenuItem (_("Close"), "app.quit");
            menu.append_item (close_item);

            popover.bind_model (menu, null);
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

        private void on_about_action () {
            string[] authors = { "tudo75" };
            Gtk.show_about_dialog (this.active_window,
                                   "program-name", "vcscreator",
                                   "authors", authors,
                                   "version", "0.1.0");
        }

        private void on_preferences_action () {
            message ("app.preferences action activated");
        }
    }
}
