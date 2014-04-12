
# Users start off with $100 dollars
WALLET_INITIAL_AMOUNT = 100.00

# 5% interest
INTEREST_RATE = 0.005

# Interval of 1 day. Jerk mode: change to 1 to add 5% interest every second
INTEREST_INTERVAL_SECONDS = 1 * (86400)

# See http://jsfiddle.net/8hnhb/44/
Number::toMoney = ->
  negative = this < 0
  str = Math.abs(this).toFixed(2).toString()
  x = str.split '.'
  x1 = x[0]
  x2 = if x.length > 1 then ('.' + x[1]) else ''
  rgx = /(\d+)(\d{3})/
  while rgx.test x1
    x1 = x1.replace rgx, '$1,$2'
  result = x1 + x2
  return if negative then "-$#{result}" else "$#{result}"


class Wallet
  constructor: (@user) ->
    this.initializeWallet()
    this.handleInterest()

  initializeWallet: ->
    unless @user.wallet
      @user.wallet =
        balance: WALLET_INITIAL_AMOUNT
        debt: 0.0
        resets: 0
        lastInterestDay: new Date().getTime() / 1000
        totalInterest: 0.0
      console.log "Initialized new wallet for #{ @user.name } with balance #{ @user.wallet.balance.toMoney() }"

  balance: ->
    return @user.wallet.balance

  debt: ->
    return @user.wallet.debt

  borrow: (amount) ->
    if amount >= 0
      @user.wallet.balance += amount
      @user.wallet.debt    += amount
      return "You borrowed #{ amount.toMoney() }"
    else
      return "Amount must be greater than zero"


  repayDebt: (amount) ->
    if amount > @user.wallet.balance
      return "Payment exceeds your balance of #{ @user.wallet.balance.toMoney() }."
    if amount > @user.wallet.debt
      return "Payment exceeds your debt of #{ @user.wallet.debt.toMoney() }."
    @user.wallet.balance -= amount
    @user.wallet.debt    -= amount
    return "We thank you for your payment."


  handleInterest: ->
    return unless this.hasDebt() # Horray! No debt!
    now = new Date().getTime() / 1000  # Convert to unix time

    previous = @user.wallet.lastInterestDay
    diff = now - previous
    mult = diff / INTEREST_INTERVAL_SECONDS  # They may have not used this module for a while, so factor in multiple days
    return if mult <= 0.1                    # Been less than a day, no interest (plus rounding errors)

    interest = this.debt() * INTEREST_RATE * mult
    @user.wallet.debt += interest
    @user.wallet.totalInterest += interest

    console.log(@user.name + " accumulated interest in the amount of " + interest.toMoney())
    return interest


  # Increase interest NOW!
  forceInterest: ->
    interest = @user.wallet.debt * INTEREST_RATE
    @user.wallet.debt += interest
    @user.wallet.totalInterest += interest
    console.log("Forced interest amount " + interest.toMoney() + " for user " + @user.name)
    return interest

  increaseBalance: (amount) ->
    @user.wallet.balance += amount


  interestSummary: ->
    return "You have paid #{@user.wallet.totalInterest.toMoney()} in interest so far"


  # Make it small in case of floating point errors
  hasDebt: ->
    return @user.wallet.debt >= 0.1

  # Resets wallet data, but keeps note of the number of times the wallet was reset
  reset: ->
    numResets = @user.wallet.resets + 1
    delete @user.wallet
    this.initializeWallet()
    @user.wallet.resets = numResets

  # Gets the number of resets this wallet has gone through
  numResets: ->
    return @user.wallet.resets

  toObject: ->
    @user.wallet

  toString: ->
    return "Balance: #{ this.balance().toMoney() }, Debt: #{ this.debt().toMoney() }, Bankruptcies: #{ this.numResets() }"

  # Purges all information about this wallet. Requires a re-initialization of the wallet
  @purge: (user) ->
    delete user.wallet

  @interestRate: ->
    return INTEREST_RATE


module.exports = Wallet
