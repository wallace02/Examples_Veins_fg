package inetConM2;

import inet.applications.traci.TraCIDemo;
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
import inet.routing.dymo.DYMO;

module carCM2Dymo
{
    parameters:
        @node();
        @node();
        @labels(node,ethernet-node,wireless-node);
        **.interfaceTableModule = default(absPath(".interfaceTable"));
        **.routingTableModule = default(absPath(".routingTable"));
        **.networkProtocolModule = default(absPath(".networkLayer.ip"));
        **.icmpModule = default(absPath(".networkLayer.icmp"));

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
                proxyARP = false;
                @display("p=304,327;q=queue");
            gates:
                ifIn[1];
                ifOut[1];
        }

        dymo: DYMO {
            @display("p=155,160");
            interfaces = "wlan0";
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
        }

    connections allowunconnected:
        udp.appOut++ --> app.udpIn;
        udp.appIn++ <-- app.udpOut;

        udp.ipOut --> networkLayer.transportIn++;
        udp.ipIn <-- networkLayer.transportOut++;

        dymo.ipOut --> networkLayer.transportIn++;
        dymo.ipIn <-- networkLayer.transportOut++;

        for i=0..sizeof(radioIn)-1 {
            radioIn[i] --> { @display("m=s"); } --> wlan[i].radioIn;
            wlan[i].upperLayerOut --> networkLayer.ifIn++;
            wlan[i].upperLayerIn <-- networkLayer.ifOut++;
        }
}
