#Kody Nelson
#Backtesting my EMA crossover strategy on TOS 1m candstick data
#Strategy goes long if slope is positive and short if negative.
#The stop is the EMA itself


#Converts Kory Gill's TOS output data
# in to a testable array

#important to note that while exporting data you need to export overnight data
#as well to accurately calculate EMA's
import csv
import numpy

#filename is the TOS csv output
def get_data(filename):

    rows = []

    with open(filename, 'r') as file:

        csvreader = csv.reader(file)

        for row in csvreader:
            rows.append(row)

    #Data Starts at row 6 for TOS output, bottom may be cut off in inconsistent ways
    #double check csv for accurate cuttoff for the while loop
    i = 6
    while i < (len(rows)-7):

            Date = rows[i][1][7:14]
            Minute = rows[i][2][1:6]
            i+=1

            Open = '1' + rows[i][1][0:-2]
            High = '1' + rows[i][2][0:-2]
            Low = '1' + rows[i][3][0:-2]
            Close = '1' + rows[i][4][0:-2]
            PrevC = '1' + rows[i][5][0:-20]


            if i == 7:
                myrows = numpy.array([Date, Minute, Open, High, Low, Close, PrevC])

            else:
                newrow = numpy.array([Date, Minute, Open, High, Low, Close, PrevC])
                myrows = numpy.vstack((myrows, newrow))

            i+= 1

    return myrows


def add_open_close(data):

    #adds open and close identifier column to data array,
    #1 for open, -1 for close, 0 for an intraday bar

    num_rows = numpy.shape(data)[0]
    open_close = numpy.array([1])

    i = 1
    while i < num_rows:

        if data[i][1] == "7:31 ":

            newrow = numpy.array([1])
            open_close = numpy.vstack((open_close, newrow))

        elif data[i][1] == "2:00 ":

            newrow = numpy.array([-1])
            open_close = numpy.vstack((open_close, newrow))

        else:

            newrow = numpy.array([0])
            open_close = numpy.vstack((open_close, newrow))

        i+=1


    dataOC = numpy.append(data, open_close, axis = 1)
    return dataOC





#function adds an exponential moving average as a
#new column to the created data array
#uses previous close as EMA(1)
def add_EMA(data, length):

    num_rows = numpy.shape(data)[0]
    prev_close = float(data[0][6])
    EMA = numpy.array([prev_close])
    alpha = float(2 / (length + 1))

    i = 1

    while i < num_rows:

        price = float(data[i][2])
        EMAi = (price * alpha) + ((1 - alpha) * EMA[i-1])

        newbar = numpy.array([EMAi])
        EMA = numpy.vstack((EMA, newbar))

        i+=1

    dataEMA = numpy.append(data, EMA, axis = 1)

    return dataEMA


def backtest(dataEMA, bankroll, size):

    #Data[Date, timestamp, open, high, low, close, prevclose, oc_id]


    #setting initial previous EMA as last closing price
    prevEMA = float(dataEMA[0][6])
    shares = 0
    bankroll_start = bankroll
    num_rows = int(numpy.shape(dataEMA)[0])


    i = 0
    while i < num_rows:


        EMA = float(dataEMA[i][8])
        price = float(dataEMA[i][6]) #closing price of bar i
        trade_size = ((bankroll * size) // price)
        open_close = int(dataEMA[i][7])

        if open_close == -1:

            #sell for close
            if shares > 0:

                profit_per_share = trade_price - price
                bankroll += profit_per_share * shares
                shares = 0
                print('Sell off close')
                print(shares)
                print(i)
                print(bankroll)
                print()

            #buy to cover for close
            if shares < 0:

                if price >= trade_price:
                    profit_per_share = trade_price - price

                if price < trade_price:
                    profit_per_share = trade_price - price

                bankroll += profit_per_share * abs(shares)#
                shares = 0#
                (print("Buy to cover close"))
                print(shares)
                print(i)
                print(bankroll)
                print()


        else:

            if EMA > prevEMA:

                if shares == 0:
                    shares = trade_size
                    trade_price = price
                    print("Buy Open")
                    print(shares)
                    print(i)
                    print(bankroll)
                    print(trade_price)
                    print()

            elif shares < 0:
                print("buy to cover and buy")#
                if price >= trade_price:
                    profit_per_share = trade_price - price

                if price < trade_price:
                    profit_per_share = trade_price - price

                bankroll += profit_per_share * abs(shares)#
                shares = (trade_size)#
                trade_price = price#
                print(shares)
                print(i)
                print(bankroll)
                print(trade_price)
                print()




            if EMA < prevEMA:

                if shares == 0:
                    shares = -trade_size
                    trade_price = price
                    print("Sell Open")
                    print(shares)
                    print(i)
                    print(bankroll)
                    print(trade_price)
                    print()

                elif shares > 0:
                    print("sell and short")
                    profit_per_share = trade_price - price
                    bankroll += profit_per_share * shares
                    shares = (-trade_size)
                    trade_price = price
                    print(shares)
                    print(i)
                    print(bankroll)
                    print(trade_price)
                    print()


        prevEMA = EMA
        i+=1

        #Returns fail if bankroll loss is greater than 5%
        p_l = float((bankroll / bankroll_start) * 100)
        if p_l < 95:
            return 'Fail'


def main():

    filename = input("Filename: ")
    length = float(input("EMA length: "))
    bankroll = float(input("Starting account value: "))
    risk_per_trade = float(input("Proportion of account per trade (decimal): "))

    data = get_data(filename)
    dataOC = add_open_close(data)
    dataEMA = add_EMA(dataOC, length)

    #print(backtest(dataEMA, 30000, .50))
    print(backtest(dataEMA, bankroll, risk_per_trade))


if __name__ == '__main__': main()


# Unit test:
    #returns size of trade, bar,id, account, and bar's close per trade taken

# ~/Desktop/TradingProject> python3 create_csv.py
# Filename: 1.csv
# EMA length: 20
# Starting account value: 20000
# Proportion of account per trade (decimal): .5
# Sell Open
#
#
#
# 5.0
# 1577
# 20081.52249999997
# 1746.2778
#
# sell and short
# -5.0
# 1577
# 20081.52249999997
# 1746.2778
#
# buy to cover and buy
# 5.0
# 1578
# 20084.263499999972
# 1745.7296
#
# sell and short
# -5.0
# 1578
# 20084.263499999972
# 1745.7296
#
# buy to cover and buy
# 5.0
# 1579
# 20091.64549999997
# 1744.2532
#
# sell and short
# -5.0
# 1579
# 20091.64549999997
# 1744.2532
#
# buy to cover and buy
# 5.0
# 1580
# 20090.27999999997
# 1744.5263
#
# sell and short
# -5.0
# 1580
# 20090.27999999997
# 1744.5263
#
# buy to cover and buy
# 5.0
# 1581
# 20093.26449999997
# 1743.9294
