# Nagios Check for GLPI (check_glpi)

## Prerequisites
- Nagios::Monitoring::Plugin Perl module
- JSON Perl module
- GLPI >= 10.0.0

## Installation
1. Copy check_glpi.pl into your existing plugin directory or into a new directory for your plugins.
2. Create a new command definition using the following as a reference:
```
define command {
    command_name    check_glpi
    command_line    /opt/nagios/plugins/check_glpi.pl -h $HOSTADDRESS$ $ARG1$
}
```
Be sure to replace the path to the check_glpi script.
3. Create new service definitions for your hosts/host groups to use this command.
Example:
```
define service {
   use                      local-service
   hostgroup_name           glpi-servers
   service_description      GLPI DB
   check_command            check_glpi!-d glpi --service db
}
```

## Usage
`check_glpi -h|--host <host> [ -p|--port <port> ] [ -d|--subdirectory <subdirectory> ][ -P|--protocol <HTTP|HTTPS> ][ -s|--service <service> ] [ -t|--timeout <timeout> ][ --ignoressl ] [ -h|--help ]`

Arguments
```
 -?, --usage
   Print usage information
 -h, --help
   Print detailed help screen
 -V, --version
   Print version information
 --extra-opts=[section][@file]
   Read options from an ini file. See https://nagios-plugins.org/doc/extra-opts.html
   for usage and examples.
 -h, --host localhost
 -p, --port 80
 -P, --protocol 80
 -d, --subdirectory glpi
 -s, --service db
 --ignoressl
   Ignore bad ssl certificates
 -v, --verbose
   Show details for command-line debugging (can repeat up to 3 times)
```

Example: 
`check_json.pl --host 192.168.1.100 --protocol https --port 8443 --subdirectory glpi --service db'`

## GLPI Services
Use the `glpi:system:list_services` command with GLPI's CLI to identify the services that have their status available through GLPI's status checker.
A non-exhaustive list of these services can be found below:
| Service         | Description |
|-----------------|------------ |
| db              | Database status including the master and slave database servers
| cas             | CAS authentication server status
| ldap            | LDAP/AD server status
| imap            | Outgoing email server status
| mail_collectors | Email collector status
| crontasks       | Automatic action status including stuck actions
| filesystem      | Permission status for multiple GLPI directories
| plugins         | Plugin statuses
