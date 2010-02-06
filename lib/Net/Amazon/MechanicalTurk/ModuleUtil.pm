package Net::Amazon::MechanicalTurk::ModuleUtil;
use strict;
use warnings;
use IO::Dir;
use Carp;

our $VERSION = '1.01_01';

sub listSubmodules {
    my ($class, $package) = @_;
    my $dir = $package;
    $dir =~ s/::/\//g;
    my %submodules;
    foreach my $inc (@INC) {
        next unless !ref($inc);
        my $dh = IO::Dir->new("$inc/$dir");
        if ($dh) {
            while (my $file = $dh->read) {
                if ($file =~ /\.pm$/i and -f "$inc/$dir/$file") {
                    my $submod = "${package}::${file}";
                    $submod =~ s/\.pm$//i;
                    $submodules{$submod} = 1;
                }
            }
            $dh->close;
        }
    }
    return sort keys %submodules;
}

sub packageExists {
    my ($class, $package, $moduleFile) = @_;
    
    if (defined($moduleFile) && exists($INC{$moduleFile})) {
        return 1;
    }
    # Symbol table black magic
    no strict 'refs';
    return scalar(keys(%{*{"${package}::"}}));
}

sub require {
    my ($class, $module) = @_;
        my $moduleFile = $module . ".pm";
        $moduleFile =~ s/::/\//g;
    if (!$class->packageExists($module, $moduleFile)) {
        require $moduleFile;
    }
}

sub tryRequire {
    my ($class, $module) = @_;
    eval {
        Net::Amazon::MechanicalTurk::ModuleUtil->require($module);
    };
    return (!$@);
}

sub requireFirst {
    my $class = shift;
    my @modules = ($#_ == 0 and UNIVERSAL::isa($_[0], "ARRAY")) ? @{$_[0]} : @_;
    foreach my $module (@modules) {
        if (Net::Amazon::MechanicalTurk::ModuleUtil->tryRequire($module)) {
            return $module;
        }
    }
    Carp::croak("Could not load any of the following modules " . join(", ", @modules) . ".");
}

return 1;
