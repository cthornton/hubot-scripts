# Description:
#   Gamble your money away!
#
# Dependencies:
#   Wallet
#
# Configuration: None
#
# Commands:
#   hubot (fifty-fifty|50-50|cointoss) <bet amount>
#
# Author:
#   cgthornt

Wallet = require('./../src/wallet')

module.exports = (robot) ->
  robot.respond /(fifty\-fifty|50\-50|cointoss) \$?([0-9]+(\.[0-9]{1,2})?)/i, (msg) ->
    bet = parseFloat(msg.match[2])
    wallet = new Wallet(msg.message.user)

    # Make sure they don't exceed amount
    if bet > wallet.balance()
      msg.send "Your bet of #{bet.toMoney()} is greater than your wallet balance of #{wallet.balance().toMoney()}. Borrow some money and try again."
      return

    # Horray! We won!
    if Math.random() > 0.5
      wallet.increaseBalance(bet)
      msg.send "Horray! You won #{bet.toMoney()}. Your new wallet balance: #{wallet.balance().toMoney()}."
    else
      wallet.increaseBalance(-bet)
      msg.send "Oh no! You lost #{bet.toMoney()}! Your new wallet balance: #{wallet.balance().toMoney()}."
