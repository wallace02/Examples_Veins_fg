package Prj_Part1_propag.AODV;

//import inet.applications.traci.TraCIDemo;
import inet.linklayer.ieee80211.Ieee80211Nic;
import inet.networklayer.common.InterfaceTable;
import org.car2x.veins.modules.mobility.traci.TraCIMobility;
import org.car2x.veins.modules.application.traci.TraCIDemo11p;

import inet.networklayer.configurator.ipv4.HostAutoConfigurator;
import inet.networklayer.ipv4.IPv4NetworkLayer;
import inet.networklayer.ipv4.IPv4RoutingTable;
import inet.transportlayer.udp.UDP;
import inet.applications.udpapp.UDPBasicBurst;
import inet.networklayer.contract.IManetRouting;
import inet.routing.aodv.AODVRouting;
import inet.linklayer.loopback.LoopbackInterface;

module carAODV
{
    parameters:
        @node();
        @networkNode();
        @labels(node,ethernet-node,wireless-node);
        **.interfaceTableModule = default(absPath(".interfaceTable"));
        **.routingTableModule = default(absPath(".routingTable"));
        **.networkProtocolModule = default(absPath(".networkLayer.ip"));
        **.icmpModule = default(absPath(".networkLayer.icmp"));
        **.arpModule = default(absPath(".networkLayer.arp"));
        //**.networkConfiguratorModule = default(absPath(".configurator"));
        int numRadios = default(1);


        @display("bgb=370,536");
    gates:
        input radioIn[numRadios] @directIn;

    submodules:
        //        app: TraCIDemo11p {
        app: UDPBasicBurst {
            parameters:
                @display("p=313,53");
        }

        udp: UDP {
            parameters:
                @display("p=313,160");
        }

        networkLayer: IPv4NetworkLayer {
            parameters:
                proxyARP = true;
                @display("p=304,327;q=queue");
            gates:
                ifIn[1];
                ifOut[1];
        }

        aodv: AODVRouting {
            @display("p=155,160");
        }

        interfaceTable: InterfaceTable {
            parameters:
                @display("p=155,345");
        }

        routingTable: IPv4RoutingTable {
            parameters:
                forwarding = true;
                //routerId = "";
                routingFile = "";
                @display("p=60,315");
        }

        ac_wlan: HostAutoConfigurator {
            @display("p=60,390");
            interfaces = "wlan0";
        }

        mobility: TraCIMobility {
            parameters:
                @display("p=60,459");
        }

        wlan[numRadios]: Ieee80211Nic {
            parameters:
                @display("p=304,461,row,60;q=queue");
                mgmtType = "Ieee80211MgmtAdhoc";  // use adhoc management
                //radio.radioMediumModule = default(absPath(".radioMedium"));
                //**.mobilityModule = default(absPath(".mobility"));
        }

        lo0: LoopbackInterface {
            @display("p=167,461");
        }

    connections allowunconnected:
        udp.appOut++ --> app.udpIn;
        udp.appIn++ <-- app.udpOut;

        udp.ipOut --> networkLayer.transportIn++;
        udp.ipIn <-- networkLayer.transportOut++;

        networkLayer.transportOut++ --> aodv.ipIn;
        networkLayer.transportIn++ <-- aodv.ipOut;
        
        networkLayer.ifOut++ --> lo0.upperLayerIn;
        lo0.upperLayerOut --> networkLayer.ifIn++;

        for i=0..sizeof(radioIn)-1 {
            radioIn[i] --> { @display("m=s"); } --> wlan[i].radioIn;
            wlan[i].upperLayerOut --> networkLayer.ifIn++;
            wlan[i].upperLayerIn <-- networkLayer.ifOut++;
        }
}
