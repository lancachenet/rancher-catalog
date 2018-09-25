# LAN Cache

Full-stack Lan Caching for gaming

## About this stack

This stack will configure a full LAN cache for your network or LAN event, Each caching server will require a unique IP Address on either the same host or on multiple hosts. The DNS container will take care of sending the DNS Queries to the correct container and the SNI-Proxy will allow HTTPS to bypass the caching altogether.

## Configuration

* Each caching service requires it's own caching directory.
* Port 80(tcp) and 53(udp) are required
* A [SNI-Proxy](https://github.com/steamcache/sniproxy) is required to allow HTTPS traffic through

### Steam caching
There are 3 types of caching for steam, Currently only 2 are implemented in this repository.

1.) steamcache - This is the default for Steam, this caches the depot contents of the downloads in the same way as CDNs cache the data.

2.) generic - This is a general cache, This is what's used for all other caches, This is a simple proxy cache.

3.) steamcache-site-licence - This is not yet implemented in this repository, This uses Valves own site licence system for caching and includes p2p downloading from clients on the network. For more details on this look here: https://support.steampowered.com/kb_article.php?ref=3303-QWRC-3436

## More information

This Rancher catalogue is currently a work in progress, Please report all issues to https://github.com/steamcache/rancher-catalogue

## FAQ

See here: https://github.com/steamcache/generic/blob/master/faq.md

## Supported services
Supported services are all services listed over at https://github.com/uklans/cache-domains
The current list of supported servers at the time of writing is:
* apple
* arenanet
* blizzard
* daybreak
* frontier
* gog
* hirez
* minecraft
* nexusmods
* nintendo
* origin
* riot
* rockstar
* sony
* steam
* uplay
* twitch[1]
* wargaming
* wsus
* xboxlive

[1]: Twitch is for items that twitch supply rather than the streams. This is due to twitch moving their streams over to HTTPS, we can therefor not cache twitch streams.
