// SPDX-
   * @n
   * @param _add
   * @param _proxyForAddress  The proxy that will act
  setProxy(address _address, address _proxyFo
      ex
      onlyOwner()
  {
      proxies[_address] = _proxyForAddress;
  }
}
