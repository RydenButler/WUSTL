import sys  
import re, os
from nltk import word_tokenize
from nltk.stem import PorterStemmer
from stop_words import get_stop_words
import json
import csv

reload(sys)  
sys.setdefaultencoding('utf8')

# Question 1
with open('nyt_ac.json') as data_file:    
    data = json.load(data_file, encoding='utf-8')

# data is nested dictionary:
# data:
# - body
# |- title
# |- body_text
# - meta
# |- taxonomic_classes
# |- publication_day_of_month
# |- publication_year
# |- online_sections
# |- publication_month
# |- dsk
# |- print_page_number
# |- alternate_url
# |- print_section
# |- publication_day_of_week
# |- print_column
# |- slug

for doc in data:
	slug = doc['meta']['slug'][:-3]
	filename = os.path.abspath(os.curdir) + "/Texts/"+str(slug)+".txt"
	text = u' '.join((doc['body']['title'], '\n\n', doc['body']['body_text'])).encode('utf-8')
	with open(filename, "w") as f:
		f.write(text.encode('utf8'))

stop_words = get_stop_words('english')
stop_words = [PorterStemmer().stem(i) for i in stop_words]

titles = [i['body']['title'] for i in data]
texts = [i['body']['body_text'] for i in data]
desks = [i['meta']['dsk'] for i in data]

stemmed_texts = []
for text in texts:
	# Remove punctuation, convert to lowercase, and tokenize
	tokenized = word_tokenize(re.sub(r'\W', ' ', text.lower()))
	# Apply Porter Stemmer and discard stop words
	stemmed = [PorterStemmer().stem(word) for word in tokenized if word not in stop_words]
	# Add to list of stemmed texts
	stemmed_texts.append(stemmed)

unigram_count = {}

for text in stemmed_texts:
	for word in text:
		if word in unigram_count.keys():
			unigram_count[word] += 1
			continue
		else: 
			unigram_count[word] = 1

max_unigrams = []
for i in range(0,1000):
	largest_unigram = max(unigram_count, key=unigram_count.get)
	max_unigrams.append(largest_unigram)
	unigram_count.pop(largest_unigram)

with open('HW3DTM.csv', 'wb') as outcsv:
    writer = csv.writer(outcsv)
    header = ['Desk']
    header.extend(max_unigrams)
    writer.writerow(header)
    for i in range(len(stemmed_texts)):
    	word_count = []
    	for word in max_unigrams:
    		word_count.append(stemmed_texts[i].count(word))
    	row = [desks[i]]
    	row.extend(word_count)
    	writer.writerow(row)


# Question 2

import urllib
# Read in positive words
positive_list = urllib.urlopen("http://www.unc.edu/~ncaren/haphazard/positive.txt").read().splitlines()
positive_porter = [PorterStemmer().stem(i) for i in positive_list]
# Read in negative words
negative_list = urllib.urlopen("http://www.unc.edu/~ncaren/haphazard/negative.txt").read().splitlines()
negative_porter = [PorterStemmer().stem(i) for i in negative_list]

# Create empty lists for scores
positive_scores = []
negative_scores = []
# Iterate over texts and count scores
for text in stemmed_texts:
	positive_scores.append(len([word for word in text if word in positive_porter]))
	negative_scores.append(len([word for word in text if word in negative_porter]))

difference_scores = 


