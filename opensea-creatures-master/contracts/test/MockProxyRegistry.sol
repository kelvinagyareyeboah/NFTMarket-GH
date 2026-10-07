// SPDX-License-Identi
 '@openzeppelin/contracts
 * @dev A simple mock ProxyRegistr
  /********
  |  Public Conf
  |_________
  /**
   * @notice Aner to set a proxy for testing
   * @param _address           The address that the proxy will act on behalf of
   * @param _proxyForAddress  The proxy that will act on behalf of the address
  setProxy(address _address, address _proxyForAddress)
      external
      onlyOwner()
  {
      proxies[_address] = _proxyForAddress;
  }
}
