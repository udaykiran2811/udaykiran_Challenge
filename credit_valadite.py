# Enter your code here. Read input from STDIN. Print output to STDOUT

import re
import sys

def validate_credit_card(card):
    # Check if the card starts with 4, 5, or 6 and has only digits and hyphens
    if re.match(r'^[456]\d{3}(-?\d{4}){3}$', card):
        # Remove hyphens to check consecutive repeating digits
        card_without_hyphens = card.replace('-', '')
        # Check if there are no more than 3 consecutive repeating digits
        if re.search(r'(\d)\1{3,}', card_without_hyphens):
            return "Invalid"
        else:
            return "Valid"
    else:
        return "Invalid"

# Read input
input_lines = sys.stdin.readlines()
n = int(input_lines[0].strip())
credit_cards = [line.strip() for line in input_lines[1:]]

# Validate each credit card number
for card in credit_cards:
    print(validate_credit_card(card))
