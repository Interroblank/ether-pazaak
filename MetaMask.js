window.addEventListener ("load", () => {
  if (typeof web3 !== "undefined") {
    web3 = new Web3 (web3.currentProvider);
    console.log ("found MetaMask");
  } else {
    console.error ("unable to find MetaMask");
  }

  ethereum.autoRefreshOnNetworkChange = false;

  ethereum.enable ().then (function (x) {
    console.log (`enabled Ethereum successfully: address ${x[0]} with web3.js version ${web3.version.api}`); 
  });
});
