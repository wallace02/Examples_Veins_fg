package inetConM2;

import inet.physicallayer.ieee80211.packetlevel.Ieee80211ScalarRadioMedium;
import inet.networklayer.configurator.ipv4.IPv4NetworkConfigurator;
import org.car2x.veins.modules.mobility.traci.TraCIScenarioManagerLaunchd;

network scenarioCM2
{
    submodules:
        radioMedium: Ieee80211ScalarRadioMedium {
            @display("p=351,58");
        }

        manager: TraCIScenarioManagerLaunchd {
            @display("p=146,47");
        }

        configurator: IPv4NetworkConfigurator {
            @display("p=42,111");
        }
}
