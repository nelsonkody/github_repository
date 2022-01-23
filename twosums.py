
def twosums(nums, target):

    for i in range(len(nums)):
        for j in range(i + 1, len(nums)):
            if nums[j] == target - nums[i]:
                return [i,j]


def main():

    nums = list(map(int,input().strip().split()))
    target = int(input())

    print(twosums(nums, target))


if __name__ == '__main__':

    main()




# Unit Test

# python3 twosums.py
# input 1 = 2 7 11 15
# input 2 = 9
#
# output = [0, 1]

#Unit Test 2

# python3 twosum.py
# input 1 = 14 35 89 77
# input 2 = 112
#
# output = [1, 3]

# Unit Test 3
#
# python3 twosum.py
# input 1 = 67 45 3 9 4 87
# input 2 = 56
#
# output = None
