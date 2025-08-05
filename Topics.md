# Natural language processing support

The goal of this topic is to implement in Pharo some algorithms for natural text processing.
All the code should be covered with nice tests.

## Byte Pair Encoder

Byte Pair Encoder is a simple approach to encode frequent sequence
of character in texts.
	https://en.wikipedia.org/wiki/Byte_pair_encoding
	https://huggingface.co/learn/llm-course/en/chapter6/5

We did a first naive implementation in Pharo
	https://github.com/Ducasse/BytePairEncoder/

A first task is to revisit this implementation and see how we can make it faster. 
The implementation rebuilds the complete set of information each time and it
is time consuming.

The student should profile and benchmark the implementation.

## WordPiece
	Implement a library WordPiece for Pharo
	
	https://huggingface.co/learn/llm-course/en/chapter6/6

## Unigram
	Implement a library for unigram for Pharo
	https://huggingface.co/learn/llm-course/en/chapter6/7
