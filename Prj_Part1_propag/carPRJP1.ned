package Prj_Part1_propag;

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
import inet.linklayer.loopback.LoopbackInterface;

module carPRJP1
{
    parameters:
        @node();
        @labels(node,ethernet-node,wireless-node);
        **.interfaceTableModule = default(absPath(".interfaceTable"));
        **.routingTableModule = default(absPath(".routingTable"));
        **.icmpModule = default(absPath(".networkLayer.icmp"));
        **.arpModule = default(absPath(".networkLayer.arp"));

        string routingProtocol @enum("AODVUU","DYMOUM","DYMO","DSRUU","OLSR","OLSR_ETX","DSDV_2","Batman") = default("");  // used mobile routing protocol. see: inet.networklayer.manetrouting

        @display("bgb=379,536");
    gates:
        input radioIn @directIn;

    submodules:
        //        app: TraCIDemo11p {
        app: UDPBasicBurst {
            parameters:
                @display("p=304,62");
        }

        udp: UDP {
            parameters:
                @display("p=304,172");
        }

        networkLayer: IPv4NetworkLayer {
            parameters:
                //proxyARP = false;
                @display("p=304,327;q=queue");
            gates:
                ifIn[1];
                ifOut[1];
        }

        manetrouting: <routingProtocol> like IManetRouting if routingProtocol != "" {
            @display("p=109,199");
        }

        interfaceTable: InterfaceTable {
            parameters:
                @display("p=160,345");
        }

        routingTable: IPv4RoutingTable {
            parameters:
                forwarding = true;
                //                routerId = "";
                routingFile = "";
                @display("p=60,326");
        }

        ac_wlan: HostAutoConfigurator {
            @display("p=296,402");
        }

        mobility: TraCIMobility {
            parameters:
                @display("p=60,459");
        }

        wlan: Ieee80211Nic {
            parameters:
                @display("p=304,461;q=queue");
                mgmtType = "Ieee80211MgmtAdhoc";  // use adhoc management
        }

        lo0: LoopbackInterface {
            @display("p=184,459");
        }

    connections allowunconnected:
        udp.appOut++ --> app.udpIn;
        udp.appIn++ <-- app.udpOut;

        udp.ipOut --> networkLayer.transportIn++;
        udp.ipIn <-- networkLayer.transportOut++;

        networkLayer.transportOut++ --> manetrouting.from_ip if routingProtocol != "";
        networkLayer.transportIn++ <-- manetrouting.to_ip if routingProtocol != "";

        wlan.upperLayerOut --> networkLayer.ifIn++;
        wlan.upperLayerIn <-- networkLayer.ifOut++;
        
        lo0.upperLayerIn <-- networkLayer.ifOut++;
        lo0.upperLayerOut --> networkLayer.ifIn++;

        radioIn --> wlan.radioIn;
}
