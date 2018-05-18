### Dependencies

* lua (>= 5.1)
* lua-ssllabs

### Installation

If not already installed, the package manager [luarocks](https://luarocks.org) is needed and the package `build-essentials`, because [lua-ssllabs](https://luarocks.org/modules/imolein/lua-ssllabs) used [lua-requests](https://luarocks.org/modules/jakeg/lua-requests), which depends on [lua-cjson](https://luarocks.org/modules/openresty/lua-cjson) which is written in C und needs to be compiled, which luarocks do during the installation process.

Install `lua-cjson` first, because the newest version is [buggy](https://github.com/mpx/lua-cjson/issues/56), so you have to install a specific version: `luarocks install lua-cjson 2.1.0-1`. After this you can install `lua-ssllabs` as follows: `luarocks install lua-ssllabs`.