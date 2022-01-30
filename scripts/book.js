const xrpl = require('xrpl');
const mysql = require('mysql');

var connection = mysql.createConnection({
    host     : '1.1.1.1', // Add in your MySQL Servers IP Address
    user     : 'USERNAME', // Add in your MySQL Servers Username
    password : 'PASSWORD', // Add in your MySQL Servers Password
    database : 'DATABASE' // Add in your MySQL Servers Database
  });
  

  connection.connect();
  const XRPclient = new xrpl.Client('wss://xrplcluster.com'); 

  connection.query('TRUNCATE TABLE offersSell', function (error, results, fields) {

});

connection.query('TRUNCATE TABLE offersBuy', function (error, results, fields) {

});

connection.query('TRUNCATE TABLE lastupdate', function (error, results, fields) {

});

sqlVar = {Tag: "UpdateMe"};
   var query = connection.query('INSERT INTO `lastupdate` SET ?', sqlVar, function (error, results, fields) {
if (error) throw error;

});


  var totalAdded = 0
  var totalXRP = 0


async function getSellOrders() {
      
    await XRPclient.connect();
    
   const getOfferData = {
        "id": 4,
        "command": "book_offers",
        "taker_gets": {
            "currency": "7850455045000000000000000000000000000000", // Insert your tokens currency ID
          "issuer": "rw5e5krAvv1DrWyzmEr1NtNzg5jR26u5Gj" // Insert your issuer address
        },
        "taker_pays": {
          "currency": "XRP" // Change this if you want to change the exchange type
        },
        "limit":300
   }

   const responseOfferInfo = await XRPclient.request(getOfferData);




   for (var i = 0; i < responseOfferInfo.result.offers.length; i++) { 
       totalAdded += 1
       totalXRP = 0
       totalXRP = responseOfferInfo.result.offers[i].quality
       totalXRP = totalXRP / 1000000
        if (responseOfferInfo.result.offers[i].owner_funds === undefined) {
            responseOfferInfo.result.offers[i].owner_funds = "0.00"
        }
       sqlVar = {Seller: responseOfferInfo.result.offers[i].Account, xPEPE: responseOfferInfo.result.offers[i].TakerGets.value,
        XRP: totalXRP, Holdings: responseOfferInfo.result.offers[i].owner_funds};
       var query = connection.query('INSERT INTO `offersSell` SET ?', sqlVar, function (error, results, fields) {
    if (error) throw error;
   
   });

   
     }

   // console.log('\n' + "Seller: " + responseOfferInfo.result.offers[i].Account + '\n' + "Selling: " + responseOfferInfo.result.offers[i].TakerGets.value + '\n' +
    //"Cost in XRP: " +  totalXRP + '\n')

    console.log("Total number of Sell Offers added to Database: " + totalAdded)
   
   // XRPclient.disconnect()
   // connection.end()

}



async function getBuyOrders() {
    totalAdded = 0
    await XRPclient.connect();
   //connection.connect();
   const getBuyData = {
        "id": 4,
        "command": "book_offers",
        "taker": "rf1BiGeXwwQoi8Z2ueFYTEXSwuJYfV2Jpn",
        "taker_gets": {
          "currency": "XRP"
        },
        "taker_pays": {
          "currency": "7850455045000000000000000000000000000000", // Insert your tokens currency ID
          "issuer": "rw5e5krAvv1DrWyzmEr1NtNzg5jR26u5Gj" // Insert your issuer address
        },
        "limit":300
      }

   const responseBuyInfo = await XRPclient.request(getBuyData);



   for (var i = 0; i < responseBuyInfo.result.offers.length; i++) { 
       totalAdded += 1
       totalXRP = 0
       totalXRP = responseBuyInfo.result.offers[i].TakerGets
       totalXRP = totalXRP / 1000000
        if (responseBuyInfo.result.offers[i].owner_funds === undefined) {
            responseBuyInfo.result.offers[i].owner_funds = "0.00"
        }
       sqlVar = {Buyer: responseBuyInfo.result.offers[i].Account, xPEPE: responseBuyInfo.result.offers[i].TakerPays.value,
        XRP: totalXRP, Holdings: responseBuyInfo.result.offers[i].owner_funds};
       var query = connection.query('INSERT INTO `offersBuy` SET ?', sqlVar, function (error, results, fields) {
    if (error) throw error;
   
   });

   
     }

   // console.log('\n' + "Seller: " + responseOfferInfo.result.offers[i].Account + '\n' + "Selling: " + responseOfferInfo.result.offers[i].TakerGets.value + '\n' +
    //"Cost in XRP: " +  totalXRP + '\n')

    console.log("Total number of Orders added to Database: " + totalAdded)
   
}

finalFunction()
async function finalFunction(){
    await getBuyOrders();
    await getSellOrders();
    console.log("Finished both!")
    XRPclient.disconnect()
    connection.end()
  };