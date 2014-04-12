# Description:
#   Money money money!
#
# Dependencies:
#   None
#
# Configuration: None
#
# Commands:
#   hubot wallet info - get information about your wallet
#   hubot wallet borrow <amount> - plunge yourself further into debt
#   hubot wallet repay <amount> - bring yourself out of debt
#   hubot wallet interest - view information about your interest
#   hubot wallet force-interest - force an interest payment
#   hubot wallet bankrupt - reset your wallet
#   hubot wallet donate - donate your money to charity
#   hubot how (rich|poor) am i?
#
# Author:
#   cgthornt

Wallet = require('./../src/wallet')

wealthOMeter = [

  # Goes up to a billion
  [10000000, "venture capitalism at its finest!"],
  [1000000, "you millionaire status!!!"],
  [5000000, "you be making so much bank, it's crazy!"],
  [200000, "you be popping bottles every weekend!"],
  [100000, "$4 toast and starbucks every day like a true techie!"],
  [50000, "not too bad."],
  [10000, "you're flipping burgers."],
  [100, "barely getting by."],
  [0, "you broke"],
]

debtOMeter = [
  [1000000, "you are the cause of the 2008 recession"],
  [100000, "you shouldn't have bought that boat"],
  [10000, ":("],
  [5000, "you are getting in hot water"],
  [1000, "be careful..."],
  [100, "it's not terrible"],
  [0, "you're home free"],
]


module.exports = (robot) ->
  robot.respond /wallet (info|status)/i, (msg) ->
    wallet = new Wallet(msg.message.user)
    msg.send wallet.toString()

  robot.respond /wallet borrow \$?([0-9]+(\.[0-9]{1,2})?)/i, (msg) ->
    amount = parseFloat(msg.match[1])
    wallet = new Wallet(msg.message.user)
    msg.send wallet.borrow(amount)

  robot.respond /wallet repay \$?([0-9]+(\.[0-9]{1,2})?)/i, (msg) ->
    amount = parseFloat(msg.match[1])
    wallet = new Wallet(msg.message.user)
    msg.send wallet.repayDebt(amount)

  robot.respond /wallet donate \$?([0-9]+(\.[0-9]{1,2})?)/i, (msg) ->
    amount = parseFloat(msg.match[1])
    wallet = new Wallet(msg.message.user)
    if amount > wallet.balance()
      return msg.send "Sorry, you are too poor to make this donation."
    wallet.increaseBalance(-amount)
    msg.send "Thank you for your kind donation to the Jake Augunas happyland foundation!"

  robot.respond /wallet (reset|bankrupt)/i, (msg) ->
    wallet = new Wallet(msg.message.user)
    wallet.reset()
    msg.send "You are now bankrupt! Your wallet has been reset to default values."

  robot.respond /wallet purge/i, (msg) ->
    Wallet.purge(msg.message.user)
    msg.send "OK"

  robot.respond /wallet interest/i, (msg) ->
    wallet = new Wallet(msg.message.user)
    msg.send wallet.interestSummary()

  robot.respond /wallet force\-interest/i, (msg) ->
    wallet = new Wallet(msg.message.user)
    amount = wallet.forceInterest()
    msg.send "Just for fun, you were given interest of #{amount.toMoney()} at a rate of #{Wallet.interestRate() * 100}%."

  # Pretty prints a JSON representation of the wallet
  robot.respond /wallet inspect/i, (msg) ->
    wallet = new Wallet(msg.message.user)
    msg.send JSON.stringify(wallet.toObject(), undefined, 2)

  robot.respond /(how (broke|rich)( am i\??)?)|(am i (broke|rich)\??)/i, (msg) ->
    wallet  = new Wallet(msg.message.user)
    balance = wallet.balance()
    debt    = wallet.debt()
    wealthStatus = null
    debtStatus   = null

    # Wealth meter
    for index, val of wealthOMeter
      amount = val[0]
      desc   = val[1]
      if balance >= amount
        wealthStatus = desc
        break

    # Debt meter
    for index, val of debtOMeter
      amount = val[0]
      desc   = val[1]
      if debt >= amount
        debtStatus = desc
        break

    wealthStatus ||= "you're broke"
    debtStatus   ||= 'UNDEFINED'

    msg.send "Your wealth status: #{wealthStatus} In regards to your debt: #{debtStatus}."
