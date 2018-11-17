This docker container provides a caching proxy server for game download content. For any network with more than one PC gamer in connected this will drastically reduce internet bandwidth consumption.
The primary use case is gaming events, such as LAN parties, which need to be able to cope with hundreds or thousands of computers receiving an unannounced patch - without spending a fortune on internet connectivity. Other uses include smaller networks, such as Internet Cafes and home networks, where the new games are regularly installed on multiple computers; or multiple independent operating systems on the same computer.
This container is designed to support any game that uses HTTP and also supports HTTP range requests (used by Origin). This should make it suitable for:
* Steam (Valve)
* Origin (EA Games)
* Riot Games (League of Legends)
* Battle.net (Hearthstone, Starcraft 2, Overwatch)
* Frontier Launchpad (Elite Dangerous, Planet Coaster)
* Uplay (Ubisoft)
* Windows Updates
This is the best container to use for all game caching and should be used for Steam in preference to the steamcache/steamcache container.
