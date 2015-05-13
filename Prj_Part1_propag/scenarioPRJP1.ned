package Prj_Part1_propag;

import inet.physicallayer.ieee80211.packetlevel.Ieee80211ScalarRadioMedium;
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import org.car2x.veins.modules.mobility.traci.TraCIScenarioManagerLaunchd;

network scenarioPRJP1
{
    submodules:
        radioMedium: Ieee80211ScalarRadioMedium {
            parameters:
                @display("p=351,58");
        }

        manager: TraCIScenarioManagerLaunchd {
            @display("p=146,47");
        }

        configurator: IPv4NetworkConfigurator {
            parameters:
            	@display("p=42,111");
            	config = xml("<config><interface hosts='*' address='10.x.x.x' netmask='255.x.x.x'/></config>");
        }
}
