Class {
	#name : 'BaselineOfBPE1',
	#superclass : 'BaselineOf',
	#category : 'BPE1-Baseline',
	#package : 'BPE1-Baseline'
}

{ #category : 'baselines' }
BaselineOfBPE1 >> baseline: spec [
    <baseline>
    spec for: #common do: [
        spec package: 'BPE1'.
        spec group: 'default' with: #('BPE1').
    ].

]
