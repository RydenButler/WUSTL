from bs4 import BeautifulSoup
import urllib
import re, os


# Read text into python
url  = urllib.urlopen('Debate1.html').read()
soup = BeautifulSoup(url)

# Subset by <p> tags
speech = soup.find_all('p')[6:477]

# Join statements
statements = ['Remove This One']
for p in speech:
	# Convert to string and remove tags
	current_text = re.sub(r'<[^>]+>', '', str(p))
	# If noted speaker made the previous statement
	if current_text[0:6] == statements[-1][0:6]:
		statements[-1] = statements[-1] + current_text[6:]
		continue
	# If a new speaker is noted, add a new element to the list of statements
	if current_text[0:6] == 'LEHRER':
		statements.append(current_text)
		continue
	if current_text[0:5] == 'OBAMA':
		statements.append(current_text)
		continue
	if current_text[0:6] == 'ROMNEY':
		statements.append(current_text)
		continue
	# If no new speaker is noted, attribute text to the last noted speaker
	else:
		statements[-1] = statements[-1] + current_text

# Remove non-speech text (applause, laughter, etc.)
statements = [re.sub(r'\([^>]+\)', ' ', i) for i in statements[1:]]

# Read in positive words
positive_list = urllib.urlopen("http://www.unc.edu/~ncaren/haphazard/positive.txt").read().splitlines()

# Read in negative words
negative_list = urllib.urlopen("http://www.unc.edu/~ncaren/haphazard/negative.txt").read().splitlines()

# Load nltk functions
from nltk.stem.lancaster import LancasterStemmer
from nltk.stem import PorterStemmer
from nltk.stem.snowball import EnglishStemmer

# Stem positive words
positive_lancaster = [LancasterStemmer().stem(i) for i in positive_list]
positive_porter = [PorterStemmer().stem(i) for i in positive_list]
positive_snowball = [EnglishStemmer().stem(i) for i in positive_list]
# Stem negative words
negative_lancaster = [LancasterStemmer().stem(i) for i in negative_list]
negative_porter = [PorterStemmer().stem(i) for i in negative_list]
negative_snowball = [EnglishStemmer().stem(i) for i in negative_list]

# Change whitespace to character sequence and convert to lower case
statements = [re.sub(r'\s', 'xqvz', i.lower()) for i in statements]
# Handle periods and dashes separately
statements = [re.sub(r'\.|-', 'xqvz', i) for i in statements]
# Remove punctuation
statements = [re.sub(r'\W', '', i) for i in statements]
# Replace white space
statements = [re.sub(r'xqvz', ' ', i) for i in statements]

from stop_words import get_stop_words
stop_words = get_stop_words('english')

from nltk import word_tokenize

counter = 1
dataset = {}
for statement in statements:
    words = [word for word in word_tokenize(statement) if word not in stop_words]
    current_statement = {}
    current_statement['statement_number'] = counter
    current_statement['speaker'] = words[0]
    current_statement['spoken_words'] = len(words) - 1
    current_statement['positive_words'] = len([word for word in words if word in positive_list])
    current_statement['negative_words'] = len([word for word in words if word in negative_list])
    current_statement['positive_lancaster'] = len([word for word in [LancasterStemmer().stem(i) for i in words] if word in positive_lancaster])
    current_statement['negative_lancaster'] = len([word for word in [LancasterStemmer().stem(i) for i in words] if word in negative_lancaster])
    current_statement['positive_porter'] = len([word for word in [PorterStemmer().stem(i) for i in words] if word in positive_porter])
    current_statement['negative_porter'] = len([word for word in [PorterStemmer().stem(i) for i in words] if word in negative_porter])
    current_statement['positive_snowball'] = len([word for word in [EnglishStemmer().stem(i) for i in words] if word in positive_snowball])
    current_statement['negative_snowball'] = len([word for word in [EnglishStemmer().stem(i) for i in words] if word in negative_snowball])
    dataset[counter] = current_statement
    counter += 1

import csv
# Open csv called Output for storing data
with open('HW1.csv', 'wb') as f:
  # Name variables for header in csv
  my_writer = csv.DictWriter(f, fieldnames=("Number", "Speaker", "WordCount", "Positive", "Negative", "LanPos", "LanNeg", "PortPos", "PortNeg", "SnowPos", "SnowNeg"))
  my_writer.writeheader()
  # Iterate over each element of each list of data
  for i in range(1,len(dataset)):
    # Save each data point in the corresponding row (by iteration) and column (by fieldname)
    my_writer.writerow({"Number":dataset[i]['statement_number'], "Speaker":dataset[i]['speaker'], "WordCount":dataset[i]['spoken_words'], "Positive":dataset[i]['positive_words'], "Negative":dataset[i]['negative_words'], "LanPos":dataset[i]['positive_lancaster'], "LanNeg":dataset[i]['negative_lancaster'], "PortPos":dataset[i]['positive_porter'], "PortNeg":dataset[i]['negative_porter'], "SnowPos":dataset[i]['positive_snowball'], "SnowNeg":dataset[i]['negative_snowball']})




