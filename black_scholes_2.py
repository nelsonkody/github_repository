
#-----------------------------------------------------------------------
## Black-Scholes option valuation. The Black Scholes formula
## supplies the theoretical value of a European call option on a stock
## that pays no dividends...

import sys
import stdio
import math
import gauss

# Gets first trading variable
def call_a(s, x, r, sigma, t):
    a = (math.log(s/x) + ((r + (sigma ** 2/2)) * t)) / \
        (sigma * math.sqrt(t))
    return a

# Gets second trading variable
def call_b(a, sigma, t):
    b = a - (sigma * (math.sqrt(t)))
    return b

# Theoretical pricing function
def black_scholes(a, b, s, x, r, sigma, t):
    a = gauss.Phi(a)
    b = gauss.Phi(b)
    th_value = (s * a) - (x * (math.e ** (-r * t)) * b )
    return th_value



# Main function for client testing and code execution
def main():

    # current stock price
    s = float(sys.argv[1])

    # exersise price at maturity
    x = float(sys.argv[2])

    #risk free intrest rate ie. a comparable rate for time(t) in
    #goverment securities
    r = float(sys.argv[3])

    #volatility of stocks return / example = .30 or 30% implied volatility
    sigma = float(sys.argv[4])

    #months till experation
    t = float(float(sys.argv[5])/12)

    #Call formulas to entered into black_scholes formumla
    a = (call_a(s, x, r, sigma, t))

    #Calls second function and gets second variable for black_scholes formumla
    b = (call_b(a, sigma, t))

    #Show raw inputs
    stdio.writeln('a = ' + str(a))
    stdio.writeln('b = ' + str(b))
    stdio.writeln('s = ' + str(s))
    stdio.writeln('x = ' + str(x))
    stdio.writeln('r = ' + str(r))
    stdio.writeln('sigma = ' + str(sigma))
    stdio.writeln('t = ' + str(t))


    #Run and display main option contract theoretical value
    stdio.writeln('Theoretical price = ' + str(black_scholes(a, b, s, x, r, sigma, t)))



#Main function execution from client
if __name__ == '__main__': main()
#-----------------------------------------------------------------------

# Unit testing

#SPX 26 Nov 21 (one month out to date)
# python3 black_scholes_2.py 4537.26 4600 .0004 .1580 1
#0.0
# a = -0.27755561392859424
# b = -0.3231662851945747
# s = 4537.26
# x = 4600.0
# r = 0.0004
# sigma = 0.158
# t = 0.08333333333333333
# Theoretical price = 55.54982739559091
###

#RUT 30 SEP 22 (11 months out)
# python3 black_scholes_2.py 2281.48 2330 .0012 .2606 11
# 0.0
# a = 0.04481899496454105
# b = -0.20468650931676066
# s = 2281.48
# x = 2330.0
# r = 0.0012
# sigma = 0.2606
# t = 0.9166666666666666
# Theoretical price = 206.53584338208339
