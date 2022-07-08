
install_data(
    'com.github.tudo75.vcs-creator.gschema.xml',
    install_dir: join_paths(
        get_option('datadir'), 
        'glib-2.0', 
        'schemas'
    ),
    rename: meson.project_name() + '.gschema.xml',
)

# not install compile only for local testing
gnome.compile_schemas(
    build_by_default: true,
    depend_files: 'com.github.tudo75.vcs-creator.gschema.xml',
)

# install icon
install_data(
  'vcs-creator.svg',
  install_dir: join_paths(
        get_option('datadir'), 
        'icons', 
        'hicolor',
        'scalable',
        'apps',
    ),
)

# install launcher
install_data(
  'vcs-creator.desktop',
  install_dir: join_paths(
        get_option('datadir'), 
        'applications',
    ),
)

