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

1.) Why don't you include EPIC games?
  Currently we can not cache EPIC games as they distribute all files over HTTPS, Without distributing self-signed certificates to all hosts on the LAN, this will not be possible to cache at this time. Please pester EPIC Games to allow caching of their games services.

2.) I ran out of disk space, What should I do?
  Either delete some of the cache data, or put the caching services on a bigger disk

3.) The cache seems slow.
  If the cache seems slow, Check that you have enough memory on the system, The more memory you have the faster the cache will run as the caching system will cache data in to RAM. The cache can only deliver files as fast as it can read them from either the internet (if they're not yet cached) or from the disk if they are cached. Using faster disks/SSD can greatly improve the performance of the cache.

## Supported services
We are working on adding services to our caching system all the time, Currently the list of supported networks are:
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

[1]: Twitch have since moved to HTTPS for their streams, so some of this content will not be cached
