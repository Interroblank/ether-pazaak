function init() {
	// Setting up the hand buttons.
	document.querySelector("#hand1sp1").addEventListener("click", play_js1);
	document.querySelector("#hand1sp2").addEventListener("click", play_js2);
	document.querySelector("#hand1sp3").addEventListener("click", play_js3);
	document.querySelector("#hand1sp4").addEventListener("click", play_js4);
	document.querySelector("#hand2sp1").addEventListener("click", play_js1);
	document.querySelector("#hand2sp2").addEventListener("click", play_js2);
	document.querySelector("#hand2sp3").addEventListener("click", play_js3);
	document.querySelector("#hand2sp4").addEventListener("click", play_js4);

	// Setting up the join button.
	document.querySelector("#join").addEventListener("click", join_js);

	// Setting up the start button.
	document.querySelector("#start").addEventListener("click", start_js);

	document.querySelector("#stand").addEventListener("click", stand_js);
	document.querySelector("#turn").addEventListener("click", turn_js);

	// Fetching contract information.
	fetch ("./EtherPazaak.abi.json")
		.then (function(response) {
			return response.json();
		})
		.then (function(abi) {
			window.abi = abi;
		});
}

// Calls the "join" function in the smart contract.
function join_js (evt) {
  let instance = getInstance ();
  let sender = web3.eth.accounts[0];
  console.log ("calling join");
  instance.join (
    { from : sender, gas : 200000 },
    function (error, result) {
      if (!error) {
        console.log (result.toString ());
      } else {
        console.error (error);
      }
    }
  );
}

// Calls the "start" function in the smart contract.
function start_js (evt) {
	startListening();
  let instance = getInstance ();
  let sender = web3.eth.accounts[0];
  console.log ("calling start");
  instance.start (
    { from : sender, gas : 200000 },
    function (error, result) {
      if (!error) {
        console.log (result.toString ());
        update_js();
      } else {
        console.error (error);
      }
    }
  );
}

// Calls the "play" function in the smart contract.
function play_js1 (evt) {
	startListening();
  let instance = getInstance ();
  let sender = web3.eth.accounts[0];
  console.log ("calling play");
  instance.play (
  	0,
    { from : sender, gas : 200000 },
    function (error, result) {
      if (!error) {
        console.log (result.toString ());
        update_js();
      } else {
        console.error (error);
      }
    }
  );
}

// Calls the "play" function in the smart contract.
function play_js2 (evt) {
	startListening();
  let instance = getInstance ();
  let sender = web3.eth.accounts[0];
  console.log ("calling play");
  instance.play (
  	1,
    { from : sender, gas : 200000 },
    function (error, result) {
      if (!error) {
        console.log (result.toString ());
        update_js();
      } else {
        console.error (error);
      }
    }
  );
}

// Calls the "play" function in the smart contract.
function play_js3 (evt) {
	startListening();
  let instance = getInstance ();
  let sender = web3.eth.accounts[0];
  console.log ("calling play");
  instance.play (
  	2,
    { from : sender, gas : 200000 },
    function (error, result) {
      if (!error) {
        console.log (result.toString ());
        update_js();
      } else {
        console.error (error);
      }
    }
  );
}

// Calls the "play" function in the smart contract.
function play_js4 (evt) {
	startListening();
  let instance = getInstance ();
  let sender = web3.eth.accounts[0];
  console.log ("calling play");
  instance.play (
  	3,
    { from : sender, gas : 200000 },
    function (error, result) {
      if (!error) {
        console.log (result.toString ());
        update_js();
      } else {
        console.error (error);
      }
    }
  );
}

function stand_js (evt) {
	startListening();
  let instance = getInstance ();
  let sender = web3.eth.accounts[0];
  console.log ("calling stand");
  instance.stand (
    { from : sender, gas : 200000 },
    function (error, result) {
      if (!error) {
        console.log (result.toString ());
        update_js();
      } else {
        console.error (error);
      }
    }
  );
}

function turn_js (evt) {
	startListening();
  let instance = getInstance ();
  let sender = web3.eth.accounts[0];
  console.log ("calling turn");
  instance.turn (
    { from : sender, gas : 200000 },
    function (error, result) {
      if (!error) {
        console.log (result.toString ());
        update_js();
      } else {
        console.error (error);
      }
    }
  );
}

// Standard "getInstance" function that reads the contract address and glues
// things together for you.  You can just copy this function into your code.
function getInstance () {
  let contractAddress = document.querySelector ("#contractAddress").value;
  if (contractAddress === "") {
    console.error ("no contract address set");
  }
  let factory = web3.eth.contract (window.abi);
  let instance = factory.at (contractAddress);
  return instance;
}

// Keep track of whether we are already listening for events.
let alreadyListening = false;

