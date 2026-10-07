// SPDX-
   * @n
   * @param _address           The address that the proxy will act  of
   * @param _proxyForAddress  The proxy that will act on behalf of the address
  setProxy(address _address, address _proxyForAddress)
      external
      onlyOwner()
  {
      proxies[_address] = _proxyForAddress;
  }
}
