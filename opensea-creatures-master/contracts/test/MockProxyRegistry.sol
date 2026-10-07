// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

/**
 * @title MockProxyRegistry
 * @author -
 * @dev A simple mock ProxyRegistry for use in local tests with minimal
 *      security. It mimics the OpenSea-style proxy registry interface:
 *      a public `proxies` mapping that maps an address to the proxy
 *      address that acts on its behalf.
 *
 *      WARNING: This contract is intended for TESTING ONLY. Do not deploy
 *      it to a production network.
 */
contract MockProxyRegistry is Ownable {
    /***********************************|
    |             Storage               |
    |__________________________________*/

    /// @notice Maps an address to the proxy that acts on its behalf
    mapping(address => address) public proxies;

    /***********************************|
    |              Events               |
    |__________________________________*/

    /**
     * @notice Emitted whenever a proxy is set or changed for an address
     * @param account   The address the proxy acts on behalf of
     * @param proxy     The new proxy address
     */
    event ProxySet(address indexed account, address indexed proxy);

    /***********************************|
    |  Public Configuration Functions   |
    |__________________________________*/

    /**
     * @notice Allow the owner to set a proxy for testing
     * @param _address          The address that the proxy will act on behalf of
     * @param _proxyForAddress  The proxy that will act on behalf of the address
     */
    function setProxy(address _address, address _proxyForAddress)
        external
        onlyOwner
    {
        _setProxy(_address, _proxyForAddress);
    }

    /**
     * @notice Allow the owner to set many proxies in a single transaction
     * @dev Both arrays must be the same length; entries are matched by index
     * @param _addresses         The addresses that the proxies will act on behalf of
     * @param _proxiesForAddress The proxies that will act on behalf of each address
     */
    function setProxies(
        address[] calldata _addresses,
        address[] calldata _proxiesForAddress
    ) external onlyOwner {
        require(
            _addresses.length == _proxiesForAddress.length,
            'MockProxyRegistry: length mismatch'
        );

        for (uint256 i = 0; i < _addresses.length; i++) {
            _setProxy(_addresses[i], _proxiesForAddress[i]);
        }
    }

    /**
     * @notice Allow the owner to remove the proxy for an address
     * @param _address The address whose proxy should be cleared
     */
    function clearProxy(address _address) external onlyOwner {
        _setProxy(_address, address(0));
    }

    /***********************************|
    |          View Functions           |
    |__________________________________*/

    /**
     * @notice Check whether an address currently has a proxy set
     * @param _address The address to check
     * @return True if a non-zero proxy is registered for the address
     */
    function hasProxy(address _address) external view returns (bool) {
        return proxies[_address] != address(0);
    }

    /***********************************|
    |        Internal Functions         |
    |__________________________________*/

    /**
     * @dev Writes the proxy to storage and emits the corresponding event
     */
    function _setProxy(address _address, address _proxyForAddress) internal {
        proxies[_address] = _proxyForAddress;
        emit ProxySet(_address, _proxyForAddress);
    }
}

