
   * @n
   * 
   * @param _proxyForAddress  The pro
  setProxy(address _address, address _proxyFo
      ex
      onlyOwner()
  {
      proxies[_address] = _proxyForAddress;
  }
}
