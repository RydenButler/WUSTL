import re, os
from nltk import word_tokenize
from nltk.stem import PorterStemmer
from stop_words import get_stop_words
from nltk import trigrams
import csv

sessions_corpus = os.listdir('./Sessions/')

sessions = {}
for text in sessions_corpus:
	current_text = {}
	current_text['month'] = text[2:5]
	current_text['year'] = text[5:9]
	current_text['day'] = text[0:2]
	current_text['author'] = 'Sessions'
	current_text['text'] = open('./Sessions/'+text, 'r').read()
	sessions[text[:-4]] = current_text

shelby_corpus = os.listdir('./Shelby/')

shelby = {}
for text in shelby_corpus:
	current_text = {}
	current_text['month'] = text[2:5]
	current_text['year'] = text[5:9]
	current_text['day'] = text[0:2]
	current_text['author'] = 'Shelby'
	current_text['text'] = open('./Shelby/'+text, 'r').read()
	shelby[text[:-4]] = current_text

stop_words = get_stop_words('english')
stop_words.extend(['shelby', 'sessions', 'richard', 'jeff', 'email', 'press', 'room', 'member', 'senate'])
stop_words = [PorterStemmer().stem(i) for i in stop_words]

for key in sessions.keys():
	# Remove punctuation, convert to lowercase, and tokenize
	sessions[key]['text'] = word_tokenize(re.sub(r'\W', ' ', sessions[key]['text'].lower()))
	# Apply Porter Stemmer and discard stop words
	sessions[key]['text'] = [PorterStemmer().stem(word) for word in sessions[key]['text'] if word not in stop_words]

for key in shelby.keys():
	# Remove punctuation, convert to lowercase, and tokenize
	shelby[key]['text'] = word_tokenize(re.sub(r'\W', ' ', shelby[key]['text'].lower()))
	# Apply Porter Stemmer and discard stop words
	shelby[key]['text'] = [PorterStemmer().stem(word) for word in shelby[key]['text'] if word not in stop_words]

for key in sessions.keys():
	sessions[key]['trigram'] = [i for i in trigrams(sessions[key]['text'])]

for key in shelby.keys():
	shelby[key]['trigram'] = [i for i in trigrams(shelby[key]['text'])]

unigram_count = {}
trigram_count = {}

for key in sessions.keys():
	for word in sessions[key]['text']:
		if word in unigram_count.keys():
			unigram_count[word] += 1
			continue
		else: 
			unigram_count[word] = 1
	for tri in sessions[key]['trigram']:
		if tri in trigram_count.keys():
			trigram_count[tri] += 1
			continue
		else: 
			trigram_count[tri] = 1

for key in shelby.keys():
	for word in shelby[key]['text']:
		if word in unigram_count.keys():
			unigram_count[word] += 1
			continue
		else: 
			unigram_count[word] = 1
	for tri in shelby[key]['trigram']:
		if tri in trigram_count.keys():
			trigram_count[tri] += 1
			continue
		else: 
			trigram_count[tri] = 1

max_unigrams = []
max_trigrams = []
for i in range(0,1000):
	largest_unigram = max(unigram_count, key=unigram_count.get)
	max_unigrams.append(largest_unigram)
	unigram_count.pop(largest_unigram)
	

for i in range(0,500):
	largest_trigram = max(trigram_count, key=trigram_count.get)
	max_trigrams.append(largest_trigram)
	trigram_count.pop(largest_trigram)

clean_trigrams = []
for i in max_trigrams:
	one = i[0]
	two = i[1]
	three = i[2]
	clean_trigrams.append(str(one)+'.'+str(two)+'.'+str(three))

with open('HW2Unigrams.csv', 'wb') as outcsv:
    writer = csv.writer(outcsv)
    header = ['speaker']
    header.extend(max_unigrams)
    writer.writerow(header)
    for key in sessions.keys():
    	word_count = []
    	for word in max_unigrams:
    		word_count.append(sessions[key]['text'].count(word))
    	row = ['sessions']
    	row.extend(word_count)
    	writer.writerow(row)
    for key in shelby.keys():
    	word_count = []
    	for word in max_unigrams:
    		word_count.append(shelby[key]['text'].count(word))
    	row = ['shelby']
    	row.extend(word_count)
    	writer.writerow(row)

with open('HW2Trigrams.csv', 'wb') as outcsv:
    writer = csv.writer(outcsv)
    header = ['speaker']
    header.extend(clean_trigrams)
    writer.writerow(header)
    for key in sessions.keys():
    	word_count = []
    	for word in max_trigrams:
    		word_count.append(sessions[key]['trigram'].count(word))
    	row = ['sessions']
    	row.extend(word_count)
    	writer.writerow(row)
    for key in shelby.keys():
    	word_count = []
    	for word in max_trigrams:
    		word_count.append(shelby[key]['trigram'].count(word))
    	row = ['shelby']
    	row.extend(word_count)
    	writer.writerow(row)

