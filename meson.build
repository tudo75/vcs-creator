# project name and programming language
project('com.github.tudo75.vcs-creator', ['vala', 'c'], version: '0.1.4')

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

conf_data = configuration_data()
conf_data.set('PROJECT_NAME', meson.project_name())
conf_data.set('GETTEXT_PACKAGE', meson.project_name())
conf_data.set('VERSION', meson.project_version())
conf_data.set('PREFIX', get_option('prefix'))

config_header = configure_file(
    input: 'src/config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

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

vala_lint = find_program('io.elementary.vala-lint', required : false)
if vala_lint.found()
    test (
        'Vala lint',
        vala_lint,
        args: [join_paths(meson.source_root(), 'src')]
    )
endif

executable(
    meson.project_name(),
    sources,
    config_header,
    dependencies: dependencies,
    install: true,
)

subdir('po')
subdir('resources')

# create api documentation from code
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
    build_by_default: false,
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
