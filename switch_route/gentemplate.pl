#!/usr/bin/perl
# Author: Gergely Czuczy <gergely.czuczy@harmless.hu>
 
 
use strict;
 
my %templates = ('graph' => '			<graph name="GR_NAME" width="900" height="200">
					<yaxistype>0</yaxistype>
					<show_work_period>1</show_work_period>
					<show_triggers>1</show_triggers>
					<graphtype>0</graphtype>
					<yaxismin>0.0000</yaxismin>
					<yaxismax>100.0000</yaxismax>
					<show_legend>0</show_legend>
					<show_3d>0</show_3d>
					<percent_left>0.0000</percent_left>
					<percent_right>0.0000</percent_right>
					<graph_elements>
GR_ELEMENTS
					</graph_elements>
				</graph>
',		 'graphElement' =>'						<graph_element item="GE_TEMPLATE:GE_OIDN.NNN">
							<drawtype>GE_DTYPE</drawtype>
							<sortorder>GE_ORDER</sortorder>
							<color>GE_COLOR</color>
							<yaxisside>1</yaxisside>
							<calc_fnc>2</calc_fnc>
							<type>0</type>
							<periods_cnt>5</periods_cnt>
						</graph_element>
',		 'item' => '				<item type="IT_TYPE" key="IT_KEY" value_type="IT_VALUETYPE">
					<description>IT_DESCR</description>
					<ipmi_sensor></ipmi_sensor>
					<delay>IT_DELAY</delay>
					<history>7</history>
					<trends>365</trends>
					<status>0</status>
					<units>IT_UNITS</units>
					<multiplier>IT_MULTIPLIER</multiplier>
					<delta>IT_DELTA</delta>
					<formula>IT_FORMULA</formula>
					<lastlogsize>0</lastlogsize>
					<logtimefmt></logtimefmt>
					<delay_flex></delay_flex>
					<params></params>
					<trapper_hosts></trapper_hosts>
					<snmp_community>IT_COMMUNITY</snmp_community>
					<snmp_oid>IT_OID</snmp_oid>
					<snmp_port>161</snmp_port>
					<snmpv3_securityname></snmpv3_securityname>
					<snmpv3_securitylevel>0</snmpv3_securitylevel>
					<snmpv3_authpassphrase></snmpv3_authpassphrase>
					<snmpv3_privpassphrase></snmpv3_privpassphrase>
				</item>
',		 'trigger'=>'                                <trigger>
                                        <description>TR_DESCR</description>
                                        <type>0</type>
                                        <expression>TR_EXPR</expression>
                                        <url></url>
                                        <status>0</status>
                                        <priority>TR_PRIO</priority>
                                        <comments>TR_DESCR</comments>
                                </trigger>
',		 'triggerLinkStatus'=>'                                <trigger>
                                        <description>Link status changed on LS_DESCR</description>
                                        <type>0</type>
                                        <expression>({{HOSTNAME}:ifOperStatus.NNN.last(0)}=2)&amp;({{HOSTNAME}:ifAdminStatus.NNN.last(0)}=1)</expression>
                                        <url></url>
                                        <status>0</status>
                                        <priority>2</priority>
                                        <comments>Inet link down on LS_DESCR</comments>
                                </trigger>
');
 
my @graph_colors = ('000099','009900','990000',
		    '0000CC','00CC00','CC0000',
		    '9900CC','99CC00','CC9900');
my ($graph_colorindex,$graph_order)=(0,0);
my ($infile,$outfile);
my $argc = @ARGV;
my %ifs;
my %disks;
my @nodisks;
my $sysname;
my %args = ('snmpver'=>'2');
my %snmpver = ('1'=>'1', '2'=>'4');
# char=1
# float=0
# int=3
# text=4
my %snmptypes = ('STRING'=>'1',
		 'INTEGER'=>'3',
		 'Gauge32'=>'3',
		 'Counter32'=>'3',
		 'Counter64'=>'3',
		 );
my %oiddatatypes = ('saFePVBitErrorRate'=>'0',
		    'saFeQPSKBitErrorRate'=>'0',
		    );
my %oiddeltas = ('Counter32'=>'1',
		 'Counter64'=>'1',
		 );
my %fieldtypes;
my %forcedtypes = ('saFeQPSKBitErrorRate'=>'0',
		   'saFePVBitErrorRate'=>'0',
		   'saFeSignalRatio'=>'3',
		   'saVideoBitrate'=>'0',
		   'ntcDevsMod01MoOutputLevel.1.1'=>'0',
		   'ntcDevsMod01MoPacketRate.1'=>'0',
		  );
my %features = ('ifDescr'=>0,'ifstat'=>0,
		'ifOper'=>0,'ifstatus'=>0,
		'hrStorageDescr'=>0,'hrStorageSize'=>0,'hrStorageUsed'=>0, 'storage'=>0,
		'saRcv'=>0);
my @nostorage = ('hrStorageRemovableDisk','hrStorageCompactDisc');
my %setup;
my %units = ('ifInOctets' => 'bps', 'ifOutOctets' => 'bps',
	     'upsBatteryTemperature'=>'Â°C', 'upsInputVoltage'=>'V',
	     'upsOutputVoltage'=>'V', 'upsInputCurrent'=>'A',
	     'upsOutputCurrent'=>'A', 'upsOutputPercentLoad'=>'%',
	     'upsEstimatedMinutesRemaining'=>'m',
	     'ifInUcastPkts'=>'pps',
	     'ifInNUcastPkts'=>'pps',
	     'ifOutUcastPkts'=>'pps',
	     'ifOutNUcastPkts'=>'pps',
	     'ifInMulticastPkts'=>'pps',
	     'ifInBroadcastPkts'=>'pps',
	     'ifOutMulticastPkts'=>'pps',
	     'ifOutBroadcastPkts'=>'pps',
	     'upsEstimatedMinutesRemaining'=>'',
	     'upsBatteryStatus'=>'',
	     'upsAlarmPresent'=>'',
	     'upsAlarmBatteryBad'=>'',
	     'upsAlarmOnBattery'=>'',
	     'upsAlarmInputBad'=>'',
	     'upsAlarmOutputBad'=>'',
	     'upsAlarmOutputOverload'=>'',
	     'upsAlarmOnBypass'=>'',
	     'upsAlarmChargerFailer'=>'',
	     'upsAlarmFanFailure'=>'',
	     'upsAlarmFuseFailure'=>'',
	     'upsAlarmGenericFault'=>'',
	     'upsAlarmCommuncationsLost'=>'',
	     'saVideoBitrate'=>'Mbps',
	     'saCaAuthorized'=>'',
	     'saCaEncrypted'=>'',
	     'saFeSignalLevel'=>'dB',
	     'saFeSignalRatio'=>'',
	     'saFePVBitErrorRate'=>'',
	     'saFeQPSKBitErrorRate'=>'',
	     'saTuningAsiSignalLocked'=>'',
	     'saMainPeAuthState'=>'',
	     'saFeCurrentInput'=>'',
	     'saFeSignalState'=>'',
	     'ifHCInOctets'=>'b',
	     'ifHCInUcastPkts'=>'pps',
	     'ifHCInMulticastPkts'=>'pps',
	     'ifHCInBroadcastPkts'=>'pps',
	     'ifHCOutOctets'=>'b',
	     'ifHCOutUcastPkts'=>'pps',
	     'ifHCOutMulticastPkts'=>'pps',
	     'ifHCOutBroadcastPkts'=>'pps',
	     'hrStorageUsed'=>'B',
	     'hrStorageSize'=>'B',
	     'ntcDevsMod01MoOutputLevel.1.1'=>'dBm',
	     );
 
my %deltas = ('upsBatteryTemperature'=>'0', 'upsInputVoltage'=>'0',
	      'upsOutputVoltage'=>'0', 'upsInputCurrent'=>'0',
	      'upsOutputCurrent'=>'0', 'upsOutputPercentLoad'=>'0',
	      'upsEstimatedMinutesRemaining'=>'0',
	      'upsBatteryStatus'=>'0',
	      'upsAlarmPresent'=>'0',
	      'upsAlarmBatteryBad'=>'0',
	      'upsAlarmOnBattery'=>'0',
	      'upsAlarmInputBad'=>'0',
	      'upsAlarmOutputBad'=>'0',
	      'upsAlarmOutputOverload'=>'0',
	      'upsAlarmOnBypass'=>'0',
	      'upsAlarmChargerFailer'=>'0',
	      'upsAlarmFanFailure'=>'0',
	      'upsAlarmFuseFailure'=>'0',
	      'upsAlarmGenericFault'=>'0',
	      'upsAlarmCommuncationsLost'=>'0',
	      'ifOperStatus'=>'0',
	      'ifAdminStatus'=>'0',
	      'hrStorageSize'=>'0',
	      'hrStorageUsed'=>'0',
	      'saVideoBitrate'=>'0',
	      'saCaAuthorized'=>'0',
	      'saCaEncrypted'=>'0',
	      'saFeSignalLevel'=>'0',
	      'saFeSignalRatio'=>'0',
	      'saFePVBitErrorRate'=>'0',
	      'saFeQPSKBitErrorRate'=>'0',
	      'saTuningAsiSignalLocked'=>'0',
	      'saMainPeAuthState'=>'0',
	      'saFeCurrentInput'=>'0',
	      'saFeSignalState'=>'0',
	      );
my %mult = ('ifInOctets' => '8', 'ifOutOctets' => '8',
	    'ifHCInOctets' => '8', 'ifHCOutOctets' => '8',
	    'upsInputCurrent'=>'0.1', 'upsOutputCurrent'=>'0.1',);
my %oids = ('ifTraffic'=> {'ifInOctets'=>'1.3.6.1.2.1.2.2.1.10',
			   'ifOutOctets'=>'1.3.6.1.2.1.2.2.1.16',
			   'ifDescr'=>'1.3.6.1.2.1.2.2.1.2',
			   'ifAlias'=>'1.3.6.1.2.1.31.1.1.1.18',
			   'ifInUcastPkts'=>'1.3.6.1.2.1.2.2.1.11',
			   'ifInNUcastPkts'=>'1.3.6.1.2.1.2.2.1.12',
			   'ifOutUcastPkts'=>'1.3.6.1.2.1.2.2.1.17',
			   'ifOutNUcastPkts'=>'1.3.6.1.2.1.2.2.1.18',
			   'ifInMulticastPkts'=>'1.3.6.1.2.1.31.1.1.1.2',
			   'ifInBroadcastPkts'=>'1.3.6.1.2.1.31.1.1.1.3',
			   'ifOutMulticastPkts'=>'1.3.6.1.2.1.31.1.1.1.4',
			   'ifOutBroadcastPkts'=>'1.3.6.1.2.1.31.1.1.1.5',
		       },
	    'ifStatus'=> {'ifOperStatus'=>'1.3.6.1.2.1.2.2.1.8',
			  'ifAdminStatus'=>'1.3.6.1.2.1.2.2.1.7',},
	    'storage'=> {'hrStorageDescr'=>'1.3.6.1.2.1.25.2.3.1.3',
			 'hrStorageAllocationUnits'=>'1.3.6.1.2.1.25.2.3.1.4',
			 'hrStorageSize'=>'1.3.6.1.2.1.25.2.3.1.5',
			 'hrStorageUsed'=>'1.3.6.1.2.1.25.2.3.1.6',},
	    'ups'=>{'upsBatteryStatus'=>'1.3.6.1.2.1.33.1.2.2',
		    'upsAlarmPresent'=>'1.3.6.1.2.1.33.1.6.1',
		    'upsAlarmBatteryBad'=>'1.3.6.1.2.1.33.1.6.3.1',
		    'upsAlarmOnBattery'=>'1.3.6.1.2.1.33.1.6.3.2',
		    'upsAlarmInputBad'=>'1.3.6.1.2.1.33.1.6.3.6',
		    'upsAlarmOutputBad'=>'1.3.6.1.2.1.33.1.6.3.7',
		    'upsAlarmOutputOverload'=>'1.3.6.1.2.1.33.1.6.3.8',
		    'upsAlarmOnBypass'=>'1.3.6.1.2.1.33.1.6.3.9',
		    'upsAlarmChargerFailer'=>'1.3.6.1.2.1.33.1.6.3.13',
		    'upsAlarmFanFailure'=>'1.3.6.1.2.1.33.1.6.3.16',
		    'upsAlarmFuseFailure'=>'1.3.6.1.2.1.33.1.6.3.17',
		    'upsAlarmGenericFault'=>'1.3.6.1.2.1.33.1.6.3.18',
		    'upsAlarmCommuncationsLost'=>'1.3.6.1.2.1.33.1.6.3.20',},
	    'upsGraph'=>{
		'upsEstimatedMinutesRemaining'=>'1.3.6.1.2.1.33.1.2.3',
		'upsBatteryTemperature'=>'1.3.6.1.2.1.33.1.2.7',
		'upsInputVoltage'=>'1.3.6.1.2.1.33.1.3.3.1.3',
		'upsInputCurrent'=>'1.3.6.1.2.1.33.1.3.3.1.4',
		'upsOutputVoltage'=>'1.3.6.1.2.1.33.1.4.4.1.2',
		'upsOutputCurrent'=>'1.3.6.1.2.1.33.1.4.4.1.3',
		'upsOutputPercentLoad'=>'1.3.6.1.2.1.33.1.4.4.1.5',
	    },
	    'upsOther'=>{
		'upsOutputSource'=>'1.3.6.1.2.1.33.1.4.1',
	    },
	    'saRcv'=> {
		'saVideoBitrate'=>'1.3.6.1.4.1.1429.2.2.6.2.19.1',
		'saCaAuthorized'=>'1.3.6.1.4.1.1429.2.2.6.2.16.2.1.3',
		'saCaEncrypted'=>'1.3.6.1.4.1.1429.2.2.6.2.16.2.1.4',
		'saFeSignalLevel'=>'1.3.6.1.4.1.1429.2.2.6.2.12.1.1.11',
		'saFeSignalRatio'=>'1.3.6.1.4.1.1429.2.2.6.2.12.1.1.10',
		'saFePVBitErrorRate'=>'1.3.6.1.4.1.1429.2.2.6.2.12.1.1.9',
		'saFeQPSKBitErrorRate'=>'1.3.6.1.4.1.1429.2.2.6.2.12.1.1.8',
		'saTuningAsiSignalLocked'=>'1.3.6.1.4.1.1429.2.2.6.2.11.4',
		'saMainPeAuthState'=>'1.3.6.1.4.1.1429.2.2.6.2.2.1.1.6',
		'saFeCurrentInput'=>'1.3.6.1.4.1.1429.2.2.6.2.12.1.1.2',
		'saFeSignalState'=>'1.3.6.1.4.1.1429.2.2.6.2.12.1.1.5',
	    },
	    'gyda'=> {
		'choSignalInput1'=>'1.3.6.1.4.1.8768.1.3.8.2.1.4',
		'choSignalInput2'=>'1.3.6.1.4.1.8768.1.3.8.2.1.5',
		'choLock'=>'1.3.6.1.4.1.8768.1.3.8.2.1.3',
		'choState'=>'1.3.6.1.4.1.8768.1.3.8.2.1.9',
	    },
	    'hphealth'=> {
		'cpqSeCpuStatus'=>'1.3.6.1.4.1.232.1.2.2.1.1.6',
		'cpqSiMemModuleECCStatus.0'=>'1.3.6.1.4.1.232.2.2.4.5.1.11.0',
		'cpqDaCntlrCondition'=>'1.3.6.1.4.1.232.3.2.2.1.1.6',
		'cpqDaCntlrBoardStatus'=>'1.3.6.1.4.1.232.3.2.2.1.1.10',
		'cpqDaCntlrBoardCondition'=>'1.3.6.1.4.1.232.3.2.2.1.1.12',
		'cpqDaAccelBattery'=>'1.3.6.1.4.1.232.3.2.2.2.1.6',
		'cpqDaLogDrvStatus.5'=>'1.3.6.1.4.1.232.3.2.3.1.1.4.5',
		'cpqDaPhyDrvStatus.5'=>'1.3.6.1.4.1.232.3.2.5.1.1.6.5',
		'cpqDaPhyDrvBay.5'=>'1.3.6.1.4.1.232.3.2.5.1.1.5.5',
		'cpqDaPhyDrvSmartStatus.5'=>'1.3.6.1.4.1.232.3.2.5.1.1.57.5',
		'cpqDaPhyDrvModel.5'=>'1.3.6.1.4.1.232.3.2.5.1.1.3.5',
		'cpqHeThermalTempStatus'=>'1.3.6.1.4.1.232.6.2.6.3',
		'cpqHeThermalSystemFanStatus'=>'1.3.6.1.4.1.232.6.2.6.4',
		'cpqHeThermalCpuFanStatus'=>'1.3.6.1.4.1.232.6.2.6.5',
		'cpqHeFltTolFanPresent.1'=>'1.3.6.1.4.1.232.6.2.6.7.1.4.1',
		'cpqHeFltTolFanCondition.1'=>'1.3.6.1.4.1.232.6.2.6.7.1.9.1',
		'cpqHeTemperatureCondition.1'=>'1.3.6.1.4.1.232.6.2.6.8.1.6.1',
		'cpqHeFltTolPwrSupplyCondition'=>'1.3.6.1.4.1.232.6.2.9.1',
		'cpqHeFltTolPowerSupplyPresent'=>'1.3.6.1.4.1.232.6.2.9.3.1.3.0',
		'cpqHeFltTolPowerSupplyStatus.0'=>'1.3.6.1.4.1.232.6.2.9.3.1.5.0',
		'cpqHeFltTolPowerSupplyCondition.0'=>'1.3.6.1.4.1.232.6.2.9.3.1.4.0',
		'cpqHeResMemModuleStatus.0'=>'1.3.6.1.4.1.232.6.2.14.11.1.4.0',
		'cpqHeResMemModuleCondition.0'=>'1.3.6.1.4.1.232.6.2.14.11.1.5.0',
		'cpqHeTemperatureCelsius.1'=>'1.3.6.1.4.1.232.6.2.6.8.1.4.1'
	    },
	    'hpdriveperf'=> {
		'cpqDaPhyDrvReads.5'=>'1.3.6.1.4.1.232.3.2.5.1.1.11.5',
		'cpqDaPhyDrvWrites.5'=>'1.3.6.1.4.1.232.3.2.5.1.1.13.5',
	    },
	    'ntcmod'=>{
		'ntcDevsMod01MoOutputLevel.1.1'=>'1.3.6.1.4.1.5835.3.1.3.1.29.1.1',
		'ntcDevsMod01MoTxStatus.1'=>'1.3.6.1.4.1.5835.3.1.3.1.37.1',
		'ntcDevsMod01MoPacketRate.1'=>'1.3.6.1.4.1.5835.3.1.3.1.79.1',
		'ntcDevsMod01AlAlarmsCur.0'=>'1.3.6.1.4.1.5835.3.1.2.1.9.0',
	    },
	    'ciscohealth'=> {
		'ciscoEnvMonFanState'=>'1.3.6.1.4.1.9.9.13.1.4.1.3',
		'ciscoEnvMonSupplyState'=>'1.3.6.1.4.1.9.9.13.1.5.1.3',
	    },
	    'helper'=> {
		'ifSpeed'=>'1.3.6.1.2.1.2.2.1.5',
		'moduleLabel.gyda.1'=>'1.3.6.1.4.1.8768.1.4.5.1.1.4.2.1',
		'moduleStatus.gyda.1'=>'1.3.6.1.4.1.8768.1.4.5.1.1.3.2.1',
		'cpqDaLogDrvOsName'=>'1.3.6.1.4.1.232.3.2.3.1.1.14.5',
		'cpqHeTemperatureLocale.1'=>'1.3.6.1.4.1.232.6.2.6.8.1.3.1',
	    },
	    'replacement'=> {
		'ifHCInOctets'=>'1.3.6.1.2.1.31.1.1.1.6',
		'ifHCInUcastPkts'=>'1.3.6.1.2.1.31.1.1.1.7',
		'ifHCInMulticastPkts'=>'1.3.6.1.2.1.31.1.1.1.8',
		'ifHCInBroadcastPkts'=>'1.3.6.1.2.1.31.1.1.1.9',
		'ifHCOutOctets'=>'1.3.6.1.2.1.31.1.1.1.10',
		'ifHCOutUcastPkts'=>'1.3.6.1.2.1.31.1.1.1.11',
		'ifHCOutMulticastPkts'=>'1.3.6.1.2.1.31.1.1.1.12',
		'ifHCOutBroadcastPkts'=>'1.3.6.1.2.1.31.1.1.1.13',
	    },
	    'pf'=> {
		'pfStateTableCount'=>'1.3.6.1.4.1.12325.1.200.1.3.1',
		'pfStateTableSearches'=>'1.3.6.1.4.1.12325.1.200.1.3.2',
		'pfStateTableInserts'=>'1.3.6.1.4.1.12325.1.200.1.3.3',
		'pfStateTableRemovals'=>'1.3.6.1.4.1.12325.1.200.1.3.4',
		'pfLimitsStates'=>'1.3.6.1.4.1.12325.1.200.1.5.1',
	    },
#	    'ups'=>'1.3.6.1.2.1.33.1.',
#	    ''=>'',
	    );
my %delays = ('choSignalInput1'=>60,
	      'choSignalInput2'=>60,
	      'choLock'=>30,
	      );
my %noitem = ('ifDescr'=>1,'ifAlias'=>1,
	      'hrStorageDescr'=>1, 'hrStorageAllocationUnits'=>1,
	      );
my %nofeatures = ('helper'=>1, 'replacement'=>1);
my %features = ('ifDescr'=>0,'ifstat'=>0,
		'ifOper'=>0,'ifstatus'=>0,
		'hrStorageDescr'=>0,'hrStorageSize'=>0,'hrStorageUsed'=>0, 'storage'=>0,
		'saRcv'=>0);
my %replaces = ('ifInOctets'=>'ifHCInOctets',
		'ifInUcastPkts'=>'ifHCInUcastPkts',
		'ifInMulticastPkts'=>'ifHCInMulticastPkts',
		'ifInBroadcastPkts'=>'ifHCInBroadcastPkts',
		'ifOutOctets'=>'ifHCOutOctets',
		'ifOutUcastPkts'=>'ifHCOutUcastPkts',
		'ifOutMulticastPkts'=>'ifHCOutMulticastPkts',
		'ifOutBroadcastPkts'=>'ifHCOutBroadcastPkts',
		);
my @delaystat;
my ($items,$graphs,$triggers);
my $community = 'public';
my %graphdefs = ('pfstates' => {'pfStateTableCount'=>1,
				'pfLimitsStates'=>1},
		 'pfusage' => {'pfStateTableSearches'=>1,
			       'pfStateTableInserts'=>1,
			       'pfStateTableRemovals'=>1},
		 );
my %itemlist;
 
# cache hash
my %revoidmap;
foreach my $cat (keys %oids) {
    foreach my $oidname (keys %{$oids{$cat}}) {
	$revoidmap{$oids{$cat}{$oidname}} = $oidname;
    }
}
 
for ($argc=@ARGV; $argc>1; $argc=@ARGV) {
    my $arg = $ARGV[0];
    if ( $arg =~ /^--snmpver=(1|2)$/ ) {
	$args{'snmpver'}=$1;
    } elsif ( $arg =~ /^--noifstat$/ ) {
	$args{'noifstat'}=1;
	$nofeatures{'ifTraffic'}=1;
    } elsif ( $arg =~ /^--noifstatus$/ ) {
	$args{'noifstatus'}=1;
	$nofeatures{'ifStatus'}=1;
    } elsif ( $arg =~ /^--sysname=(.*)$/ ) {
	$sysname = $1;
	$sysname =~ s/\"//g;
    } elsif ( $arg =~ /^--community=(.*)$/ ) {
	$community = $1;
    } else {
	die "Unkown parameter: '$arg'\n";
    }
    shift @ARGV;
}
 
die "Usage:\n\t$0 <snmpdump>\n" if ( $argc != 1 );
 
$infile = @ARGV[0];
$outfile = $infile.'.xml';
 
die "$infile is not readable\n" if ( ! -r $infile );
 
# getvalue($string)
sub getvalue {
    my ($string) = @_;
 
    if ( $string =~ /^.*\(([0-9]+)\)$/ ) {
	$string = $1;
    }
 
    return $string;
}
 
sub getreplacement {
    my ($oidname, $n) = @_;
 
    if ( exists($replaces{$oidname}) ) {
	my $r = $replaces{$oidname};
	return $replaces{$oidname} if ( exists($setup{'replacement'}{$r}{$n}) );
    }
 
    return $oidname;
}
 
sub log10 {
    my $n = shift;
    return log($n)/log(10);
}
 
sub getdelay {
    my ($oidname, $n) = @_;
 
    if ( $oidname =~ /^if(:?HC)?(?:In|Out)/ ) {
	return 300 if ( !exists($setup{'helper'}{'ifSpeed'}{$n}) );
	my $speed = $setup{'helper'}{'ifSpeed'}{$n};
	my $type = $fieldtypes{$oidname}{$n};
	return 600 if ( $speed < 10**7 );
 
	if ( $type =~ /Counter(32|64)/i ) {
	    my $ival = int ((2**$1)/($speed/8));
	    return 300 if ( $ival > 300 || $ival < 30);
	    return int ($ival-10) if ( (0.1*$ival) < 10 );
	    return int ($ival*0.9);
	} else {
	    return 303;
	}
    }
    return 304 if ( $oidname =~ /^ifAdminStatus/ );
    return 120 if ( $oidname =~ /^ifOperStatus/ );
 
    return $delays{$oidname} if ( exists($delays{$oidname}) );
 
    return 305;
}
 
sub getunits {
    my ($oidname) = @_;
 
    return $units{$oidname} if ( exists($units{$oidname}) );
 
    return '';
}
 
sub getdelta {
    my ($oidname, $n) = @_;
 
    return '1' if ( $fieldtypes{$oidname}{$n} =~ /Counter/ );
#    return $deltas{$oidname} if ( exists($deltas{$oidname}) );
 
    return '0';
}
 
sub getmult {
    my ($oidname) = @_;
 
    return $mult{$oidname} if ( exists($mult{$oidname}) );
 
    return '';
}
 
sub getoidname {
    my ($oid) = @_;
 
    return $revoidmap{$oid};
 
    return '';
}
 
sub getoid {
    my ($oidname) = @_;
 
    foreach my $cat (%oids) {
	return $oids{$cat}{$oidname} if ( exists($oids{$cat}{$oidname}) );
    }
 
    return '';
}
 
# TR_DESCR
# TR_PRIO
# TR_EXPR
# mktrigger($descr, $prio, $expr);
sub mktrigger {
    my ($descr,$prio,$expr) = @_;
    my $tr = $templates{'trigger'};
 
    $tr =~ s/TR_DESCR/$descr/g;
    $tr =~ s/TR_PRIO/$prio/g;
    $tr =~ s/TR_EXPR/$expr/g;
 
    return $tr;
}
 
sub mkitem {
    my ($units, $key, $descr, $oid, $formula, $multiplier, $delta, $type, $vtype, $delay, $community) = @_;
 
    my $item = $templates{'item'};
 
    $item =~ s/IT_KEY/$key/g;
    $item =~ s/IT_UNITS/$units/g;
    $item =~ s/IT_DESCR/$descr/g;
    $item =~ s/IT_OID/$oid/g;
    $item =~ s/IT_FORMULA/$formula/g;
    $item =~ s/IT_MULTIPLIER/$multiplier/g;
    $item =~ s/IT_DELTA/$delta/g;
    $item =~ s/IT_TYPE/$type/g;
    $item =~ s/IT_VALUETYPE/$vtype/;
    $item =~ s/IT_DELAY/$delay/;
    $item =~ s/IT_COMMUNITY/$community/;
 
    return $item;
}
 
sub mkpingitem {
    my $item;
 
    $item = mkitem('', 'icmpping', 'ping', '', '', 0, 0, 3, 3, 300, '');
 
    return $item;
}
 
# IT_UNITS
# mksnmpitem($n, $oidname[, $mult])
sub mksnmpitem {
    my ($n, $oidname, $mmult) = @_;
    my ($oid, $mult, $units, $delta,
	$delay) = (getoid($oidname),getmult($oidname),
		   getunits($oidname), getdelta($oidname, $n),
		   getdelay($oidname,$n));
 
    my $itemtype=-1;
 
    if ( exists($forcedtypes{$oidname}) ) {
	$itemtype = $forcedtypes{$oidname};
    } elsif ( exists($fieldtypes{$oidname}{$n}) ) {
	$itemtype = $snmptypes{$fieldtypes{$oidname}{$n}};
    }
    push @delaystat, $delay;
 
    $mult = $mmult if ( $mmult != undef );
    my $usemult = ($mult eq '')?'0':'1';
 
    print "mksnmpitem: $oidname.$n($oid) M:$mult IT:$itemtype IV:$delay U:$units D:$delta\n";
 
    my $item = mkitem($units, $oidname.'.'.$n, $oidname.'.'.$n, $oid.'.'.$n,
		      $mult, $usemult, $delta, $snmpver{$args{'snmpver'}},
		      $itemtype, $delay, $community);
 
    return $item;
}
 
# GR_NAME
# GR_ELEMENTS
sub mkgraph {
    my ($name, $elements) = @_;
    my $g = $templates{'graph'};
 
    $g =~ s/GR_NAME/$name/g;
    $g =~ s/GR_ELEMENTS/$elements/g;
 
    $graph_order=0;
    $graph_colorindex=0;
 
 
    return $g;
}
 
# GE_TEMPLATE:GE_OIDN.NNN
# GE_DTYPE(drawtype) 1:fill 2:line
# GE_ORDER (auto)
# GE_COLOR (auto)
# mkgraphElement($oidname, $n, $drawtype)
sub mkgraphElement {
#    my ($templ,$oidn,$n,$dt) = @_;
    my ($oidn,$n,$dt) = @_;
    my $gi = $templates{'graphElement'};
 
    $gi =~ s/NNN/$n/g;
    $gi =~ s/GE_TEMPLATE/Template_$sysname/g;
    $gi =~ s/GE_OIDN/$oidn/g;
    $gi =~ s/GE_DTYPE/$dt/g;
    $gi =~ s/GE_ORDER/$graph_order/g;
    $gi =~ s/GE_COLOR/$graph_colors[$graph_colorindex]/g;
 
    ++$graph_order;
    ++$graph_colorindex;
 
    return $gi;
}
 
# makes a scheme trigger
# newtrigger($descr, oidname, severity, expression)
sub newtrigger {
    my ($descr, $oidname, $severity, $expr) = @_;
 
    foreach my $cat (keys %setup ) {
	next if ( ! exists($setup{$cat}{$oidname}) );
 
	foreach my $n (keys %{$setup{$cat}{$oidname}} ) {
	    my ($lexpr, $ldescr) = ($expr, $descr);
 
	    $lexpr =~ s/OIDNAME/$oidname/g;
	    $lexpr =~ s/NNN/$n/g;
	    $ldescr =~ s/NNN/$n/g;
 
	    $triggers .= mktrigger($ldescr, $severity, $lexpr);
	}
    }
 
}
 
open(IN, '<', $infile) || die "Unable to open $infile\n";
while(<IN>) {
    chomp;
    if ( /^hrStorageType.([0-9]+) = OID: (.*)$/ ) {
	if (grep(/$2/, @nostorage)) {
	    push @nodisks, $1;
	    next;
	}
    }
    if ( $sysname eq '' && /^(?:sysName|\Q.1.3.6.1.2.1.1.5\E).0 = STRING: (.*)$/) {
	$sysname = $1;
	$sysname =~ s/\"//g;
	next;
    }
    if ( /^hrStorageDescr.([0-9]+) = (STRING): (.*)$/ && !grep(/$1/, @nodisks) ) {
	$disks{$1}{'hrStorageDescr'} = $3;
	$features{'hrStorageDescr'}=1;
	$fieldtypes{'hrStorageDescr'}{$1}=$2;
	next;
    }
    if ( /^hrStorageAllocationUnits.([0-9]+) = (INTEGER): ([0-9]*) .*$/ && !grep(/$1/, @nodisks) ) {
	$disks{$1}{'hrStorageAllocationUnits'} = $3;
	$features{'hrStorageAllocationUnits'}=1;
	$fieldtypes{'hrStorageAllocationUnits'}{$1}=$2;
	next;
    }
    if ( /^hrStorageSize.([0-9]+) = (INTEGER): (.*)$/ && !grep(/$1/, @nodisks) ) {
	$disks{$1}{'hrStorageSize'} = $3;
	$features{'hrStorageSize'}=1;
	$fieldtypes{'hrStorageSize'}{$1}=$2;
	next;
    }
    if ( /^hrStorageUsed.([0-9]+) = (INTEGER): (.*)$/ && !grep(/$1/, @nodisks) ) {
	$disks{$1}{'hrStorageUsed'} = $3;
	$features{'hrStorageUsed'}=1;
	$fieldtypes{'hrStorageUsed'}{$1}=$2;
	next;
    }
    foreach my $cat (keys %oids) {
	my $f=0;
	foreach my $k (keys %{$oids{$cat}}) {
	    my $oid = $oids{$cat}{$k};
	    if (  /^(?:\Q$k\E|\Q.$oid\E).([0-9]+) = ([A-Za-z]+[0-9]*): (.*)$/ ) {
		my ($n, $type, $val) = ($1, $2, $3);
		$val =~ s/\"//g if ( $type eq 'STRING' );
		$setup{$cat}{$k}{$n} = $val;
		$itemlist{$k}{$n} = $val;
		$features{$k}=1;
		$fieldtypes{$k}{$n}=$type;
		$f=1;
		last;
	    }
	}
	last if ( $f==1 );
    }
}
close(IN);
 
# helper oids
if ( 0 ) {
    my $cat = 'helper';
    foreach my $o (keys %{$setup{$cat}}) {
	print "$cat/$o\n";
	foreach my $n (keys %{$setup{$cat}{$o}}) {
	    print "$cat/$o/$n=$setup{$cat}{$o}{$n}\n";
	}
    }
    exit;
}
 
if ( $sysname eq '' ) {
    print "sysName.0 was not found, enter system name: ";
    $sysname = <STDIN>;
    chomp $sysname;
}
$sysname =~ s/[^a-z0-9]/_/gi;
 
 
$features{'ifstat'}=1 if ( $features{'ifDescr'}==1 );
$features{'ifstatus'}=1 if ( $features{'ifOperStatus'}==1 && $features{'ifAdminStatus'}==1 );
$features{'storage'}=1 if ( $features{'hrStorageDescr'}==1 &&
			    $features{'hrStorageAllocationUnits'}==1 &&
			    $features{'hrStorageSize'}==1 &&
			    $features{'hrStorageUsed'}==1 );
#
# make all the items
#
$items .= mkpingitem();
$triggers .= mktrigger('Host unreachable', 1, '{{HOSTNAME}:icmpping.last(0)}#1');
print "Making items...\n";
foreach my $cat (keys %setup) {
    next if ( exists($nofeatures{$cat}) );
    foreach my $name (keys %{$setup{$cat}}) {
	next if ( exists($noitem{$name}) );
	foreach my $id (keys %{$setup{$cat}{$name}}) {
	    my $effname = getreplacement($name, $id);
	    $items .= mksnmpitem($id, $effname);
	}
    }
}
 
#
# make all the graphs
#
# %graphdefs{graph}{items[n]}{0/1}
print "Making graphs...\n";
if (0) {
    # all graphs
    foreach my $gr (keys %graphdefs) {
	# check the required OIDs whether they exist
	my @gilist; # Graph Items List
	my $gisok=1; # Graph Items OK
 
	foreach my $oid (keys %{$graphdefs{$gr}}) {
	    my $roid = getreplacement($oid); # replacement oid
 
	    push @gilist, ($roid) if ( exists($itemlist{$roid}) );
	    $gisok = 0 if ( $graphdefs{$gr}{$oid}!=1 && !exists($itemlist{$roid}) );
	}
	next if ( $gisok==1 );
 
    }
}
 
#
# per-type stuff
#
 
print "Doing interface graphs and triggers\n";
# interface stuff
foreach my $k (keys %{$setup{'ifTraffic'}{'ifDescr'}} ) {
    my ($descr, $alias) = ($setup{'ifTraffic'}{'ifDescr'}{$k},
			   $setup{'ifTraffic'}{'ifAlias'}{$k});
 
    $descr = ($alias eq '')?$descr:$descr.' - '.$alias;
 
    if ( $features{'ifstat'}==1 && $args{'noifstat'}!=1 ) {
	my ($gi, $dt) = ('',1);
	for my $oidname (('ifInOctets','ifOutOctets')) {
	    my $effname = getreplacement($oidname, $k);
	    $gi .= mkgraphElement($effname,$k,$dt++);
	}
	$graphs .= mkgraph($descr.' bps', $gi);
	$gi = '';
	print "Making grah $descr pps\n";
	for my $oidname (('ifInUcastPkts','ifInNUcastPkts','ifOutUcastPkts','ifOutNUcastPkts',
			  'ifInMulticastPkts','ifInBroadcastPkts','ifOutMulticastPkts','ifOutBroadcastPkts')) {
	    my $effname = getreplacement($oidname, $k);
	    print " - $oidname -> $effname $k\n";
	    next unless ( exists($setup{'ifTraffic'}{$effname}{$k}) ||
			  exists($setup{'replacement'}{$effname}{$k}) );
	    print "  - adding $effname\n";
	    $gi .= mkgraphElement($effname,$k,2);
	}
	$graphs .= mkgraph($descr.' pps', $gi);
    }
    if ( $features{'ifstatus'}==1 && $args{'noifstatus'}!=1 ) {
	my $trn = "Link down on $descr";
	$triggers .= mktrigger($trn ,2,
			       '({{HOSTNAME}:ifOperStatus.'.$k.'.last(0)}=2)&amp;({{HOSTNAME}:ifAdminStatus.'.$k.'.last(0)}=1)');
    }
}
 
# ups graphs
foreach my $oidname (keys %{$setup{'upsGraph'}}) {
    my $ge = '';
    foreach my $k (keys %{$setup{'upsGraph'}{$oidname}}) {
	$ge .= mkgraphElement($oidname, $k, 2);
    }
    $graphs .= mkgraph($oidname, $ge);
}
 
# ups triggers
foreach my $oidname (keys %{$setup{'ups'}}) {
    foreach my $k (keys %{$setup{'ups'}{$oidname}}) {
	print "$oidname.$k=".$setup{'ups'}{$oidname}{$k}."\n";
	$triggers .= mktrigger("$oidname.$k", 3, "({{HOSTNAME}:$oidname.$k.last(0)}#0)");
    }
}
 
# SA Scientific Atlanta triggers
# mktrigger($descr, $prio, $expr);
# Check against !=1
foreach my $oidname ( ('saCaAuthorized') ) {
    if ( exists($setup{'saRcv'}{$oidname}) ) {
	foreach my $n (keys %{$setup{'saRcv'}{$oidname}}) {
	    $triggers .= mktrigger("CA Authorization failure on $n", 4, "({{HOSTNAME}:$oidname.$n.last(0)}#1)");
	}
    }
}
# bitrate check
if ( exists($setup{'saRcv'}{'saVideoBitrate'}) ) {
    my $oidname = 'saVideoBitrate';
    foreach my $n (keys %{$setup{'saRcv'}{'saVideoBitrate'}}) {
	    $triggers .= mktrigger("Bitrate underflow on $n", 4, "({{HOSTNAME}:$oidname.$n.last(0)}&lt;1)");
    }
}
# signal lock checks
if ( exists($setup{'saRcv'}{'saFeCurrentInput'}) ) {
    $triggers .= mktrigger('ASI Signal unlocked', 4, '({{HOSTNAME}:saFeCurrentInput.1.last(0)}=1)&amp;'.
			   '({{HOSTNAME}:saTuningAsiSignalLocked.0.last(0)}#2)');
    $triggers .= mktrigger('RF Signal unlocked', 4, '({{HOSTNAME}:saFeCurrentInput.1.last(0)}&gt;1)&amp;'.
			   '({{HOSTNAME}:saFeSignalState.1.str(Yes)}=0)');
}
# Authorization checks
if ( exists($setup{'saRcv'}{'saMainPeAuthState'}) ) {
    $triggers .= mktrigger('Authorization state failed', 4, '({{HOSTNAME}:saMainPeAuthState.1.last(0)}#4)');
}
 
#
# GYDA ChangeOver
#
#		'choSignalInput1'=>'1.3.6.1.4.1.8768.1.3.8.2.1.4',
#		'choSignalInput2'=>'1.3.6.1.4.1.8768.1.3.8.2.1.5',
#		'choLock'=>'1.3.6.1.4.1.8768.1.3.8.2.1.3',
#		'choState'=>'1.3.6.1.4.1.8768.1.3.8.2.1.9',
#		'moduleLabel.gyda.1'=>'1.3.6.1.4.1.8768.1.4.5.1.1.4.2.1',
#		'moduleStatus.gyda.1'=>'1.3.6.1.4.1.8768.1.4.5.1.1.3.2.1',
{
    # gyda modules
    foreach my $nn (keys %{$setup{'helper'}{'moduleStatus.gyda.1'}} ) {
	my $n = $nn+1;
	my $val = $setup{'helper'}{'moduleStatus.gyda.1'}{$nn};
	$val =~ s/^[a-z]+\(([0-9])\)/\1/;
	next if ( $val ne '1' );
 
	my $name = $setup{'helper'}{'moduleLabel.gyda.1'}{$nn};
	$name =~ s/^\"(.*)\"$/\1/;
 
	if ( exists($setup{'gyda'}{'choSignalInput1'}{$n}) ) {
	    $triggers .= mktrigger('Input 1 lost on '.$name, 2, "({{HOSTNAME}:choSignalInput1.$n.last(0)}#1)");
	}
	if ( exists($setup{'gyda'}{'choSignalInput2'}{$n}) ) {
	    $triggers .= mktrigger('Input 2 lost on '.$name, 2, "({{HOSTNAME}:choSignalInput2.$n.last(0)}#1)");
	}
	if ( exists($setup{'gyda'}{'choLock'}{$n}) ) {
	    $triggers .= mktrigger('Reclocker lock lost on '.$name, 5, "({{HOSTNAME}:choLock.$n.last(0)}#1)");
	}
    }
}
 
 
#foreach my $f (keys %features) {
#    print "$f: ".$features{$f}."\n";
#}
# storage stuff
if ( $features{'storage'}==1 ) {
 
    foreach my $diskid (keys %disks) {
	my ($au, $descr) = ($disks{$diskid}{'hrStorageAllocationUnits'},$disks{$diskid}{'hrStorageDescr'});
	my ($gi,$dt) = ('',0);
	print "au: '$au'\n";
	foreach my $oidn (('hrStorageSize','hrStorageUsed')) {
	    print "$diskid $oidn\n";
	    $items .= mksnmpitem($diskid, $oidn, $au);
	    $gi .= mkgraphElement($oidn, $diskid, $dt++);
	}
	$graphs .= mkgraph($descr, $gi);
    }
}
 
#
# HP System Health status
#
{
    newtrigger('CPU NNN failure', 'cpqSeCpuStatus', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('Mem ECC NNN failure', 'cpqSiMemModuleECCStatus.0', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('Board NNN failure', 'cpqDaCntlrBoardStatus', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('Board NNN failure', 'cpqDaCntlrBoardCondition', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('ArrayBattery NNN failure', 'cpqDaAccelBattery', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)&amp;'.
	       '({{HOSTNAME}:OIDNAME.NNN.last(0)}#6)');
    newtrigger('Logical drive NNN failure', 'cpqDaLogDrvStatus.5', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('Phyiscal drive NNN failure', 'cpqDaPhyDrvStatus.5', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('PhyDrv SMART NNN failure', 'cpqDaPhyDrvSmartStatus.5', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('Thermal NNN failure', 'cpqHeThermalTempStatus', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('Fan NNN failure', 'cpqHeThermalSystemFanStatus', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('CPU fan NNN failure', 'cpqHeThermalCpuFanStatus', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    newtrigger('PSU failure', 'cpqHeFltTolPwrSupplyCondition', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;2)');
    if ( exists($setup{'hphealth'}{'cpqHeFltTolPowerSupplyPresent.0'}) &&
	 exists($setup{'hphealth'}{'cpqHeFltTolPowerSupplyCondition.0'}) ) {
	foreach my $n (keys %{$setup{'hphealth'}{'cpqHeFltTolPowerSupplyPresent.0'}}) {
	    $triggers = mktrigger("Fan $n failure", 4, "({{HOSTNAME}:cpqHeFltTolPowerSupplyPresent.0.$n.last(0)}=3)&amp;".
				  "({{HOSTNAME}:cpqHeFltTolPowerSupplyCondition.0.$n.last(0)}#1)");
	}
    }
    newtrigger('Memory module NNN failure', 'cpqHeResMemModuleStatus.0', 4, '({{HOSTNAME}:OIDNAME.NNN.last(0)}&gt;4)');
    # graphs / temperature
    my $gi;
    my %tmpsnridx = (
		     '1'=>'other',
		     '2'=>'unknown',
		     '3'=>'system',
		     '4'=>'systemBoard',
		     '5'=>'ioBoard',
		     '6'=>'cpu',
		     '7'=>'memory',
		     '8'=>'storage',
		     '9'=>'removableMedia',
		     '10'=>'powerSupply',
		     '11'=>'ambient',
		     '12'=>'chassis',
		     '13'=>'bridgeCard',
		     );
    if ( exists($setup{'hphealth'}{'cpqHeTemperatureCelsius.1'}) ) {
	foreach my $n (keys %{$setup{'hphealth'}{'cpqHeTemperatureCelsius.1'}}) {
	    $gi .= mkgraphElement('cpqHeTemperatureCelsius.1', $n, 2);
	}
	$graphs .= mkgraph('Temperatures', $gi);
    }
    $gi = '';
    if ( exists($setup{'hpdriveperf'}{'cpqDaPhyDrvReads.5'}) &&
	 exists($setup{'hpdriveperf'}{'cpqDaPhyDrvWrites.5'}) ) {
	foreach my $n (keys %{$setup{'hpdriveperf'}{'cpqDaPhyDrvReads.5'}}) {
	    $gi = mkgraphElement('cpqDaPhyDrvReads.5', $n, 2);
	    $gi .= mkgraphElement('cpqDaPhyDrvWrites.5', $n, 2);
	    $graphs .= mkgraph("Disk $n read/write", $gi);
	}
    }
}
#
# NewTec Modulators
#
#		'ntcDevsMod01MoOutputLevel.1.1'=>'1.3.6.1.4.1.5835.3.1.3.1.29.1.1',
#		'ntcDevsMod01MoTxStatus.1'=>'1.3.6.1.4.1.5835.3.1.3.1.37.1',
#		'ntcDevsMod01MoPacketRate.1'=>'1.3.6.1.4.1.5835.3.1.3.1.79.1',
#		'ntcDevsMod01AlAlarmsCur.0'=>'1.3.6.1.4.1.5835.3.1.2.1.9.0',
# mkgraphElement($oidname, $n, $drawtype)
#	$graphs .= mkgraph($descr, $gi);
# newtrigger($descr, oidname, severity, expression)
# mktrigger($descr, $prio, $expr);
#	    $triggers .= mktrigger('Reclocker lock lost on '.$name, 5, "({{HOSTNAME}:choLock.$n.last(0)}#1)");
{
    my $gi='';
    my $oidname='ntcDevsMod01MoOutputLevel.1.1';
    my $cat='ntcmod';
    if ( exists($setup{$cat}{$oidname}) ) {
	foreach my $n (keys %{$setup{'ntcmod'}{$oidname}}) {
	    print "adding $oidname.$n to graph\n";
	    $gi .= mkgraphElement($oidname, $n, 2);
	}
	$graphs .= mkgraph('Output Power Level', $gi);
	$gi = '';
    }
 
    $oidname = 'ntcDevsMod01MoTxStatus.1';
    if ( exists($setup{$cat}{$oidname}) ) {
	newtrigger('TX Status failure', 'ntcDevsMod01MoTxStatus.1', 5, '({{HOSTNAME}:OIDNAME.NNN.last(0)}#1)');
    }
    $oidname = 'ntcDevsMod01MoPacketRate.1';
    if ( exists($setup{$cat}{$oidname}) ) {
	$gi = mkgraphElement($oidname, 1, 2);
	$graphs .= mkgraph('Packet Rate', $gi);
	$gi = '';
    }
 
    $oidname = 'ntcDevsMod01AlAlarmsCur.0';
    if ( exists($setup{$cat}{$oidname}) ) {
	my %alarmbits = (
			 '1'=>'Device reset flag',
			 '2'=>'Self test',
			 '3'=>'Incompatibility',
			 '4'=>'General device',
			 '5'=>'Interface',
			 '6'=>'Reference clock',
			 '7'=>'Device temperature',
			 '8'=>'Power supply voltage',
			 '9'=>'Input framing',
			 '10'=>'ASI code violations',
			 '11'=>'ASI opt. sig. det.',
			 '12'=>'LVDS signal detect',
			 '13'=>'NCR inserter GPS 1pps',
			 '14'=>'Baseband frame sync',
			 '15'=>'Buffer underflow',
			 '16'=>'Buffer overflow',
			 '17'=>'Clock PLL',
			 '18'=>'Synthesiser',
			 '19'=>'RF phase lock DRO',
			 '20'=>'BISS summary',
			 '21'=>'Internal MC module',
			 '22'=>'Interface module',
			 '23'=>'Internal modulator',
			 );
# newtrigger($descr, oidname, severity, expression)
	foreach my $k (keys %alarmbits) {
	    my ($descr, $dots) = ($alarmbits{$k}, '');
	    for (my $i=1; $i<$k; ++$i) {
		$dots .= '.';
	    }
	    newtrigger($descr, $oidname, 4, "({{HOSTNAME}:OIDNAME.NNN.regexp(^${dots}1)}=1)");
	}
    }
}
 
#
## FreeBSD pf
#
# 'pfStateTableCount'=>'1.3.6.1.4.1.12325.1.200.1.3.1',
# 'pfStateTableSearches'=>'1.3.6.1.4.1.12325.1.200.1.3.2',
# 'pfStateTableInserts'=>'1.3.6.1.4.1.12325.1.200.1.3.3',
# 'pfStateTableRemovals'=>'1.3.6.1.4.1.12325.1.200.1.3.4',
# 'pfLimitsStates'=>'1.3.6.1.4.1.12325.1.200.1.5.1',
#{
#    if ( exists($setup{$cat}{$oidname}) ) {
#	foreach my $n (keys %{$setup{'ntcmod'}{$oidname}}) {
#	    print "adding $oidname.$n to graph\n";
#	    $gi .= mkgraphElement($oidname, $n, 2);
#	}
#	$graphs .= mkgraph('Output Power Level', $gi);
#	$gi = '';
#    }
#}
 
 
open(OUT, '>', $outfile) || die "Unable to open $outfile\n";
print OUT '<?xml version="1.0"?>
<zabbix_export version="1.0" date="27.04.09" time="14.23">
	<hosts>
		<host name="Template_'.$sysname.'">
			<useip>0</useip>
			<dns></dns>
			<ip>0.0.0.0</ip>
			<port>10050</port>
			<status>3</status>
			<groups>
				<group>Templates</group>
			</groups>
			<items>
'.$items.'
			</items>
                        <triggers>
'.$triggers.'
                        </triggers>
			<graphs>
'.$graphs.'
			</graphs>
		</host>
	</hosts>
</zabbix_export>
';
close(OUT);
 
my $totaldelays=0;
foreach my $d (@delaystat) {
    $totaldelays += $d;
}
my $nodelays = @delaystat;
print "Avarage delay: ".($totaldelays/$nodelays)."\n" if ( $nodelays > 0 );