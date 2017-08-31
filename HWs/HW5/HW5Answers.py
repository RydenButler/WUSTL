import sys  
import re, os
from nltk import word_tokenize
from nltk.stem import PorterStemmer
from stop_words import get_stop_words
import json
import csv

reload(sys)  
sys.setdefaultencoding('utf8')

# Question 2
mach_corpus = os.listdir('./MachText/')

mach = []
for text in mach_corpus:
	mach.append(open('./MachText/'+text, 'r').read())

stop_words = get_stop_words('english')
stop_words = [PorterStemmer().stem(i) for i in stop_words]

stemmed_texts = []
for text in mach:
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
for i in range(0,500):
	largest_unigram = max(unigram_count, key=unigram_count.get)
	max_unigrams.append(largest_unigram)
	unigram_count.pop(largest_unigram)

with open('HW5DTM.csv', 'wb') as outcsv:
    writer = csv.writer(outcsv)
    header = max_unigrams
    writer.writerow(header)
    for i in range(len(stemmed_texts)):
    	word_count = []
    	for word in max_unigrams:
    		word_count.append(stemmed_texts[i].count(word))
    	row = word_count
    	writer.writerow(row)