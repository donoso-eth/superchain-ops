# Validation

This document can be used to validate the inputs and result of the execution of the transaction which you are
signing.

The steps are:

1. [Validate the Domain and Message Hashes](#expected-domain-and-message-hashes)
2. [Verifying the transaction input](#understanding-task-calldata)
3. [Verifying the state changes](#task-state-changes)

## Expected Domain and Message Hashes

First, we need to validate the domain and message hashes. These values should match both the values on your ledger and
the values printed to the terminal when you run the task.

> [!CAUTION]
>
> Before signing, ensure the below hashes match what is on your ledger.
>
> ### Foundation Safe (`0xDEe57160aAfCF04c34C887B5962D0a69676d3C8B`)
>
> - Domain Hash: `0x37e1f5dd3b92a004a23589b741196c8a214629d4ea3a690ec8e41ae45c689cbb`
> - Message Hash: `0x0fb415b196b1cc2520377998fa86d71e6e68473223c6b342bbe0b87448bb85ad`
>
> ### Security Council Safe (`0xf64bc17485f0B4Ea5F06A96514182FC4cB561977`)
>
> - Domain Hash: `0xbe081970e9fc104bd1ea27e375cd21ec7bb1eec56bfe43347c3e36c5d27b8533`
> - Message Hash: `0xe41063970d132c7bd99a79ca4b7f5e63ecc2bf58759e5b753fdbd46186fcbb8e`

## Understanding Task Calldata

The task calls `setImplementation(uint32,address,bytes)` on the Arena-Z Testnet DisputeGameFactory
to update the CWIA (Clone-With-Immutable-Args) for the `PERMISSIONED_CANNON` game type (1).

The implementation contract remains unchanged at `0x58bf355C5d4EdFc723eF89d99582ECCfd143266A`.

Only the proposer address in the CWIA args is updated:
- **Old proposer:** `0xC97FFcB0953e60995B5D06755DEd41b78A3C8B48`
- **New proposer:** `0x5D7481c68Eb61da46b2F4eF81B9FD988d97527E0`

The CWIA args are packed as:
`absolutePrestate(32) + vm(20) + anchorStateRegistry(20) + weth(20) + l2ChainId(32) + proposer(20) + challenger(20)`

You can verify by decoding the inner calldata:

```bash
cast 4byte-decode 0xb1070957000000000000000000000000000000000000000000000000000000000000000100000000000000000000000058bf355c5d4edfc723ef89d99582eccfd143266a000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a4033c000916b4a88cfffeceddd6cf0f4be3897a89195941e5a7c3f8209b4dbb6e6463dee3828677f6270d83d45408044fc5edb908ca89d6e09024334188aa219fe1c994361dd76e21b496a0c00e7a3ca9d1746015d7c6ed6dc5293a1900000000000000000000000000000000000000000000000000000000000026ab5d7481c68eb61da46b2f4ef81b9fd988d97527e0fd1d2e729ae8eee2e146c033bf4400fe75284301
```

Which decodes to:
- `gameType`: `1` (PERMISSIONED_CANNON)
- `impl`: `0x58bf355C5d4EdFc723eF89d99582ECCfd143266A`
- `args`: 164-byte packed CWIA args with the new proposer

Calldata:
```
0x174dea71000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000020000000000000000000000000d02dd46b73ff5f3ec3970f9a12f08ad703c103df0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000144b1070957000000000000000000000000000000000000000000000000000000000000000100000000000000000000000058bf355c5d4edfc723ef89d99582eccfd143266a000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000a4033c000916b4a88cfffeceddd6cf0f4be3897a89195941e5a7c3f8209b4dbb6e6463dee3828677f6270d83d45408044fc5edb908ca89d6e09024334188aa219fe1c994361dd76e21b496a0c00e7a3ca9d1746015d7c6ed6dc5293a1900000000000000000000000000000000000000000000000000000000000026ab5d7481c68eb61da46b2f4ef81b9fd988d97527e0fd1d2e729ae8eee2e146c033bf4400fe752843010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
```

# State Validations

For each contract listed in the state diff, please verify that no contracts or state changes shown in the Tenderly diff are missing from this document. Additionally, please verify that for each contract:

- The following state changes (and none others) are made to that contract. This validates that no unexpected state
  changes occur.
- All addresses (in section headers and storage values) match the provided name, using the Etherscan and Superchain
  Registry links provided. This validates the bytecode deployed at the addresses contains the correct logic.
- All key values match the semantic meaning provided, which can be validated using the storage layout links provided.

### State Overrides

Note: The changes listed below do not include threshold, nonce and owner mapping overrides. These changes are listed and explained in the [NESTED-VALIDATION.md](../../../../../docs/NESTED-VALIDATION.md) file.

### Task State Changes

### [`0x1Eb2fFc903729a0F03966B917003800b145F56E2`](https://github.com/ethereum-optimism/superchain-registry/blob/main/superchain/configs/sepolia/arena-z.toml) (ProxyAdminOwner (GnosisSafe)) - Chain ID: 11155420

- **Key:**          `0x0000000000000000000000000000000000000000000000000000000000000005`
  - **Decoded Kind:** `uint256`
  - **Before:** `48`
  - **After:** `49`
  - **Summary:** Nonce increment for the ProxyAdminOwner Safe.
  - **Detail:** The Safe nonce is incremented from 48 to 49 after executing the transaction.

> [!IMPORTANT]
> Foundation Only

If signer is on Foundation Safe: `0xDEe57160aAfCF04c34C887B5962D0a69676d3C8B`:

- **Key:**          `0xc13b35165139594ec8622e8b091e9e28c50a964c21c404747a8a766f1d33c427`
  - **Before:** `0x0000000000000000000000000000000000000000000000000000000000000000`
  - **After:** `0x0000000000000000000000000000000000000000000000000000000000000001`
  - **Summary:** `approveHash(bytes32)` called on ProxyAdminOwner by Foundation Safe.
  - **Detail:** **THIS WAS CAREFULLY VERIFIED BY RUNBOOK REVIEWERS AND NEED NOT BE CHECKED BY SIGNERS.** This slot change reflects the Foundation Safe calling `approveHash` on the ProxyAdminOwner as part of the nested multisig execution flow. The slot is `approvedHashes[0xDEe57160aAfCF04c34C887B5962D0a69676d3C8B][0x747b5032179d7ed33b016bafd5c4cb20cf6a2cb64fcbeab5b4ec0b3732e87cf0]` (mapping at slot 8). To verify:
    - `res=$(cast index address 0xDEe57160aAfCF04c34C887B5962D0a69676d3C8B 8)`
    - `cast index bytes32 0x747b5032179d7ed33b016bafd5c4cb20cf6a2cb64fcbeab5b4ec0b3732e87cf0 $res`

> [!IMPORTANT]
> Security Council Only

If signer is on Security Council Safe: `0xf64bc17485f0B4Ea5F06A96514182FC4cB561977`:

- **Key:**          `0x39a018745adf610fb4c3d09eb5757455a96130bee678bd24d1799aa2bdd1d615`
  - **Before:** `0x0000000000000000000000000000000000000000000000000000000000000000`
  - **After:** `0x0000000000000000000000000000000000000000000000000000000000000001`
  - **Summary:** `approveHash(bytes32)` called on ProxyAdminOwner by Security Council Safe.
  - **Detail:** **THIS WAS CAREFULLY VERIFIED BY RUNBOOK REVIEWERS AND NEED NOT BE CHECKED BY SIGNERS.** This slot change reflects the Security Council Safe calling `approveHash` on the ProxyAdminOwner as part of the nested multisig execution flow. The slot is `approvedHashes[0xf64bc17485f0B4Ea5F06A96514182FC4cB561977][0x747b5032179d7ed33b016bafd5c4cb20cf6a2cb64fcbeab5b4ec0b3732e87cf0]` (mapping at slot 8). To verify:
    - `res=$(cast index address 0xf64bc17485f0B4Ea5F06A96514182FC4cB561977 8)`
    - `cast index bytes32 0x747b5032179d7ed33b016bafd5c4cb20cf6a2cb64fcbeab5b4ec0b3732e87cf0 $res`

### [`0xd02dd46b73ff5f3eC3970f9A12f08Ad703c103df`](https://github.com/ethereum-optimism/superchain-registry/blob/main/superchain/configs/sepolia/arena-z.toml) (DisputeGameFactoryProxy) - Chain ID: 9899

These two slots are consecutive storage locations for the packed CWIA (Clone-With-Immutable-Args) bytes
stored in the `gameArgs` mapping for game type `1` (PERMISSIONED_CANNON).

The `gameArgs` mapping is at storage slot **105** in the DisputeGameFactory v1.4.0 (op-contracts v6.0.0+).
This is derived from the inheritance chain: `OwnableUpgradeable` and its parents consume slots 0-100
(Initializable + ContextUpgradeable `__gap[50]` + `_owner` + OwnableUpgradeable `__gap[49]`),
then the factory's own variables occupy slots 101-105 (`gameImpls`, `initBonds`, `_disputeGames`,
`_disputeGameList`, `gameArgs`). The slot can be verified on-chain: `cast storage <proxy> $(cast keccak $(cast abi-encode "f(uint32,uint256)" 1 105))` returns `0x149` (Solidity's encoding for 164-byte dynamic `bytes`: `164 * 2 + 1 = 329`).

For `mapping(GameType => bytes)` with key `1` at slot 105, the data slots are computed as:
`dataStart = keccak256(keccak256(abi.encode(1, 105)))`, and the 164 bytes span 6 consecutive 32-byte slots starting there.

The CWIA layout is: `absolutePrestate(32) + vm(20) + anchorStateRegistry(20) + weth(20) + l2ChainId(32) + proposer(20) + challenger(20)` = 164 bytes packed.

Only the proposer address changes (bytes 124-143). The challenger (`0xFd1D2e729AE8eEe2E146c033BF4400fE75284301`) remains unchanged.

- **Key:**          `0x9afb513dc3306e3bc370fea0bac86eaae93221c831ccaae670c9d4101fb0fa7f`
  - **Before:** `0x000000000000000000000000000000000000000000000000000026abc97ffcb0`
  - **After:** `0x000000000000000000000000000000000000000000000000000026ab5d7481c6`
  - **Summary:** CWIA args data slot — contains end of `l2ChainId` + first 4 bytes of proposer.
  - **Detail:** The last 2 bytes `26ab` are the chain ID (9899), unchanged. The trailing 4 bytes change from `c97ffcb0` (start of old proposer `0xC97FFcB0...`) to `5d7481c6` (start of new proposer `0x5D7481c6...`). You can verify the current on-chain args with:
    ```bash
    cast call 0xd02dd46b73ff5f3eC3970f9A12f08Ad703c103df "gameArgs(uint32)(bytes)" 1 --rpc-url https://ethereum-sepolia-rpc.publicnode.com
    ```

- **Key:**          `0x9afb513dc3306e3bc370fea0bac86eaae93221c831ccaae670c9d4101fb0fa80`
  - **Before:** `0x953e60995b5d06755ded41b78a3c8b48fd1d2e729ae8eee2e146c033bf4400fe`
  - **After:** `0x8eb61da46b2f4ef81b9fd988d97527e0fd1d2e729ae8eee2e146c033bf4400fe`
  - **Summary:** CWIA args data slot — contains remaining 16 bytes of proposer + first 16 bytes of challenger.
  - **Detail:** The first 16 bytes change from `953e60995b5d06755ded41b78a3c8b48` (bytes 4-19 of old proposer `0xC97FFcB0953e60995B5D06755DEd41b78A3C8B48`) to `8eb61da46b2f4ef81b9fd988d97527e0` (bytes 4-19 of new proposer `0x5D7481c68Eb61da46b2F4eF81B9FD988d97527E0`). The last 16 bytes `fd1d2e729ae8eee2e146c033bf4400fe` are the first 16 bytes of the challenger address `0xFd1D2e729AE8eEe2E146c033BF4400fE75284301`, which remains unchanged.

> [!IMPORTANT]
> Security Council Only

### [`0xc26977310bC89DAee5823C2e2a73195E85382cC7`](https://github.com/ethereum-optimism/optimism/blob/e84868c27776fd04dc77e95176d55c8f6b1cc9a3/packages/contracts-bedrock/src/safe/LivenessGuard.sol) (LivenessGuard)
**THIS STATE DIFF ONLY APPEARS WHEN SIGNING FOR THE COUNCIL AND DOES NOT NEED TO BE CHECKED BY SIGNERS.**

- **Key:**          `0x8b832b208e2b85d2569164b1655368f5b5eddb1c56f6c1acf41053cac08f5141`
  - **Before:**     `0x0000000000000000000000000000000000000000000000000000000000000000`
  - **After:**      Updated to `block.timestamp` at time of execution.
  - **Summary:**    LivenessGuard timestamp update.
  - **Detail:**     **THIS STATE DIFF ONLY APPEARS WHEN SIGNING FOR THE COUNCIL AND DOES NOT NEED TO BE CHECKED BY SIGNERS.**
                    When the security council safe executes a transaction, the liveness timestamps are updated.
                    This is updating at the moment when the transaction is submitted (`block.timestamp`) into the [`lastLive`](https://github.com/ethereum-optimism/optimism/blob/e84868c27776fd04dc77e95176d55c8f6b1cc9a3/packages/contracts-bedrock/src/safe/LivenessGuard.sol#L41) mapping located at the slot 0.

