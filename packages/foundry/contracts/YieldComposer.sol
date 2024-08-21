pragma solidity ^0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { IOFT, SendParam, MessagingFee, MessagingReceipt, OFTReceipt } from 
//                                     "LayerZero-v2/packages/layerzero-v2/evm/oapp/contracts/oft/interfaces/IOFT.sol";
import { ILayerZeroComposer } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroComposer.sol";
import { OFTComposeMsgCodec } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/libs/OFTComposeMsgCodec.sol";

import { IDiscreteStakingRewardsStargateEth } from "lib/interfaces/IDiscreteStakingRewardsStargateEth.sol";

// import { IMockAMM } from './interfaces/IMockAMM.sol';

contract YieldComposer is ILayerZeroComposer {
    // IMockAMM public immutable amm;
    address public immutable endpoint;
    address public immutable stargate;
    address public warden;
    address public pendingWarden = address(0);
    address public immutable coin;

    event ReceivedOnDestination(address token);

    constructor(address _endpoint, address _stargate) {
        // amm = IMockAMM(_amm);
        // warden = _warden;
        endpoint = _endpoint;
        stargate = _stargate; // The native OFT?
    }

    // function setWarden(address _warden) external {
    //     require(msg.sender == warden, "!warden");
    //     pendingWarden = _warden;
    // }

    // function acceptWarden(address _warden) external {
    //     require(msg.sender == pendingWarden, "!pendingWarden");
    //     warden = pendingWarden;
    // }

    function lzCompose(
        address _from,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) external payable {
        require(_from == stargate, "!stargate");
        require(msg.sender == endpoint, "!endpoint");

        uint256 amountLD = OFTComposeMsgCodec.amountLD(_message);
        bytes memory _composeMessage = OFTComposeMsgCodec.composeMsg(_message);

        (address user, uint amount, address oft, address vault) =
            abi.decode(_composeMessage, (address, uint, address, address));

        IERC20(oft).approve(vault, amount);
        IDiscreteStakingRewardsStargateEth(vault).stake(amount);

        // IERC20(_oftOnDestination).approve(address(amm), amountLD);

        // try amm.swapExactTokensForTokens(
        //     amountLD,
        //     _amountOutMinDest,
        //     path,  
        //     _tokenReceiver, 
        //     _deadline 
        // ) {
        //     emit ReceivedOnDestination(_tokenOut);
        // } catch {
        //     IERC20(_oftOnDestination).transfer(_tokenReceiver, amountLD);
        //     emit ReceivedOnDestination(_oftOnDestination);
        // }
    }

    fallback() external payable {}
    receive() external payable {}
}