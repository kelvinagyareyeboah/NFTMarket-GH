// SPDX-
   * @n
   * @param _address           The ad
   * @param _proxyForAddress  The proxy that will act on beh
  setProxy(address _address, address _proxyFo
      external
      onlyOwner()
  {
      proxies[_address] = _proxyForAddress;
  }
}
