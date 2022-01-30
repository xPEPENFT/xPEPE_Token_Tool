# xPEPE_Token_Tool_Public
 A Windows-Based Program Written To Pull Data From The XRPL Ledger And Push To MySQL
- The Main GUI/Tool is written in AutoIt - Compiled to an EXE but the Source is also available.
- A mix of Javascript + Python is used to pull XRP Ledger Data
- Javascript for the OfferBook section - Written by Robert Daugherty aka xArtist Dameinx
- Python for the Richlist Compile (Pull all Token Holders Wallets/Balances) - Written by xPEPE Raphael

- [Top 15 LIVE Leaderboard](https://github.com/xPEPENFT/xPEPE_Leaderboard) (Uses the MySQL data from these files)

What you need

A MySQL Database to store the information

Create your tables

1: richlist (Holds your Wallet Strings and the Balance tied to that Wallet)

![image](https://user-images.githubusercontent.com/98682121/151691073-b65f445d-2f08-4cff-a6ab-d746e705aec1.png)

```
CREATE TABLE `richlist` (
  `ID` int(11) NOT NULL,
  `Wallet` varchar(255) NOT NULL,
  `Balance` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

2: lastupdate (Holds a record that is updated each time you push new MySQL Data as to give timestamps for reference)

![image](https://user-images.githubusercontent.com/98682121/151691059-7363781c-df41-4966-8130-674bec8d36da.png)

```
CREATE TABLE `lastupdate` (
  `ID` int(11) NOT NULL,
  `Time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `Tag` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

3: offersBuy (Holds the Buy section of the Offer Book. Shows the buyers Wallet, how much they want to buy, what they intend to spend in XRP and their Wallet Balance)

![image](https://user-images.githubusercontent.com/98682121/151691044-f6ad4ac7-e5c1-4c0b-b544-684248a9b7f5.png)

```
CREATE TABLE `offersBuy` (
  `ID` int(11) NOT NULL,
  `Buyer` varchar(255) NOT NULL,
  `xPEPE` varchar(255) NOT NULL,
  `XRP` varchar(255) NOT NULL,
  `Holdings` varchar(255) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

4: offersSell (Holds the Sell section of the OFfer Book. Shows the sellers Wallet, how much they are selling, their buy price and their total Token Balance)

![image](https://user-images.githubusercontent.com/98682121/151691015-3e9e040a-fe46-423c-90c9-30d897147164.png)

```
CREATE TABLE `offersSell` (
  `ID` int(11) NOT NULL,
  `Seller` varchar(255) NOT NULL,
  `xPEPE` varchar(255) NOT NULL,
  `XRP` varchar(255) NOT NULL,
  `Holdings` varchar(255) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```

Next step is to setup the MySQL Server Settings for the program
- Locate the INI file labeled "Settings.ini" in the folder

![image](https://user-images.githubusercontent.com/98682121/151691209-d75db10f-a586-488e-b304-a30e1f701cc9.png)

Once you open the Settings.ini file change the text in the file to your Settings.

Default Settings for Settings.ini
```
[Settings]
ServerIP=NA
ServerUsername=NA
ServerPassword=NA
ServerPort=3306

[Database]
Database=xrpPEPE
RichlistTable=richlist
```

Next step is to setup the Javascript + Python scripts

If you do not have Javascript / Python setup, please install those before moving forward.

Open the "book.js" file located in the "scripts" folder

1: Setup your MySQL Server Settings inside here just as you did your Settings.ini (Lines 4-9)

```
var connection = mysql.createConnection({
    host     : '1.1.1.1', // Add in your MySQL Servers IP Address
    user     : 'USERNAME', // Add in your MySQL Servers Username
    password : 'PASSWORD', // Add in your MySQL Servers Password
    database : 'DATABASE' // Add in your MySQL Servers Database
  });
  ```
  
2: Setup your request for Sell Orders, put in your Token Currency and your Issuer Address in their respective places (Lines 42-53)
  
```
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
```
   
3: Setup your request for Buy Orders, put in your Token Currency and Issuer Address in their respectice places. (Lines 94-106)
   
```
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
```
      
 That's it for book.js!
      
 Let's move onto the rich_list-V6.py!
      
 The only thing you need to change here is the issuer address to match yours! (Line 9)
      
 ```
      target_address = "rw5e5krAvv1DrWyzmEr1NtNzg5jR26u5Gj" # Fill out with your target address
 ```
      
 The last thing we have to do is optional, if you wish to ignore certain Wallet's from the Richlist download, add them into the exempt.txt file.
      
 This is handy for ignoring the issuing Wallet + any Marketing/Devlopment Wallets you might not need to look at.
      
 That's it for this tool! Please check out the other Repo's to tie in this tool with others, including a Leaderboard for your top 15 Holders and a way to easily View all your MySQL Data!
 
 [Top 15 LIVE Leaderboard Repo](https://github.com/xPEPENFT/xPEPE_Leaderboard)
