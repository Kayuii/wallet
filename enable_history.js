module.exports = function(fibos) {
    let accountName = process.env.WATCH_ACCOUNT;
    if (accountName) {
      var arr = accountName.slice(1,-1).split(',')
      // console.log(arr)

      fibos.load('history', {
        'filter-on': arr,
      });
  
      fibos.load('history_api');
    }
  
    fibos.start();
  };
