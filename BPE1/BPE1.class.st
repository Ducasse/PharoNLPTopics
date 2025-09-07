Class {
	#name : 'BPE1',
	#superclass : 'Object',
	#instVars : [
		'words',
		'pairs',
		'merges',
		'vocabulary',
		'pairsAssociateToWords',
		'wordsAssociatedToPairs',
		'wordsContainingFrequencyPairsAfterFusion'
	],
	#category : 'BPE1',
	#package : 'BPE1'
}

{ #category : 'merges' }
BPE1 >> addToMergesPair: aCollection mergedInto: aString [
	merges add: aCollection -> aString
]

{ #category : 'vocabulary' }
BPE1 >> addToVocabulary: aString [
	vocabulary add: aString 
]

{ #category : 'compute' }
BPE1 >> computePairs: aBag [
	aBag associationsDo: [ :association|self pairForAssociation:association ]
]

{ #category : 'vocabulary' }
BPE1 >> computeVocabulary [ 
	words do:[:each|each do:[:aChar|self addToVocabulary: aChar asString ]]
]

{ #category : 'accessing' }
BPE1 >> frequencyOfWord: aString [
	^words occurrencesOf: aString 
]

{ #category : 'api' }
BPE1 >> fromText: aText [
	self prepareWordsFromText: aText .
	self computePairs: words .
	self pairsAssociatedToWordsAdd: words .
	self wordsAssociatedToPairsAdd: words .
	self computeVocabulary .
]

{ #category : 'initialization' }
BPE1 >> initialize [ 
	super initialize .
	words := Bag new.
	vocabulary := Set new.
	merges := OrderedCollection new.
	pairs := Bag new.
	pairsAssociateToWords := Dictionary new.
	wordsAssociatedToPairs := Dictionary new.
]

{ #category : 'accessing' }
BPE1 >> merges [ 
	^merges 
]

{ #category : 'merges' }
BPE1 >> mergesOneStep [ 
	|newVocabularyItem pair|
	pair :=pairs sortedCounts first value.
	newVocabularyItem :=pair first , pair second.
	self addToVocabulary: newVocabularyItem .
	self addToMergesPair: pair mergedInto: newVocabularyItem .
	self updateWordsContainingFrequencyPairsFrom: pair to: newVocabularyItem .
	self pairsUpdate: pair .
	self updateCorpusFrom: pair .
	self pairsAssociatedToWordsAndWordsAssociatedToPairsUpdate: pair .
]

{ #category : 'compute' }
BPE1 >> neighboringPairsOfFrequencyPair:pair [ 
"Returns all adjacent pairs surrounding the given frequent pair."
	|bag|
	bag :=Bag new .
	(self wordsContainingFrequencyPairs: pair ) do: [ :word|(self wordsAssociatedToPairs at: word ) associationsDo:[:each |bag add: each key withOccurrences: (each value * (self occurrencesOf: word ))] ].
	^bag 
]

{ #category : 'accessing' }
BPE1 >> numberOfPairs [ 
	^pairs keys size 
]

{ #category : 'accessing' }
BPE1 >> occurrencesOf: aString [
	^words occurrencesOf: aString 
]

{ #category : 'compute' }
BPE1 >> pairForAssociation: anAssociation [
	|word|
	word:=anAssociation key.
	word overlappingPairsWithIndexDo: [ :a :b :index|pairs add:{a.b} withOccurrences:anAssociation value ]
]

{ #category : 'accessing' }
BPE1 >> pairOccurrencesOf: aString [
	^pairs occurrencesOf: aString 
]

{ #category : 'accessing' }
BPE1 >> pairs [
	^pairs 
]

{ #category : 'accessing' }
BPE1 >> pairsAssociatedToWords [
"Returns a dictionary with all pairs as keys, and for each pair, the values are the set of tokens that contain it."
	^pairsAssociateToWords 
]

{ #category : 'compute' }
BPE1 >> pairsAssociatedToWordsAdd:aBag [
"Add an element to pairsAssociatedToWords."
	aBag associationsDo: [ :association| 1 to:(association key size -1) do:[:i|
			|pair set| pair:=Array with: (association key at:i) with: (association key at: i+1).
			set:=(self pairsAssociatedToWords at: pair ifAbsent:[Set new ]).
			set add: association key.
			pairsAssociateToWords at: pair put: set ]. ]
]

{ #category : 'compute' }
BPE1 >> pairsAssociatedToWordsAndWordsAssociatedToPairsUpdate:pair [ 
"Updates to the pairsAssociatedToWords and wordsAssociatedToPairs after merging."
	|c|
	c:=Set new.
	(self wordsContainingFrequencyPairs: pair ) do:[:each | c add: each ].
	c do: [:word|(self wordsAssociatedToPairs at: word ) associationsDo: [:each|(self pairsAssociatedToWords  at: each key) remove: word ifAbsent:[]. (self pairsAssociatedToWords at: each key) isEmpty ifTrue: [self pairsAssociatedToWords removeKey: each key]].self wordsAssociatedToPairs removeKey: word].
	self pairsAssociatedToWordsAdd: wordsContainingFrequencyPairsAfterFusion .
	self wordsAssociatedToPairsAdd: wordsContainingFrequencyPairsAfterFusion 
]

{ #category : 'compute' }
BPE1 >> pairsUpdate: pair [ 
"Updates to the pairs after merging."
	(self neighboringPairsOfFrequencyPair: pair) associationsDo: [:each| self removeOccurenceOf: each ].
	self computePairs: wordsContainingFrequencyPairsAfterFusion 
]

{ #category : 'compute' }
BPE1 >> prepareWordsFromText: aText [
	|rawWords|
	rawWords :=(aText substrings: {Character space . Character cr . Character tab}).
	words addAll: (rawWords collect: [:each|
		|col|
		col:=OrderedCollection new: each size + 1 .
		each do: [:aChar|col add: aChar asString].
		col add:'_'.
		col ] )
]

{ #category : 'compute' }
BPE1 >> removeOccurenceOf: pair [
"Updates to the occurrence of a pair."
	|count|
	count :=self pairOccurrencesOf: pair key.
	pairs removeKey: pair key ifAbsent: [].
	pairs add: pair key withOccurrences: count - pair value.
	(pairs occurrencesOf: pair key)=0 ifTrue: [ pairs removeKey:pair key ifAbsent: []]
]

{ #category : 'vocabulary' }
BPE1 >> uniqueWords [ 
	^words keys 
]

{ #category : 'compute' }
BPE1 >> updateCorpusFrom: pair [
"Corpus updates following the merging of frequent pairs." 
	wordsContainingFrequencyPairsAfterFusion do: [ :each|words add:each ].
	(self wordsContainingFrequencyPairs: pair ) do: [ :word|words removeKey: word ifAbsent: []]
]

{ #category : 'compute' }
BPE1 >> updateWordsContainingFrequencyPairsFrom: pair to: newVocabularyItem [
"Modification on tokens containing the frequent pairs."
	wordsContainingFrequencyPairsAfterFusion :=Bag new .
	(self wordsContainingFrequencyPairs: pair ) do: [ :word|wordsContainingFrequencyPairsAfterFusion add:(word copyReplaceAll: pair with: {newVocabularyItem }) withOccurrences:(words occurrencesOf: word ) ]
]

{ #category : 'accessing' }
BPE1 >> vocabulary [
	^vocabulary 
]

{ #category : 'vocabulary' }
BPE1 >> vocabularySize [ 
	^vocabulary size 
]

{ #category : 'accessing' }
BPE1 >> words [
	^words 
]

{ #category : 'accessing' }
BPE1 >> wordsAssociatedToPairs [
"Returns a dictionary with tokens as keys, and for each token, the values are the pairs associated with it."
	^wordsAssociatedToPairs 
]

{ #category : 'compute' }
BPE1 >> wordsAssociatedToPairsAdd: aBag [
"Add an element to wordsAssociatedToPairs."
	aBag associationsDo: [ :association||bag| bag:=Bag new. 
		1 to: (association key size - 1) do:[:i|
			bag add: (Array with: (association key at:i ) with: (association key at: i+1))].
		wordsAssociatedToPairs at: association key put:bag ]
]

{ #category : 'compute' }
BPE1 >> wordsContainingFrequencyPairs: pair [
"Returns the set of all tokens containing the given frequent pair."
	^self pairsAssociatedToWords at: pair 
]

{ #category : 'accessing' }
BPE1 >> wordsContainingFrequencyPairsAfterFusion [
"Returns the changes applied to tokens that include the frequent pairs following their merging."
	^wordsContainingFrequencyPairsAfterFusion 
]
