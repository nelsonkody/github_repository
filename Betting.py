
# Kody Nelson
# Betting.py finds summary statistics for spreads on betting underdogs only


import pandas as p
import random

def sim(bets, odds):

    bet_sum = sum(bets)
    outcomes = []
    for i in range(500):
        card = 0

        for i in range(len(bets)):
            if float(random.uniform(0,1)) >= .5:
                card += odds[i]/100*bets[i] + bets[i]

        # i = 0
        # while i < len(bets):
        #     if float(random.uniform(0,1)) >= .5:
        #         card += bets[i]
        #i+=1

        outcomes.append(card)

    return outcomes

def main():

    n = int(input("Enter number of bets: "))
    bets = []
    for i in range(n):
        bet = int(input())
        bets.append(bet)
        #infinate loop?

    print("Corresponding odds?:")
    bet_odds = []
    for i in range(n):
        odds = int(input())
        bet_odds.append(odds)



    outcomes = sim(bets, bet_odds)
    #print(outcomes)
    outcomes = p.Series(outcomes)
    print(outcomes.describe())

if __name__ == '__main__': main()

#Unit Testing

# Enter number of bets: 4
# 25
# 25
# 25
# 25
# Corresponding odds?:
# 120
# 160
# 185
# 205
# count    500.000000
# mean     129.280000
# std       67.996995
# min        0.000000
# 25%       71.250000
# 50%      131.250000
# 75%      191.250000
# max      267.500000
# dtype: float64
