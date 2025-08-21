Class {
	#name : 'TestBPE1',
	#superclass : 'TestCase',
	#category : 'BPE1',
	#package : 'BPE1'
}

{ #category : 'tests' }
TestBPE1 >> testBuildVocabularyProducesCorrectVocabulary [

	| enc |
	enc := BPE1 new. 
	enc prepareWordsFromText: self text.
	enc computeVocabulary.
	self 
		assertCollection: enc vocabulary asSet
		hasSameElements: { '_' . 'd' . 'e' . 'i' . 'l' . 'f' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
TestBPE1 >> testBuildVocabularyProducesCorrectVocabularyText2 [

	| enc |
	enc := BPE1 new. 
	enc prepareWordsFromText: self text2.
	enc computeVocabulary.
	self assertCollection: enc vocabulary asSet hasSameElements: { '_' . 'd' . 'e' . 'i' . 'l' . 'n' . 'o' . 'r' . 's' . 't' . 'w'} asSet
]

{ #category : 'tests' }
TestBPE1 >> testComputePairs [

	| enc |
	enc := BPE1 new. 
	enc fromText: self text.
	
	self assert: (enc pairOccurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairOccurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairOccurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairOccurrencesOf: {'s' .'t'}) equals: 13. 
	self assert: (enc pairOccurrencesOf: {'e' . 's'}) equals: 13. 
	self assert: (enc pairOccurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairOccurrencesOf: {'t' . '_'}) equals: 13. 
	
	self assert: enc numberOfPairs equals: 15
]

{ #category : 'tests' }
TestBPE1 >> testComputePairsText2 [

	| enc |
	enc := BPE1 new. 
	enc fromText: self text2.
	
	self assert: (enc pairOccurrencesOf: {'e' .'s'}) equals: 9. 
	self assert: (enc pairOccurrencesOf: {'i'. 'd'}) equals: 3. 
	self assert: (enc pairOccurrencesOf: {'o' .'w'}) equals: 7. 
	self assert: (enc pairOccurrencesOf: {'s'. 't'}) equals: 9. 
	self assert: (enc pairOccurrencesOf: {'w'. 'e'}) equals: 8. 
	self assert: (enc pairOccurrencesOf: {'w'. 'i'}) equals: 3. 
	self assert: (enc pairOccurrencesOf: {'t'.'_'}) equals: 9. 
	
	 "#('lo' 't_' 'er' 'r_' 'st' 'wi' 'es' 'ne' 'ow' 'we' 'w_' 'id' 'de' 'ew')"
	self assert: enc numberOfPairs equals: 14
]

{ #category : 'tests' }
TestBPE1 >> testMergeOneStepAddMergeToMergeList [

	| enc |
	enc := BPE1 new. 
	enc fromText: self text.
	enc computeVocabulary.
	
	self assert: enc merges isEmpty.
	enc mergesOneStep .
	self assert: enc merges first equals: #('e' 's')->'es' 
]

{ #category : 'tests' }
TestBPE1 >> testMergeOneStepIncreaseVocabularyAndMerges [

	| enc mergeOldSize |
	enc := BPE1 new. 
	enc fromText: self text.
	enc computeVocabulary.
	
	self assert: enc vocabulary size equals: 12.
	mergeOldSize := enc merges size.
	enc mergesOneStep .
	self assert: (enc vocabulary includes: 'es').
	self assert: enc merges size equals: mergeOldSize + 1.
	self assert: enc vocabulary size equals: 13
]

{ #category : 'tests' }
TestBPE1 >> testMergeOneStepRecomputePairs [

	| enc finestFrequency |
	enc := BPE1 new. 
	enc fromText: self text.
	finestFrequency := enc frequencyOfWord: #('f' 'i' 'n' 'es' 't').
	enc computeVocabulary.
	
	enc mergesOneStep .
	
	self assert: (enc pairOccurrencesOf: {'o' . 'l'}) equals: 10. 
	self assert: (enc pairOccurrencesOf: {'l' . 'd'}) equals: 10. 
	self assert: (enc pairOccurrencesOf: {'l' .'d'}) equals: 10. 
	self assert: (enc pairOccurrencesOf: {'es' . 't'}) equals: 13. 
	self assert: (enc pairOccurrencesOf: {'l' .'o'}) equals: 4. 
	self assert: (enc pairOccurrencesOf: {'t' . '_'}) equals: 13. 
	self assert: (enc pairOccurrencesOf: {'w' . 'es'}) equals: 4. 
	self assert: (enc pairOccurrencesOf: {'n' . 'es'}) equals: 9. 
]

{ #category : 'tests' }
TestBPE1 >> testMergeOneStepUpdatesCorpus [

	| enc finestFrequency |
	enc := BPE1 new. 
	enc fromText: self text.
	finestFrequency := enc frequencyOfWord: #('f' 'i' 'n' 'es' 't').

	enc mergesOneStep .
	"should have a better assert"
	self assert: (enc uniqueWords includes: #('l' 'o' 'w' 'es' 't' '_') asOrderedCollection).
	self assert: (enc uniqueWords includes: #('f' 'i' 'n' 'es' 't' '_') asOrderedCollection). 
	self assert: (enc frequencyOfWord: #('f' 'i' 'n' 'es' 't' '_')) equals: finestFrequency.
]

{ #category : 'tests' }
TestBPE1 >> testPairsAssociatedToWords [ 
	|b|
	b:=BPE1 new.
	b fromText: self text. 
	self assertCollection: b pairsAssociatedToWords hasSameElements: {#('o' 'l') -> {#('o' 'l' 'd' '_')asOrderedCollection . #('o' 'l' 'd' 'e' 'r' '_')asOrderedCollection }asSet . #('l' 'd') -> {#('o' 'l' 'd' '_')asOrderedCollection . #('o' 'l' 'd' 'e' 'r' '_')asOrderedCollection }asSet . #('d' '_') ->{#('o' 'l' 'd' '_')asOrderedCollection }asSet . #('d' 'e') -> {#('o' 'l' 'd' 'e' 'r' '_')asOrderedCollection }asSet . #('e' 'r') -> {#('o' 'l' 'd' 'e' 'r' '_')asOrderedCollection }asSet . #('r' '_') -> {#('o' 'l' 'd' 'e' 'r' '_')asOrderedCollection }asSet . #('f' 'i') -> {#('f' 'i' 'n' 'e' 's' 't' '_')asOrderedCollection }asSet . #('i' 'n') -> {#('f' 'i' 'n' 'e' 's' 't' '_')asOrderedCollection }asSet . #('n' 'e') -> {#('f' 'i' 'n' 'e' 's' 't' '_')asOrderedCollection }asSet . #('e' 's') -> {#('f' 'i' 'n' 'e' 's' 't' '_')asOrderedCollection . #('l' 'o' 'w' 'e' 's' 't' '_')asOrderedCollection }asSet . #('s' 't') -> {#('f' 'i' 'n' 'e' 's' 't' '_')asOrderedCollection . #('l' 'o' 'w' 'e' 's' 't' '_')asOrderedCollection }asSet . #('t' '_') -> {#('f' 'i' 'n' 'e' 's' 't' '_')asOrderedCollection . #('l' 'o' 'w' 'e' 's' 't' '_')asOrderedCollection }asSet . #('l' 'o') -> {#('l' 'o' 'w' 'e' 's' 't' '_')asOrderedCollection }asSet . #('o' 'w') -> {#('l' 'o' 'w' 'e' 's' 't' '_')asOrderedCollection }asSet . #('w' 'e') -> {#('l' 'o' 'w' 'e' 's' 't' '_')asOrderedCollection }asSet } asDictionary .
]

{ #category : 'tests' }
TestBPE1 >> testPrepareWordsFromText [

	| enc |
	enc := BPE1 new. 
	enc fromText: self text.
	self assert: (enc occurrencesOf: #('o' 'l' 'd' '_') asOrderedCollection) equals: 7. 
	self assert: (enc occurrencesOf: #('o' 'l' 'd' 'e' 'r' '_') asOrderedCollection) equals: 3. 
	self assert: (enc occurrencesOf: #('f' 'i' 'n' 'e' 's' 't' '_') asOrderedCollection) equals: 9. 
	self assert: (enc occurrencesOf: #('l' 'o' 'w' 'e' 's' 't' '_') asOrderedCollection) equals: 4. 
]

{ #category : 'tests' }
TestBPE1 >> testTwoMerges [

	| enc |
	enc := BPE new. 
	enc fromText: self text.
	enc computeVocabulary.
	enc mergesOneStep .
	enc mergesOneStep .
	
	self assert: enc merges1 first equals: #('e' 's')->'es'. 
	self assert: enc merges1 second equals: #('es' 't')->'est'. 
]

{ #category : 'tests' }
TestBPE1 >> testWordsAssociatedToPairs [
	|b|
	b:=BPE1 new.
	b fromText: self text. 
	self assertCollection: b wordsAssociatedToPairs hasSameElements: { #('o' 'l' 'd' '_')asOrderedCollection ->({#('o' 'l') . #('l' 'd') . #('d' '_')})asBag . #('o' 'l' 'd' 'e' 'r' '_')asOrderedCollection ->({#('o' 'l') . #('l' 'd') . #('d' 'e') . #('e' 'r') . #('r' '_')})asBag . #('f' 'i' 'n' 'e' 's' 't' '_')asOrderedCollection ->({#('f' 'i') . #('i' 'n') . #('n' 'e') . #('e' 's') . #('s' 't') . #('t' '_')})asBag . #('l' 'o' 'w' 'e' 's' 't' '_')asOrderedCollection ->({#('l' 'o') . #('o' 'w') . #('w' 'e') . #('e' 's') . #('s' 't') . #('t' '_')})asBag } asDictionary .
]

{ #category : 'accessing' }
TestBPE1 >> text [
	^ 'old old old old old old old 
older older older
finest finest finest finest finest finest finest finest finest 
lowest lowest lowest lowest 
'
]

{ #category : 'accessing structure variables' }
TestBPE1 >> text2 [
	^ '
low low low low low
lower lower
newest newest newest newest newest newest 
widest widest widest'
]
