import re

def process_string(input_string):
    # Define the regex pattern to find the percentage
    percentage_pattern = r"\b\d+\.\d+%"
        
    # Patterns to remove specific substrings
    substrings_to_remove = [r"btp ", r"btp-", r"btpi", r"btpi-"]
        
    # Replace comma with dot for standard percentage format
    input_string = input_string.replace(",", ".")
        
    # Find the percentage using the regex pattern
    percentage_match = re.search(percentage_pattern, input_string)
        
    # Extract the percentage if found
    percentage = percentage_match.group(0) if percentage_match else None
        
    # Erase the found percentage from the original string
    with_btp = re.sub(percentage_pattern, '', input_string)

    with_btp = re.sub(' +', ' ', with_btp).strip()

    btpless = with_btp[:]
        
    # Remove specific substrings
    for pattern in substrings_to_remove:
        btpless = re.sub(pattern, '', btpless)
        
    # Collapse double spaces
    btpless = re.sub(' +', ' ', btpless).strip()
        
    return percentage, with_btp, btpless

test_string = r"btp tf 4,75% st28 eur"
print(process_string(test_string))