


def longest_substring(string):

    substring_len = 0
    substring = ''
    longest_substring = ''

    for x in string:

        if x not in substring:
            substring += x
            substring_len = max(substring_len, len(substring))
            if len(substring) >= len(longest_substring):
                longest_substring = substring

        else:
            slice_index = substring.index(x)
            substring = substring[slice_index + 1:] + x
            if len(substring) >= len(longest_substring):
                longest_substring = substring


    return ('The longest substring is \"' + str(longest_substring) + '\", with ' +
    str(substring_len) + ' characters.')

def main():

    s = input()

    print(longest_substring(s))

if __name__ == '__main__':

    main()
