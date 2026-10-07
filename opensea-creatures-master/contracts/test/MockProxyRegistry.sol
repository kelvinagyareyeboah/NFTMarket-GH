
   * @n
   * @param _add
   * @param _proxyForAddress  The proxy that w
  setProxy(address _address, address _proxyFo
      ex
      onlyOwner()
  {
      proxies[_address] = _proxyForAddress;
  }
}
