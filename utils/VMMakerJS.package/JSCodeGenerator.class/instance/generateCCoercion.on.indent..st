JS translation
generateCCoercion: msgNode on: aStream indent: level
	"Generate the JS code for this message onto the given stream."
	| expr cType |.
	expr := msgNode args first.
	cType := msgNode args second value.
	(expr isSend and: [expr receiver name = 'interpreterProxy' and: [expr selector = #firstIndexableField:]]) ifTrue: [
		cType := msgNode args second value.
		self emitJSExpression: expr args first on: aStream.
		cType = 'unsigned char *' ifTrue: [^aStream nextPutAll: '.bytes'].
		cType = 'unsigned int *' ifTrue: [^aStream nextPutAll: '.words'].
		cType = 'int *' ifTrue: [^aStream nextPutAll: '.wordsAsInt32Array()'].
		cType = 'short *' ifTrue: [^aStream nextPutAll: '.wordsAsInt16Array()'].
		cType = 'float *' ifTrue: [^aStream nextPutAll: '.wordsAsFloat32Array()'].
		cType = 'double *' ifTrue: [^aStream nextPutAll: '.wordsAsFloat64Array()'].
		self halt.
	] ifFalse: [
		(#('int') includes: cType) ifTrue: [
			aStream nextPutAll: '('.
			self emitJSExpression: expr on: aStream.
			^aStream nextPutAll: '|0)'].
		(#('unsigned int' 'unsigned' ) includes: cType) ifTrue: [
				aStream nextPutAll: '('.
				self emitJSExpression: expr on: aStream.
				^ aStream nextPutAll: '>>>0)'].
		((#('double' 'float') includes: cType) or: [('sqInt (*)(*)'match: cType)
			or: [#(transformPoint:into:) includes: currentMethod selector]])
			ifFalse: [self halt].
		self emitJSExpression: expr on: aStream.
	]
