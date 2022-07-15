# project name and programming language
project('com.github.tudo75.vcs-creator', ['vala', 'c'], version: '0.1.0')

assert('com.github.tudo75.vcs-creator.gschema.xml'==meson.project_name() + '.gschema.xml', 'proj name and gschema file not the same')

# Include the translations module
i18n = import('i18n')
# define GETTEXT_PACKAGE
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')
# Set our translation domain
add_global_arguments(['-DG_LOG_DOMAIN="@0@"'.format (meson.project_name())], language:'c')


# Include the gnome module
gnome = import('gnome')

# add resources to the executeable
dependencies = [
	dependency('gtk+-3.0', version: '>= 3.20'),
	dependency('glib-2.0'),
	dependency('gio-2.0'),
	dependency('gee-0.8'),
	dependency('cairo'),
    meson.get_compiler('c').find_library('m', required: false),
    meson.get_compiler('vala').find_library('posix'),
]

sources = files(
    'src/application.vala',
    'src/settingsdialog.vala',
    'src/filesdialog.vala',
)

sources += gnome.compile_resources(
    meson.project_name() + '.resources',
    'resources/com.github.tudo75.vcs-creator.gresource.xml',
    source_dir: 'resources',
)

executable(
    meson.project_name(),
    sources,
    dependencies: dependencies,
    install: true,
)

subdir('po')
subdir('resources')

# dcreate api documentation from code
valadoc = find_program(
    'valadoc',
    required: false,
)
docsrc = [
    '../src/application.vala',
    '../src/settingsdialog.vala',
    '../src/filesdialog.vala',
]

doc = custom_target(
    'documentation',
	output: 'doc',
	command: [
        valadoc, 
        '--verbose',
        '--force',
        '--internal',
        '--private',
        '--use-svg-images',
        '--package-name=VcsCreator',
        '--package-version=0.1.0',
        '--pkg=gtk+-3.0',
        '--pkg=glib-2.0',
        '--pkg=gio-2.0',
        '--pkg=gee-0.8',
        '--pkg=posix',
        '--directory=../doc',
        '--target-glib=auto',
        # '--import=gtk+-3.0',
        docsrc
    ],
)


meson.add_install_script('build-aux/post_install.py')