// Start listening for Move events if we are not already listening for them.
function startListening () {
  if (!alreadyListening) {
  	console.log("now listening for events");
    let instance = getInstance ();
    let event = instance.update (function (error, result) {
      if (!error) {
        // When we do receive a Move event, print a message to the console and
        // then call "updateScreen" below.
        console.log ("An update event was received: " + result);
        update_js();
      }
    });
    alreadyListening = true;
  }
}

function update_js () {
 	// Loop over the 3x3 grid.
 	console.log("starting the update . . .");
	for (let i = 0; i < 4; i++) {
	  // Get the HTML button at position (i,j).
	  let button = document.querySelector (`#hand1sp${i + 1}`);
	  // Read the state of the "board" array for position (i,j).
	  let instance = getInstance ();
	  let sender = web3.eth.accounts[0];
	  instance.hand1 (
	    i,
	    { from : sender, gas : 5000000 },
	    function (error, result) {
	      if (!error) {
	        // When we reach here, "result" is the uint8 for the "board" array at position (i,j).
	        // So we assign it to the HTML button's value, which changes the button's label.
	        button.value = result;
	      } else {
	        console.error (error);
	      }
	    }
	  );
	}
	for (let i = 0; i < 4; i++) {
	  // Get the HTML button at position (i,j).
	  let button = document.querySelector (`#hand2sp${i + 1}`);
	  // Read the state of the "board" array for position (i,j).
	  let instance = getInstance ();
	  let sender = web3.eth.accounts[0];
	  instance.hand2 (
	    i,
	    { from : sender, gas : 5000000 },
	    function (error, result) {
	      if (!error) {
	        // When we reach here, "result" is the uint8 for the "board" array at position (i,j).
	        // So we assign it to the HTML button's value, which changes the button's label.
	        button.value = result;
	      } else {
	        console.error (error);
	      }
	    }
	  );
	}
	for (let i = 0; i < 9; i++) {
	  // Get the HTML button at position (i,j).
	  let button = document.querySelector (`#board1sp${i + 1}`);
	  // Read the state of the "board" array for position (i,j).
	  let instance = getInstance ();
	  let sender = web3.eth.accounts[0];
	  instance.board1 (
	    i,
	    { from : sender, gas : 5000000 },
	    function (error, result) {
	      if (!error) {
	        // When we reach here, "result" is the uint8 for the "board" array at position (i,j).
	        // So we assign it to the HTML button's value, which changes the button's label.
	        button.value = result;
	      } else {
	        console.error (error);
	      }
	    }
	  );
	}
	for (let i = 0; i < 9; i++) {
	  // Get the HTML button at position (i,j).
	  let button = document.querySelector (`#board2sp${i + 1}`);
	  // Read the state of the "board" array for position (i,j).
	  let instance = getInstance ();
	  let sender = web3.eth.accounts[0];
	  instance.board2 (
	    i,
	    { from : sender, gas : 5000000 },
	    function (error, result) {
	      if (!error) {
	        // When we reach here, "result" is the uint8 for the "board" array at position (i,j).
	        // So we assign it to the HTML button's value, which changes the button's label.
	        button.value = result;
	      } else {
	        console.error (error);
	      }
	    }
	  );
	}
  let sum1 = document.querySelector ("#sum1");
  let instance1 = getInstance ();
  let sender1 = web3.eth.accounts[0];
	instance1.sum (
	    1,
	    { from : sender1, gas : 5000000 },
	    function (error, result) {
	      if (!error) {
	      	console.log ("" + result)
	        sum1.innerHTML = result;
	      } else {
	        console.error (error);
	      }
	    }
	 );
	let sum2 = document.querySelector ("#sum2");
  let instance2 = getInstance ();
  let sender2 = web3.eth.accounts[0];
	instance2.sum (
	    2,
	    { from : sender2, gas : 5000000 },
	    function (error, result) {
	      if (!error) {
	      	console.log ("" + result)
	        sum2.innerHTML = result;
	      } else {
	        console.error (error);
	      }
	    }
	 );
  let instance3 = getInstance ();
  let sender3 = web3.eth.accounts[0];
	instance3.count (
	    1,
	    { from : sender3, gas : 5000000 },
	    function (error, result) {
	      if (!error) {
	      	console.log ("" + result)
	        score1.innerHTML = result;
	      } else {
	        console.error (error);
	      }
	    }
	 );
  let instance4 = getInstance ();
  let sender4 = web3.eth.accounts[0];
	instance4.count (
	    2,
	    { from : sender4, gas : 5000000 },
	    function (error, result) {
	      if (!error) {
	      	console.log ("" + result)
	        score2.innerHTML = result;
	      } else {
	        console.error (error);
	      }
	    }
	 );
}
