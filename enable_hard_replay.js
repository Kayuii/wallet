module.exports = function(chain_config) {
    let hardreplay = process.env.HARD_REPLAY;
    if (hardreplay) {
       chain_config['hard-replay-blockchain'] = true;
    }
  
};
