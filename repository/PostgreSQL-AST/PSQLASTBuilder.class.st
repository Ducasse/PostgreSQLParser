Class {
	#name : #PSQLASTBuilder,
	#superclass : #PSQLGrammar,
	#category : 'PostgreSQL-AST-Builder'
}

{ #category : #'accessing - blocks' }
PSQLASTBuilder >> binaryOperatorBlock [
	^ [ :exp1 :op :exp2 |
			PSQLASTBinaryOperator new
				operator: op;
				left: exp1;
				right: exp2;
				yourself ]
]

{ #category : #accessing }
PSQLASTBuilder >> columnReference [
	^ super columnReference ==> [ :tokens |
		tokens first ifNotNil: [ 
			PSQLASTAttributeAccess new
				accessed: tokens first first;
				attributeIdentifier: tokens second;
				yourself ]
			ifNil: [ 
				tokens second ] ]
]

{ #category : #expression }
PSQLASTBuilder >> commaSubscriptWith: expressionParser [
	^ (super commaSubscriptWith: expressionParser) ==> [ :tokens |
		PSQLASTArrayConstructor new
			items: ((tokens copyFrom: 2 to: tokens size - 1) first reject: [ :object | object = $, ] thenCollect: #first);
			yourself ]
]

{ #category : #expression }
PSQLASTBuilder >> compositeValueWith: anExpressionParser [
	^ (super compositeValueWith: anExpressionParser)
		==> [ :tokens |
			|node|
			node := PSQLCompositeValue new
						items: (tokens second reject: [ :item | item = $, ] thenCollect: #first);
						yourself.
			tokens fourth ifNotNil: [ 
				node := PSQLASTBinaryOperator new
							operator: '::';
							left: node;
							right: (PSQLASTIdentifier new identifier: ((tokens fourth second reject: [ :item | item first = Character space ] thenCollect: [ :item | (item first reject: #isNil) first ]) joinUsing: ' '); yourself) ].
			node ]
]

{ #category : #expression }
PSQLASTBuilder >> conditionalExpression [
	^ super conditionalExpression ==> [ :tokens |
		PSQLConditionalExpression new
			conditionsToExpressions: (tokens second collect: [ :item | item second -> item fourth ]);
			elseExpression: tokens third second;
			yourself ]
]

{ #category : #expression }
PSQLASTBuilder >> expressionParserTermFor: expressionParser [
	^ (super expressionParserTermFor: expressionParser) ==> [ :tokens |
		tokens second isNil
			ifTrue: [ tokens first ]
			ifFalse: [ 
				PSQLASTBinaryOperator new
					operator: '::';
					left: tokens first;
					right: (PSQLASTIdentifier new identifier: (tokens second second joinUsing: ' '); yourself) ] ]
]

{ #category : #expression }
PSQLASTBuilder >> functionCallParserWith: expressionParser [
	^ (super functionCallParserWith: expressionParser)
		==> [ :tokens |
			PSQLFunctionCall new
				functionIdentifier: tokens first;
				argumentsList: (tokens second second reject: [ :item | item = $, or: [ item first isArray ] ] thenCollect: #first);
				argumentsDictionary: (tokens second second reject: [ :item | item = $, or: [ item first isArray not ] ] thenCollect: [ :array | array first first -> array first third ]) asDictionary;
				yourself ]
]

{ #category : #accessing }
PSQLASTBuilder >> identifier [
	^ super identifier ==> [ :tokens | 
		PSQLASTIdentifier new
			identifier: tokens second;
			yourself ]
]

{ #category : #accessing }
PSQLASTBuilder >> identifierOrKeyword [
	^ super identifierOrKeyword ==> [ :tokens | String newFrom: tokens flattened ]
]

{ #category : #accessing }
PSQLASTBuilder >> isNotNull [
	^ super isNotNull ==> [ :tokens | tokens joinUsing: ' ' ]
]

{ #category : #accessing }
PSQLASTBuilder >> isNull [
	^ super isNull ==> [ :tokens | tokens joinUsing: ' ' ]
]

{ #category : #accessing }
PSQLASTBuilder >> numericConstant [
	^ super numericConstant ==> [ :tokens |
		PSQLASTNumericConstant new
			content: (String newFrom: (tokens flattened reject: #isNil));
			yourself ]
]

{ #category : #expression }
PSQLASTBuilder >> parenthesedExpressionParserWith: expressionParser [
	^ (super parenthesedExpressionParserWith: expressionParser)
			==> [ :tokens | 
				PSQLParenthesedExpression new
					expression: tokens second;
					yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlAliasDeclaration [
	^ super plpgsqlAliasDeclaration ==> [ :tokens |
		PSQLPlpgSQLASTAliasDeclaration new
			identifier: tokens first;
			aliased: tokens fourth;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlArrayLoop [
	^ super plpgsqlArrayLoop ==> [ :tokens |
		PSQLPlpgSQLASTArrayLoop new
			beginLabel: tokens first;
			endLabel: tokens last;
			target: tokens third;
			sliceNumber: (tokens fourth ifNotNil: [ :arr | arr second ]);
			arrayExpression: tokens seventh;
			statements: tokens ninth;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlAssignmentLeftPart [
	^ super plpgsqlAssignmentLeftPart ==> [ :tokens |
			|target|
			target := tokens first.
			tokens second do: [ :subTokens | "First manage attribute access."
				target := PSQLASTAttributeAccess new
								accessed: target;
								attributeIdentifier: subTokens second;
								yourself ].
			tokens third do: [ :subscriptTokens | "Then manage subscripts."
				target := PSQLSubscript new
								target: target;
								subscriptExpression: subscriptTokens second;
								yourself ].
			target ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlAssignmentStatement [
	^ super plpgsqlAssignmentStatement ==> [ :tokens |
		PSQLPlpgSQLASTAssignment new
			target: tokens first;
			operator: tokens second;
			toAssign: tokens third;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlBeginLabel [
	^ super plpgsqlBeginLabel ==> [ :tokens | tokens second ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlBlock [
	^ super plpgsqlBlock ==> [ :tokens |
		PSQLPlpgSQLASTBlock new
			label: tokens first;
			declarations: (tokens second ifNotNil: #second);
			statements: tokens fourth;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlClassicDeclaration [
	^ super plpgsqlClassicDeclaration ==> [ :tokens |
		PSQLPlpgSQLASTClassicDeclaration new
			identifier: tokens first;
			isConstant: tokens second isNotNil;
			type: tokens third;
			isNotNull: tokens fourth isNotNil;
			defaultExpression: (tokens fifth ifNotNil: #second);
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlContinueStatement [
	^ super plpgsqlContinueStatement ==> [ :tokens |
		PSQLPlpgSQLASTContinue new
			label: tokens second;
			whenExpression: tokens third second;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlCopyTypeDeclaration [
	^ super plpgsqlCopyTypeDeclaration ==> [ :tokens |
		PSQLPlpgSQLASTCopyTypeDeclaration new
			identifier: tokens first;
			accessToCopyType: (PSQLASTAttributeAccess new
											attributeIdentifier: tokens second;
											accessed: tokens fourth;
											yourself);
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlDeclarationType [
	^ super plpgsqlDeclarationType ==> [ :tokens |
		PSQLPlpgSQLASTType new
					identifier: (PSQLASTIdentifier new
										identifier: (tokens sixth joinUsing: ' ');
										yourself);
					size: (tokens seventh ifNotNil: [ :array | array second content asNumber ]);
					dimensions: (tokens eighth ifNotNil: [ :array | array size ]);
					yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlForLoop [
	^ super plpgsqlForLoop ==> [ :tokens |
		PSQLPlpgSQLASTForLoop new
			beginLabel: tokens first;
			endLabel: tokens last;
			statements: (tokens at: 11);
			target: tokens third;
			fromExpression: tokens sixth;
			toExpression: tokens eighth;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlIfThen [
	^ super plpgsqlIfThen ==> [ :tokens |
		PSQLPlpgSQLASTIf new
			conditionToStatements: { tokens second -> tokens fourth };
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlIfThenElse [
	^ super plpgsqlIfThenElse ==> [ :tokens |
		PSQLPlpgSQLASTIf new
			conditionToStatements: { tokens second -> tokens fourth };
			elseStatements: tokens sixth;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlIfThenElsif [
	^ super plpgsqlIfThenElsif ==> [ :tokens |
		PSQLPlpgSQLASTIf new
			conditionToStatements: { tokens second -> tokens fourth } , (tokens fifth collect: [ :subTokens | subTokens second -> subTokens fourth ]);
			elseStatements: (tokens sixth ifNotNil: #second);
			yourself ]
]

{ #category : #accessing }
PSQLASTBuilder >> plpgsqlIndexParameter [
	^ super plpgsqlIndexParameter ==> [ :tokens | 
		PSQLASTIdentifier new
			identifier: '$',(String newFrom: tokens second);
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlLabel [
	^ super plpgsqlLabel ==> [ :tokens |
		PSQLPlpgSQLASTBlockLabel labelContent: tokens identifier ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlLoopLoop [
	^ super plpgsqlLoopLoop ==> [ :tokens |
		PSQLPlpgSQLASTLoop new
			beginLabel: tokens first;
			endLabel: tokens last;
			statements: tokens third;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlQueryResultsLoop [
	^ super plpgsqlQueryResultsLoop ==> [ :tokens |
		PSQLPlpgSQLASTQueryResultsLoop new
			beginLabel: tokens first;
			endLabel: tokens last;
			statements: tokens seventh;
			target: tokens third;
			query: tokens fifth;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlRaiseStatement1 [
	^ super plpgsqlRaiseStatement1 ==> [ :tokens |
		PSQLPlpgSQLASTRaiseStatement new
			level: tokens second;
			formatString: tokens third;
			formatExpressions: (tokens fourth reject: [ :item | item = $, or: [ item isArray and: [ item isEmpty ] ] ]);
			usingAssocs: tokens fifth;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlRaiseStatement2 [
	^ super plpgsqlRaiseStatement2 ==> [ :tokens |
		 ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlRaiseStatement3 [
	^ super plpgsqlRaiseStatement3 ==> [ :tokens |
		 ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlRaiseStatement4 [
	^ super plpgsqlRaiseStatement4 ==> [ :tokens |
		 ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlRaiseStatement5 [
	^ super plpgsqlRaiseStatement5 ==> [ :tokens |
		PSQLPlpgSQLASTRaiseStatement new ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlRaiseUsingOptions [
	^ super plpgsqlRaiseUsingOptions ==> [ :tokens |
		tokens second reject: [ :item  | item = $, ] thenCollect: [ :arr |
			arr first first -> arr first third ] ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlRecordDeclaration [
	^ super plpgsqlRecordDeclaration ==> [ :tokens |
		PSQLPlpgSQLASTRecordDeclaration new
			identifier: tokens first;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlReturnForm1 [
	^ super plpgsqlReturnForm1 ==> [ :tokens |
		PSQLPlpgSQLASTReturnStatement new
			expression: tokens second;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlReturnForm2 [
	^ super plpgsqlReturnForm2 ==> [ :tokens |
		PSQLPlpgSQLASTReturnStatement new
			expression: tokens third;
			isReturnNext: true;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlReturnForm3 [
	^ super plpgsqlReturnForm3 ==> [ :tokens |
		PSQLPlpgSQLASTReturnStatement new
			query: tokens third;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlReturnForm4 [
	^ super plpgsqlReturnForm4 ==> [ :tokens |
		|stmt|
		stmt := PSQLPlpgSQLASTReturnStatement new
					queryExecute: tokens fourth;
					yourself.
		tokens fifth ifNotNil: [ 
			stmt usingExpressions: (tokens fifth second reject: [ :item | item = $, ]) ].
		stmt ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlReturnForm5 [
	^ super plpgsqlReturnForm5 ==> [ :tokens |
		PSQLPlpgSQLASTReturnStatement new ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlRowTypeDeclaration [
	^ super plpgsqlRowTypeDeclaration ==> [ :tokens |
		PSQLPlpgSQLASTRowTypeDeclaration new
			identifier: tokens first;
			tableIdentifier: tokens second;
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlSearchedCase [
	^ super plpgsqlSearchedCase ==> [ :tokens |
		PSQLPlpgSQLASTSearchedCase new
			searchedExpression: tokens second;
			conditionsToStatements: (tokens third collect: [ :subTokens |
				(subTokens second reject: [ :item | item = $, ]) -> subTokens fourth ]);
			elseStatements: (tokens fourth ifNotNil: #second);
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlSimpleCase [
	^ super plpgsqlSimpleCase ==> [ :tokens |
		PSQLPlpgSQLASTSimpleCase new
			conditionToStatements: (tokens second collect: [ :subTokens | subTokens second -> subTokens fourth ]);
			elseStatements: (tokens third ifNotNil: #second);
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlStatements [
	^ super plpgsqlStatements ==> [ :tokens |
		OrderedCollection new
			add: tokens first;
			addAll: (tokens second collect: #third);
			yourself ]
]

{ #category : #plpgsql }
PSQLASTBuilder >> plpgsqlWhileLoop [
	^ super plpgsqlWhileLoop ==> [ :tokens |
		PSQLPlpgSQLASTWhileLoop new
			beginLabel: tokens first;
			endLabel: tokens last;
			condition: tokens third;
			statements: tokens fifth;
			yourself ]
]

{ #category : #accessing }
PSQLASTBuilder >> positionalParameter [
	^ super positionalParameter ==> [ :tokens | 
		PSQLPlpgSQLASTPositionalParameter new
			index: (String newFrom: tokens second) asNumber;
			yourself ]
]

{ #category : #'accessing - blocks' }
PSQLASTBuilder >> postfixOperatorBlock [
	^ [ :exp :op |
			(op isArray and: [ op size = 4 and: [ op first = $[ and: [ op last = $] ] ] ])
				ifFalse: [ 
					PSQLASTPostfixOperator new
						operator: op;
						expression: exp;
						yourself ]
				ifTrue: [ 
					PSQLSubscript new
						target: exp;
						subscriptExpression: op second;
						yourself ] ]
]

{ #category : #'accessing - blocks' }
PSQLASTBuilder >> prefixOperatorBlock [
	^ [ :op :exp |
			PSQLASTPrefixOperator new
				operator: op;
				expression: exp;
				yourself ]
]

{ #category : #accessing }
PSQLASTBuilder >> simpleStringConstant [
	^ super simpleStringConstant ==> [ :tokens |
		PSQLASTStringConstant new
			content: (String newFrom: tokens flattened allButFirst allButLast);
			yourself ]
]