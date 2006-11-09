# --
# Kernel/System/CustomerAuth/HTTPBasicAuth.pm - provides the $ENV{REMOTE_USER}
# authentification
# Copyright (C) 2001-2006 OTRS GmbH, http://otrs.org/
# --
# $Id: HTTPBasicAuth.pm,v 1.4 2006-11-09 08:31:15 martin Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --
# Note:
#
# If you use this module, you should use as fallback the following
# config settings:
#
# If use isn't login through apache ($ENV{REMOTE_USER})
# $Self->{CustomerPanelLoginURL} = 'http://host.example.com/not-authorised-for-otrs.html';
#
# $Self->{CustomerPanelLogoutURL} = 'http://host.example.com/thanks-for-using-otrs.html';
# --

package Kernel::System::CustomerAuth::HTTPBasicAuth;

use strict;

use vars qw($VERSION);
$VERSION = '$Revision: 1.4 $';
$VERSION =~ s/^\$.*:\W(.*)\W.+?$/$1/;

sub new {
    my $Type = shift;
    my %Param = @_;

    # allocate new hash for object
    my $Self = {};
    bless ($Self, $Type);

    # check needed objects
    foreach (qw(LogObject ConfigObject DBObject)) {
        $Self->{$_} = $Param{$_} || die "No $_!";
    }

    # Debug 0=off 1=on
    $Self->{Debug} = 0;

    return $Self;
}

sub GetOption {
    my $Self = shift;
    my %Param = @_;
    # check needed stuff
    if (!$Param{What}) {
        $Self->{LogObject}->Log(Priority => 'error', Message => "Need What!");
        return;
    }
    # module options
    my %Option = (
        PreAuth => 1,
    );
    # return option
    return $Option{$Param{What}};
}

sub Auth {
    my $Self = shift;
    my %Param = @_;
    # get params
    my $User = $ENV{REMOTE_USER};
    my $RemoteAddr = $ENV{REMOTE_ADDR} || 'Got no REMOTE_ADDR env!';
    if ($User) {
        my $Replace = $Self->{ConfigObject}->Get('Customer::AuthModule::HTTPBasicAuth::Replace');
        if ($Replace) {
            $User =~ s/^\Q$Replace\E//;
        }
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message => "User: $User authentification ok (REMOTE_ADDR: $RemoteAddr).",
        );
        return $User;
    }
    else {
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message => "User: No \$ENV{REMOTE_USER} !(REMOTE_ADDR: $RemoteAddr).",
        );
        return;
    }
}

1;
