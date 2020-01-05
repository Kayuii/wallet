module.exports = function(fibos) {
    let accountName = process.env.WATCH_ACCOUNT;
    if (accountName) {
      fibos.load('history', {
        'filter-on': [accountName + ':transfer:', accountName + ':extransfer:'],
      });
  
      fibos.load('history_api');
    }
  
    fibos.start();
  };
  