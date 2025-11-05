Class {
	#name : 'BaselineOfBPE1',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfBPE1',
	#package : 'BaselineOfBPE1'
}

{ #category : 'baselines' }
BaselineOfBPE1 >> baseline: spec [
    <baseline>
    spec for: #common do: [
			spec
				package: #'BPE1'.
			spec
				group: 'Core' with: #( 'BPE1' );
				group: 'default'
				with: #( 'BPE1' ) ]
]
