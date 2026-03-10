// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {VmSafe} from "forge-std/Vm.sol";
import {stdToml} from "forge-std/StdToml.sol";

import {L2TaskBase} from "src/tasks/types/L2TaskBase.sol";
import {SuperchainAddressRegistry} from "src/SuperchainAddressRegistry.sol";
import {Action} from "src/libraries/MultisigTypes.sol";

/// @title SetDisputeGameArgs
/// @notice This template updates the CWIA (Clone-With-Immutable-Args) data for a PermissionedDisputeGame
///         in the DisputeGameFactory, without changing the implementation contract itself.
///         This is used for operations like proposer migrations where only the args need to change.
contract SetDisputeGameArgs is L2TaskBase {
    using stdToml for string;

    /// @notice Struct representing configuration for the task per chain.
    /// @dev Fields MUST be in alphabetical order for stdToml.parseRaw compatibility.
    struct GameArgsConfig {
        uint256 chainId;
        address expectedChallenger;
        address expectedImpl;
        address newProposer;
    }

    /// @notice Mapping of chain ID to configuration for the task.
    mapping(uint256 => GameArgsConfig) public cfg;

    /// @notice Returns the safe address string identifier.
    function safeAddressString() public pure override returns (string memory) {
        return "ProxyAdminOwner";
    }

    /// @notice Returns the storage write permissions required for this task.
    function _taskStorageWrites() internal pure virtual override returns (string[] memory) {
        string[] memory storageWrites = new string[](1);
        storageWrites[0] = "DisputeGameFactoryProxy";
        return storageWrites;
    }

    /// @notice Sets up the template with implementation configurations from a TOML file.
    function _templateSetup(string memory _taskConfigFilePath, address _rootSafe) internal override {
        super._templateSetup(_taskConfigFilePath, _rootSafe);
        string memory toml = vm.readFile(_taskConfigFilePath);

        GameArgsConfig[] memory configs = abi.decode(toml.parseRaw(".gameArgsConfig"), (GameArgsConfig[]));
        for (uint256 i = 0; i < configs.length; i++) {
            cfg[configs[i].chainId] = configs[i];
        }
    }

    /// @notice Build the task actions: update gameArgs for PERMISSIONED_CANNON with new proposer.
    function _build(address) internal override {
        SuperchainAddressRegistry.ChainInfo[] memory chains = superchainAddrRegistry.getChains();
        for (uint256 i = 0; i < chains.length; i++) {
            uint256 chainId = chains[i].chainId;
            GameArgsConfig memory c = cfg[chainId];
            require(c.chainId != 0, "SetDisputeGameArgs: Config not found for chain");

            address dgf = superchainAddrRegistry.getAddress("DisputeGameFactoryProxy", chainId);
            IDisputeGameFactory factory = IDisputeGameFactory(dgf);

            // Read current state
            address currentImpl = factory.gameImpls(PERMISSIONED_CANNON);
            bytes memory currentArgs = factory.gameArgs(PERMISSIONED_CANNON);

            // Validate current state matches expectations
            require(currentImpl == c.expectedImpl, "SetDisputeGameArgs: Implementation mismatch");
            require(currentArgs.length == 164, "SetDisputeGameArgs: Unexpected args length");

            // Build new args: replace proposer (bytes 124-143) with new proposer
            bytes memory newArgs = _replaceProposer(currentArgs, c.newProposer);

            // Call setImplementation with same impl but new args
            factory.setImplementation(PERMISSIONED_CANNON, currentImpl, newArgs);
        }
    }

    /// @notice Validates that the proposer was updated correctly and nothing else changed.
    function _validate(VmSafe.AccountAccess[] memory, Action[] memory, address) internal view override {
        SuperchainAddressRegistry.ChainInfo[] memory chains = superchainAddrRegistry.getChains();
        for (uint256 i = 0; i < chains.length; i++) {
            uint256 chainId = chains[i].chainId;
            GameArgsConfig memory c = cfg[chainId];
            require(c.chainId != 0, "SetDisputeGameArgs: Config not found for chain");

            address dgf = superchainAddrRegistry.getAddress("DisputeGameFactoryProxy", chainId);
            IDisputeGameFactory factory = IDisputeGameFactory(dgf);

            // Verify implementation hasn't changed
            require(factory.gameImpls(PERMISSIONED_CANNON) == c.expectedImpl, "Implementation changed unexpectedly");

            // Verify new args contain the new proposer
            bytes memory newArgs = factory.gameArgs(PERMISSIONED_CANNON);
            address newProposer = _extractProposer(newArgs);
            require(newProposer == c.newProposer, "Proposer not updated correctly");

            // Verify challenger hasn't changed
            address challenger = _extractChallenger(newArgs);
            require(challenger == c.expectedChallenger, "Challenger changed unexpectedly");
        }
    }

    /// @notice No code exceptions for this template.
    function _getCodeExceptions() internal view virtual override returns (address[] memory) {}

    // ---- Internal helpers ---- //

    /// @notice Replace the proposer address in CWIA packed args.
    /// Layout: absolutePrestate(32) + vm(20) + anchorStateRegistry(20) + weth(20) + l2ChainId(32) + proposer(20) + challenger(20)
    /// Proposer starts at byte offset 124 (32+20+20+20+32).
    function _replaceProposer(bytes memory args, address newProposer) internal pure returns (bytes memory) {
        bytes memory result = new bytes(args.length);
        // Copy everything before proposer (first 124 bytes)
        for (uint256 i = 0; i < 124; i++) {
            result[i] = args[i];
        }
        // Write new proposer (20 bytes at offset 124)
        bytes20 proposerBytes = bytes20(newProposer);
        for (uint256 i = 0; i < 20; i++) {
            result[124 + i] = proposerBytes[i];
        }
        // Copy challenger (20 bytes at offset 144)
        for (uint256 i = 144; i < args.length; i++) {
            result[i] = args[i];
        }
        return result;
    }

    /// @notice Extract proposer address from CWIA packed args (offset 124, 20 bytes).
    function _extractProposer(bytes memory args) internal pure returns (address) {
        address proposer;
        assembly {
            proposer := shr(96, mload(add(add(args, 0x20), 124)))
        }
        return proposer;
    }

    /// @notice Extract challenger address from CWIA packed args (offset 144, 20 bytes).
    function _extractChallenger(bytes memory args) internal pure returns (address) {
        address challenger;
        assembly {
            challenger := shr(96, mload(add(add(args, 0x20), 144)))
        }
        return challenger;
    }
}

// ----- GAME TYPE CONSTANTS ----- //
uint32 constant PERMISSIONED_CANNON = 1;

// ----- INTERFACES ----- //
interface IDisputeGameFactory {
    function gameImpls(uint32 gameType) external view returns (address);
    function gameArgs(uint32 gameType) external view returns (bytes memory);
    function setImplementation(uint32 gameType, address impl, bytes calldata args) external;
}
