
use strict;
use warnings;

use Test::More tests => 13;
use Test::NoWarnings;
use Test::MockObject;

use Dist::Zilla::Plugin::AutoMetaResources;

is_deeply getMetadata({}), {
    resources => {}
}, "no params generate no metadata";


is_deeply getMetadata({ 'bugtracker.rt' => 1}), {
    resources => {
        'bugtracker' => {
            'web' => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Test-AutoMetaResources',
            'mailto' => 'bug-Test-AutoMetaResources@rt.cpan.org'
        }
    }
}, "bugrtracker.rt is known";

is_deeply getMetadata({ 'bugtracker.github' => [{user => 'ajgb'}]}), {
    resources => {
        'bugtracker' => {
            'web' => 'https://github.com/ajgb/test-autometaresources/issues',
        }
    }
}, "bugrtracker.github is known";

is_deeply getMetadata({ 'bugtracker.other' => {}}), {
    resources => { }
}, "bugrtracker.other is not recognised";


is_deeply getMetadata({ 'repository.github' => [{user => 'ajgb'}]}), {
    resources => {
        'repository' => {
            'web' => 'https://github.com/ajgb/test-autometaresources',
            'url' => 'git://github.com/ajgb/test-autometaresources.git',
            'type' => 'git',
        }
    }
}, "repository.github is known";

is_deeply getMetadata({ 'repository.GitHub' => [{user => 'ajgb'}]}), {
    resources => {
        'repository' => {
            'web' => 'https://github.com/ajgb/test-autometaresources',
            'url' => 'git://github.com/ajgb/test-autometaresources.git',
            'type' => 'git',
        }
    }
}, "repository.GitHub is known";

is_deeply getMetadata({ 'repository.gitmo' => 1}), {
    resources => {
        'repository' => {
            'web' => 'http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=gitmo/Test-AutoMetaResources.git;a=summary',
            'url' => 'git://git.moose.perl.org/Test-AutoMetaResources.git',
            'type' => 'git',
        }
    }
}, "repository.gitmo is known";

is_deeply getMetadata({ 'repository.catsvn' => 1}), {
    resources => {
        'repository' => {
            'web' => 'http://dev.catalystframework.org/svnweb/Catalyst/browse/Test-AutoMetaResources',
            'url' => 'http://dev.catalyst.perl.org/repos/Catalyst/Test-AutoMetaResources/',
            'type' => 'svn',
        }
    }
}, "repository.catsvn is known";

for (qw(catagits p5sagit dbsrgits)) {
    is_deeply getMetadata({ "repository.$_" => 1}), {
        resources => {
            'repository' => {
                'web' => "http://git.shadowcat.co.uk/gitweb/gitweb.cgi?p=$_/Test-AutoMetaResources.git;a=summary",
                'url' => "git://git.shadowcat.co.uk/$_/Test-AutoMetaResources.git",
                'type' => 'git',
            }
        }
    }, "repository.$_ is known";
};

is_deeply getMetadata({ 'homepage' => 'http://myperlprojects.org/%{lcdist}/'}), {
    resources => {
        'homepage' => 'http://myperlprojects.org/test-autometaresources/'
    }
}, "custom params passed and processed";



sub getMetadata {
    my $args = shift;

    my $zilla = Test::MockObject->new;
    $zilla->set_isa('Dist::Zilla');
    $zilla->mock(name => sub { 'Test-AutoMetaResources' });

    return Dist::Zilla::Plugin::AutoMetaResources->new(
        {
            plugin_name => 'AutoMetaResources',
            zilla => $zilla,
            %$args
        }
    )->metadata;
}

