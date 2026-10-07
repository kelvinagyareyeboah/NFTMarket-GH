// SPDX-License-Identifier: MIT


 '@openzeppelin/contracts/access/Owna
 * @dev A simple mock ProxyRegistry for use in local tests with minimal securi
contract MockProxyRegistry is Ownable {
  mapping(address => address) public proxies;


  /***********************************|
  |  Public Configuration Functions   |
  |__________________________________*/

  /**
   * @notice Allow the owner to set a proxy for testing
   * @param _address           The address that the proxy will act on behalf of
   * @param _proxyForAddress  The proxy that will act on behalf of the address
   */
  function setProxy(address _address, address _proxyForAddress)
      external
      onlyOwner()
  {
      proxies[_address] = _proxyForAddress;
  }
}
