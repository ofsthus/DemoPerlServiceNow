#!/usr/bin/perl
#            _.-````'-,_
#   _,.,_ ,-'`           `'-.,_
# /)     (\                   '``-.
#((      ) )                      `\
# \)    (_/                        )\
#  |       /)           '    ,'    / \
#  `\    ^'            '     (    /  ))
#    |      _/\ ,     /    ,,`\   (  "`
#     \Y,   |  \  \  | ````| / \_ \
#       `)_/    \  \  )    ( >  ( >
#                \( \(     |/   |/
#Brian Ofsthus  /_(/_(    /_(  /_(
#ofsthus@gmail.com----------------------
#    Script Name: snow_connection_example_sanitized.pl
#Script Location: ~/snow/
#    Description: ServiceNow Automation, Test connect and Show pulling data
#   Contributors: Brian Ofsthus
#          Notes:
#
#
#Release Information
#=========================================
#03/20/2015     Brian Ofsthus   Created                 


#Perl Modules needed
use MIME::Base64;
use JSON;
use REST::Client;

#Variables
$snow_user= "SNOWUSER";
$proxyUser="someproxyaccount";
$snowurl = "https://companyname.service-now.com";
$change = "CHG0478978";
#Pull Passwords
&get_snow_pass;
&get_proxy_pass;

#Set the Proxy URL
$proxyURL = 'http://' . $proxyUser . ':' . $proxyPwd . '@192.168.11.111:80';

#Create the REST Client
$client = REST::Client->new(host => $snowurl);

#Encode the login and password
$encoded_auth = encode_base64("$snow_user:$snow_passwd", '');

#Make the connection through your proxy
$client->getUseragent()->proxy(['http', 'https', 'ftp'], $proxyURL) or print "PROXY ISSUE\n";;

#Build your Search String
$string  = "change_request.do?JSONv2&sysparm_action=getRecords&sysparm_query=active=true^number=$change&displayvariables=true";

#Do your GET 
$client->GET("$string",
             {'Authorization' => "Basic $encoded_auth",
              'Accept' => 'application/json'}) or print "FAILED GET\n";
#THE CODE NUMBER
@CODE = split(/,/,$client->responseCode());
#THE JSON DATA
@DATA = split(/,/,$client->responseContent());
$ciname = "";
$sysid = "";
#Foreach through the JSON data to retive what you are needing. 
foreach $n (@DATA){
        $n =~ s/\"//g;
        @LN = split(/:/,$n);
        if ($LN[0] eq "name"){
        $ciname = $LN[1];
        }
        if ($LN[0] eq "sys_id"){
        $sysid = $LN[1];
        }
        if ($LN[0] eq "owned_by"){
        $owner_sysid = $LN[1];
        }
}


print "$ciname|$sysid|$owner_sysid";


sub get_proxy_pass {
open(IN, "< /var/.thor/proxypass.db");
@P = <IN>;
close(IN);
$crypted = $P[0];
$proxyPwd = decode_base64($crypted);
}



sub get_snow_pass {
open(IN, "< /var/.thor/snowpass.db");
@P = <IN>;
close(IN);
$crypted = $P[0];
$snow_passwd = decode_base64($crypted);
}
