### Dependencies

* lua (>= 5.1)
* [lua-ssllabs](https://github.com/imolein/lua-ssllabs) (>= 0.2-0)

### Installation

#### Manual

* Install lua
* Install [luarocks](https://github.com/luarocks/luarocks/wiki/Documentation#Quick_start) (You need luarocks >=3.0.0)
* Install lua-ssllabs: `luarocks install lua-ssllabs`
* Download this script: `wget -P /etc/zabbix/externalscripts/ https://raw.githubusercontent.com/zabbix-deb/debs/master/externalscripts/zabbix-check-ssllabs/zabbix-check-ssllabs.lua`

### Usage

* To check a host, run `lua zabbix-check-ssllabs.lua -h example.com`
   * It returns the grade if it is found in the local cache file. If it is not found and not cached by ssllabs, it returns "NA". In case of error it return "ERR".
* You can add a cronjob, which runs the script on daily basis with the update option `-u`: `lua zabbix-check-ssllabs.lua -u`
   * This will start new assessments for every host in the cache file. Depending on how many hosts you have to check, it will run some time.

*Note:* If the given host has multiple endpoints, the worst grade of all endpoints is returned. For example: IPv4 endpoint has a grade of "A+" and IPv6 endpoint a grade of "A-", the script returns "A-"

### How it work

#### zabbix-check-ssllabs.lua -h example.com

* The cache file is looked up for the host
* If host is found and has a grade as value, it returns the grade
* If host is not found or has no grade as value, the test results from ssl-labs cache with a `maxAge=48h` is requested
   * Don't be suprised if a new test is started, even though you started one a day or a few hours ago. The backend routing of ssl-labs seems a bit bogus. It is possible to invoke three different tests with `fromCache=on` from one IP address within a few minutes. First I thought I did something wrong, but I could reproduce it with curl, from different systems with different internet connections.
* If there is not cached result and a new assessment is started, "NA" is returned and the host is written to the cache file with an empty grade
* If something went wrong during the assessment, "ERR" is returned

#### zabbix-check-ssllabs.lua -u

* For every host in the cache file, an assessment is started
* If there are more than 5 hosts in your cache file, only 5 assessments get started at once
* Every 20s it checks the status of the assessment and if one is ready, the grade is saved and a next assessment is started
* If all assessments are done the cache file is renewed

### TODO

* maybe make some stuff configurable, like the seconds between the status checks, the maxAge and the location of cache file
* make a debian package
   * but I guess I have to package lua-requests and it's dependencies too, which shouldn't be that hard