#!/usr/bin/env perl

use warnings;
use strict;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON;
use Nagios::Monitoring::Plugin;
use Data::Dumper;

my $version = "1.0.0-beta-1";
my $user_agent = "check_glpi/1.0";

my $np = Nagios::Monitoring::Plugin->new(
    usage => "Usage: %s -h|--host <host> "
    . "[ -p|--port <port> ] "
    . "[ -d|--subdirectory <subdirectory> ] "
    . "[ -P|--protocol <HTTP|HTTPS> ] "
    . "[ -s|--service <service> ] "
    . "[ --ignoressl ] "
    . "[ -h|--help ] ",
    version => $version,
    blurb   => 'Nagios plugin to check GLPI service status via http(s)',
    extra   => "\nExample: \n"
    . "check_json.pl --host 192.168.1.100 --protocol https --port 8443 --subdirectory glpi -s db' ",
    url     => 'https://github.com/cconard96/check_glpi',
    plugin  => 'check_glpi',
    timeout => 15,
    shortname => "Check GLPI status",
);

$np->add_arg(
    spec => 'host|h=s',
    help => '-h, --host localhost',
    required => 1,
);

$np->add_arg(
    spec => 'port|p=i',
    help => '-p, --port 80',
    default => 80,
);

$np->add_arg(
    spec => 'protocol|P=s',
    help => '-P, --protocol 80',
    default => 'HTTP'
);

$np->add_arg(
    spec => 'subdirectory|d=s',
    help => '-d, --subdirectory glpi',
    required => 0,
);

$np->add_arg(
    spec => 'service|s=s',
    help => '-s, --service db',
    required => 0,
);

$np->add_arg(
    spec => 'ignoressl',
    help => "--ignoressl\n   Ignore bad ssl certificates",
);

$np->getopts;
if ($np->opts->verbose) { (print Dumper ($np))};

my $ua = LWP::UserAgent->new;

$ua->env_proxy;
$ua->agent($user_agent);
$ua->default_header('Accept' => 'application/json');
$ua->protocols_allowed( [ 'http', 'https'] );
$ua->parse_head(0);
$ua->timeout($np->opts->timeout);

if ($np->opts->ignoressl) {
    $ua->ssl_opts(verify_hostname => 0, SSL_verify_mode => 0x00);
}

if ($np->opts->verbose) { (print Dumper ($ua))};

my $attribute = '{status}';

my $request_url = lc($np->opts->protocol).'://'.$np->opts->host.':'.$np->opts->port;
if ($np->opts->subdirectory) {
    $request_url = $request_url . '/' . $np->opts->subdirectory;
}
$request_url = $request_url . '/status.php?format=json';
if ($np->opts->service) {
    $request_url = $request_url."&service=".$np->opts->service;
} else {
    $attribute = '{glpi}->{status}';
}
my $response = $ua->request(GET $request_url);

## Parse JSON
my $json_response = decode_json($response->content);
if ($np->opts->verbose) { (print Dumper ($json_response))};

my $check_value;
my $result = -1;
my $resultTmp;

my $check_value_str = '$check_value = $json_response->'.$attribute;

if ($np->opts->verbose) { (print Dumper ($check_value_str))};
eval $check_value_str;

if (!defined $check_value) {
    $np->nagios_exit(UNKNOWN, "No value received");
}

if ($check_value eq "OK") {
    $result = 0;
} elsif ($check_value eq "WARNING") {
    $result = 1;
} elsif ($check_value eq "ERROR") {
    $result = 2;
} else {
    $result = -1;
}

$np->nagios_exit(
    return_code => $result,
    message     => $response->content,
);