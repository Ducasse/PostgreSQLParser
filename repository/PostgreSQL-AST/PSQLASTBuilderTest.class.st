"
A PSQLASTBuilderTest is a test class for testing the behavior of PSQLASTBuilder
"
Class {
	#name : #PSQLASTBuilderTest,
	#superclass : #TestCase,
	#instVars : [
		'builder'
	],
	#category : 'PostgreSQL-AST-Tests'
}

{ #category : #initialization }
PSQLASTBuilderTest >> setUp [
	builder := PSQLASTBuilder new
]

{ #category : #tests-expression }
PSQLASTBuilderTest >> testCompositeValueWith [
	| node |
	node := builder expression parse: '(1, id*3, table.attribute)'.
	self
		assert: node class equals: PSQLCompositeValue;
		assert: node items size equals: 3;
		assert: node items first class equals: PSQLASTNumericConstant;
		assert: node items second class equals: PSQLASTBinaryOperator;
		assert: node items third class equals: PSQLASTAttributeAccess.
		
	node := builder expression parse: '((-1::INT8) << 63, 0)::"link_strength"'.
	self
		assert: node class equals: PSQLASTBinaryOperator;
		assert: node left class equals: PSQLCompositeValue;
		assert: node left items size equals: 2;
		assert: node operator equals: '::';
		assert: node right class equals: PSQLASTIdentifier.
]

{ #category : #tests-expression }
PSQLASTBuilderTest >> testConditionalExpression [
	| node |
	node := builder expression parse: 'CASE WHEN (actualite.debut IS NULL) THEN actualite.debutpublication ELSE actualite.debut END'.
	self
		assert: node class equals: PSQLConditionalExpression;
		assert: node conditionsToExpressions size equals: 1;
		assert: node conditionsToExpressions first head class equals: PSQLParenthesedExpression;
		assert: node conditionsToExpressions first tail class equals: PSQLASTAttributeAccess;
		assert: node elseExpression class equals: PSQLASTAttributeAccess
]

{ #category : #tests-expression }
PSQLASTBuilderTest >> testExpressionParserTermFor [
	| node |
	node := builder expression parse: '''a String'''.
	self
		assert: node class equals: PSQLASTStringConstant.
		
	node := builder expression parse: '''a String''::text varying'.
	self
		assert: node class equals: PSQLASTBinaryOperator;
		assert: node left class equals: PSQLASTStringConstant;
		assert: node operator equals: '::';
		assert: node right class equals: PSQLASTIdentifier
]

{ #category : #tests-expression }
PSQLASTBuilderTest >> testFunctionCallParserWith [
	| node |
	node := builder expression parse: 'fct(1, id, arg := ''argument'', 41 + 1)'.
	self
		assert: node class equals: PSQLFunctionCall;
		assert: node functionIdentifier class equals: PSQLASTIdentifier;
		assert: node functionIdentifier identifier equals: 'fct';
		assert: node argumentsList size equals: 3;
		assert: node argumentsList first class equals: PSQLASTNumericConstant;
		assert: node argumentsList second class equals: PSQLASTIdentifier;
		assert: node argumentsList third class equals: PSQLASTBinaryOperator;
		assert: node argumentsDictionary size equals: 1;
		assert: node argumentsDictionary associations first head class equals: PSQLASTIdentifier;
		assert: node argumentsDictionary associations first tail class equals: PSQLASTStringConstant
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testIdentifier [
	| node |
	node := builder identifier parse: 'id'.
	
	self
		assert: node class equals: PSQLASTIdentifier;
		assert: node identifier equals: 'id'
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testNumericConstant [
	| node |
	node := builder numericConstant parse: '1.21'.
	
	self
		assert: node class equals: PSQLASTNumericConstant;
		assert: node content equals: '1.21'
]

{ #category : #tests-expression }
PSQLASTBuilderTest >> testParenthesedExpressionParserWith [
	| node |
	node := builder expression parse: '(id+1)'.
	self
		assert: node class equals: PSQLParenthesedExpression;
		assert: node expression class equals: PSQLASTBinaryOperator
]

{ #category : #tests-plpgsql }
PSQLASTBuilderTest >> testPlpgsqlAliasDeclaration [
	| node |
	node := builder plpgsqlAliasDeclaration parse: 'id ALIAS FOR $1'.
	self
		assert: node class equals: PSQLPlpgSQLASTAliasDeclaration;
		assert: node identifier identifier equals: 'id';
		assert: node aliased identifier equals: '$1'.
		
	node := builder plpgsqlAliasDeclaration parse: 'id ALIAS FOR identifier'.
	self
		assert: node class equals: PSQLPlpgSQLASTAliasDeclaration;
		assert: node identifier identifier equals: 'id';
		assert: node aliased identifier equals: 'identifier'
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlArrayLoop [
	| node |
	node := builder plpgsqlArrayLoop parse: 'FOREACH x IN ARRAY $1
  LOOP
    s := s + x;
    t := s;
  END LOOP'.
	self
		assert: node class equals: PSQLPlpgSQLASTArrayLoop;
		assert: node beginLabel isNil;
		assert: node endLabel isNil;
		assert: node statements size equals: 2;
		assert: node target class equals: PSQLASTIdentifier;
		assert: node arrayExpression class equals: PSQLPlpgSQLASTPositionalParameter;
		assert: node sliceNumber isNil
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlAssignmentLeftPart [
	| node |
	node := builder plpgsqlAssignmentLeftPart parse: 'truc.machin[id][3]'.
	self
		assert: node class equals: PSQLSubscript;
		assert: node target class equals: PSQLSubscript;
		assert: node target target class equals: PSQLASTAttributeAccess;
		assert: node target target accessed class equals: PSQLASTIdentifier
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlAssignmentStatement [
	| node |
	node := builder plpgsqlAssignmentStatement parse: 'truc.machin[id][3] := 42'.
	self
		assert: node class equals: PSQLPlpgSQLASTAssignment;
		assert: node operator equals: ':=';
		assert: node target class equals: PSQLSubscript;
		assert: node toAssign class equals: PSQLASTNumericConstant
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlBeginLabel [
	| node |
	node := builder plpgsqlBeginLabel parse: '<<label>>'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTBlockLabel;
		assert: node labelContent equals: 'label'
]

{ #category : #tests-plpgsql }
PSQLASTBuilderTest >> testPlpgsqlBlock [
	| node |
	node := builder plpgsqlBlock parse: '<<label>>
DECLARE
	id ALIAS FOR $1;
	var INTEGER;
BEGIN
	var := id + 1;
END
label;'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTBlock;
		assert: node declarations size equals: 2;
		assert: node statements size equals: 1;
		assert: node label class equals: PSQLPlpgSQLASTBlockLabel
		
]

{ #category : #tests-plpgsql }
PSQLASTBuilderTest >> testPlpgsqlClassicDeclaration [
	| node |
	node := builder plpgsqlClassicDeclaration parse: 'id integer'.
	self
		assert: node class equals: PSQLPlpgSQLASTClassicDeclaration;
		assert: node identifier identifier equals: 'id';
		assert: node type identifier identifier equals: 'integer'
]

{ #category : #tests-plpgsql }
PSQLASTBuilderTest >> testPlpgsqlContinueStatement [
	| node |
	node := builder plpgsqlContinueStatement parse: 'CONTINUE WHEN count < 50'.
	self
		assert: node class equals: PSQLPlpgSQLASTContinue;
		assert: node label isNil;
		assert: node whenExpression class equals: PSQLASTBinaryOperator
]

{ #category : #tests-plpgsql }
PSQLASTBuilderTest >> testPlpgsqlCopyTypeDeclaration [
	| node |
	node := builder plpgsqlCopyTypeDeclaration parse: 'user_id users.user_id%TYPE'.
	self
		assert: node class equals: PSQLPlpgSQLASTCopyTypeDeclaration;
		assert: node accessToCopyType attributeIdentifier identifier equals: 'users';
		assert: node accessToCopyType accessed identifier equals: 'user_id'
]

{ #category : #tests-plpgsql }
PSQLASTBuilderTest >> testPlpgsqlDeclarationType [
	| node |
	node := builder plpgsqlDeclarationType parse: 'varying char(16)[][]'.
	self
		assert: node class equals: PSQLPlpgSQLASTType;
		assert: node identifier identifier equals: 'varying char';
		assert: node size equals: 16;
		assert: node dimensions equals: 2
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlForLoop [
	| node |
	node := builder plpgsqlForLoop parse: '<<forlabel>>
FOR i IN 1 .. 10 LOOP
    NULL;
END LOOP forlabel'.
	self
		assert: node class equals: PSQLPlpgSQLASTForLoop;
		assert: node beginLabel class equals: PSQLPlpgSQLASTBlockLabel;
		assert: node endLabel class equals: PSQLPlpgSQLASTBlockLabel;
		assert: node statements size equals: 1;
		assert: node target class equals: PSQLASTIdentifier;
		assert: node fromExpression class equals: PSQLASTNumericConstant;
		assert: node toExpression class equals: PSQLASTNumericConstant
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlIfThen [
	| node |
	node := builder plpgsqlIfThen parse: 'IF x = 1 THEN
	stmt := 1;
	stmt := stmt +1;
END IF'.
	self
		assert: node class equals: PSQLPlpgSQLASTIf;
		assert: node conditionToStatements size equals: 1;
		assert: node conditionToStatements first head class equals: PSQLASTBinaryOperator;
		assert: node conditionToStatements first tail size equals: 2
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlIfThenElse [
	| node |
	node := builder plpgsqlIfThenElse parse: 'IF x = 1 THEN
	stmt := 1;
ELSE
	stmt := stmt +1;
END IF'.
	self
		assert: node class equals: PSQLPlpgSQLASTIf;
		assert: node conditionToStatements size equals: 1;
		assert: node conditionToStatements first head class equals: PSQLASTBinaryOperator;
		assert: node conditionToStatements first tail size equals: 1;
		assert: node elseStatements size equals: 1
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlIfThenElsif [
	| node |
	node := builder plpgsqlIfThenElsif parse: 'IF x = 1 THEN
	stmt := 1;
ELSE IF x = 2 THEN
	stmt := 2;
ELSIF x = 3 THEN
	stmt := 3;
ELSE
	stmt := stmt +1;
END IF'.
	self
		assert: node class equals: PSQLPlpgSQLASTIf;
		assert: node conditionToStatements size equals: 3;
		assert: node elseStatements size equals: 1
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlIndexParameter [
	| node |
	node := builder plpgsqlIndexParameter parse: '$1'.
	
	self
		assert: node class equals: PSQLASTIdentifier;
		assert: node identifier equals: '$1'
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlLabel [
	| node |
	node := builder plpgsqlLabel parse: 'label'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTBlockLabel;
		assert: node labelContent equals: 'label'
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlLoopLoop [
	| node |
	node := builder plpgsqlLoopLoop parse: 'LOOP
    amount_owed := amount_owed + 1;
END LOOP'.
	self
		assert: node class equals: PSQLPlpgSQLASTLoop;
		assert: node beginLabel isNil;
		assert: node endLabel isNil;
		assert: node statements size equals: 1
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlQueryResultsLoop [
	| node |
	node := builder plpgsqlQueryResultsLoop parse: 'FOR mviews IN SELECT * FROM cs_materialized_views ORDER BY sort_key LOOP
	var := mviews;
END LOOP'.
	self
		assert: node class equals: PSQLPlpgSQLASTQueryResultsLoop;
		assert: node beginLabel isNil;
		assert: node endLabel isNil;
		assert: node target class equals: PSQLASTIdentifier;
		assert: node statements size equals: 1;
		flag: #'TODO test the query'
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlRaiseStatement1 [
	| node |
	node := builder plpgsqlRaiseStatement1 parse: 'RAISE EXCEPTION ''Nonexistent ID --> %'', user_id
      USING HINT = ''Please check your user ID'''.
	
	self
		assert: node class equals: PSQLPlpgSQLASTRaiseStatement;
		assert: node level equals: 'EXCEPTION';
		assert: node formatString class equals: PSQLASTStringConstant;
		assert: node formatString content equals: 'Nonexistent ID --> %';
		assert: node formatExpressions size equals: 1;
		assert: node usingAssocs size equals: 1
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlRaiseStatement2 [
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlRaiseStatement3 [
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlRaiseStatement4 [
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlRaiseStatement5 [
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlRaiseUsingOptions [
	| assocs |
	assocs := builder plpgsqlRaiseUsingOptions parse: 'USING opt = 1 + 1, opt2 = ''test'''.
	
	self
		assert: assocs size equals: 2;
		assert: assocs first head class equals: PSQLASTIdentifier;
		assert: assocs first tail class equals: PSQLASTBinaryOperator;
		assert: assocs second head class equals: PSQLASTIdentifier;
		assert: assocs second tail class equals: PSQLASTStringConstant
]

{ #category : #tests-plpgsql }
PSQLASTBuilderTest >> testPlpgsqlRecordDeclaration [
	| node |
	node := builder plpgsqlRecordDeclaration parse: 'identifier RECORD'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTRecordDeclaration;
		assert: node identifier identifier equals: 'identifier'
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlReturnForm1 [
	| node |
	node := builder plpgsqlReturnForm1 parse: 'RETURN 1+1'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTReturnStatement;
		assert: node isReturnExpression;
		deny: node hasUsingExpressions;
		deny: node isEmptyReturn;
		deny: node isReturnQuery;
		deny: node isReturnQueryExecute;
		deny: node isReturnNext;
		assert: node expression class equals: PSQLASTBinaryOperator
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlReturnForm2 [
	| node |
	node := builder plpgsqlReturnForm2 parse: 'RETURN NEXT 1+1'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTReturnStatement;
		assert: node isReturnNext;
		deny: node hasUsingExpressions;
		deny: node isEmptyReturn;
		deny: node isReturnQuery;
		deny: node isReturnQueryExecute;
		deny: node isReturnExpression;
		assert: node expression class equals: PSQLASTBinaryOperator
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlReturnForm3 [
	| node |
	node := builder plpgsqlReturnForm3 parse: 'RETURN QUERY SELECT * FROM table'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTReturnStatement;
		assert: node isReturnQuery;
		deny: node hasUsingExpressions;
		deny: node isEmptyReturn;
		deny: node isReturnNext;
		deny: node isReturnQueryExecute;
		deny: node isReturnExpression;flag:#todo"
		assert: node query class equals: "
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlReturnForm4 [
	| node |
	node := builder plpgsqlReturnForm4 parse: 'RETURN QUERY EXECUTE ''SELECT flightid
                   FROM flight
                  WHERE flightdate >= $1
                    AND flightdate < ($1 + 1)'''.
	
	self
		assert: node class equals: PSQLPlpgSQLASTReturnStatement;
		assert: node isReturnQueryExecute;
		assert: node queryExecute class equals: PSQLASTStringConstant;
		assert: node queryExecute content equals: 'SELECT flightid
                   FROM flight
                  WHERE flightdate >= $1
                    AND flightdate < ($1 + 1)';
		deny: node hasUsingExpressions;
		deny: node isEmptyReturn;
		deny: node isReturnNext;
		deny: node isReturnQuery;
		deny: node isReturnExpression
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlReturnForm4Bis [
	| node |
	node := builder plpgsqlReturnForm4 parse: 'RETURN QUERY EXECUTE ''SELECT flightid
                   FROM flight
                  WHERE % >=  %'' USING id, 2'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTReturnStatement;
		assert: node isReturnQueryExecute;
		assert: node queryExecute class equals: PSQLASTStringConstant;
		assert: node queryExecute content equals: 'SELECT flightid
                   FROM flight
                  WHERE % >=  %';
		assert: node hasUsingExpressions;
		assert: node usingExpressions size equals: 2;
		deny: node isEmptyReturn;
		deny: node isReturnNext;
		deny: node isReturnQuery;
		deny: node isReturnExpression
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlReturnForm5 [
	| node |
	node := builder plpgsqlReturnForm5 parse: 'RETURN'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTReturnStatement;
		assert: node isEmptyReturn;
		deny: node hasUsingExpressions;
		deny: node isReturnExpression;
		deny: node isReturnQuery;
		deny: node isReturnQueryExecute;
		deny: node isReturnNext
]

{ #category : #tests-plpgsql }
PSQLASTBuilderTest >> testPlpgsqlRowTypeDeclaration [
	| node |
	node := builder plpgsqlRowTypeDeclaration parse: 'id table%ROWTYPE'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTRowTypeDeclaration;
		assert: node identifier identifier equals: 'id';
		assert: node tableIdentifier identifier equals: 'table'
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlSearchedCase [
	| node |
	node := builder plpgsqlSearchedCase parse: 'CASE x
    WHEN 1, 2 THEN
        msg := ''one or two'';
	WHEN 3, 4 THEN
        msg := ''three or four'';
END CASE'.
	self
		assert: node class equals: PSQLPlpgSQLASTSearchedCase;
		assert: node searchedExpression class equals: PSQLASTIdentifier;
		assert: node conditionsToStatements size equals: 2;
		assert: node conditionsToStatements first head size equals: 2;
		assert: node conditionsToStatements first tail size equals: 1;
		assert: node conditionsToStatements second head size equals: 2;
		assert: node conditionsToStatements second tail size equals: 1;
		assert: node elseStatements isNil
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlSimpleCase [
	| node |
	node := builder plpgsqlSimpleCase parse: 'CASE
    WHEN x < 10 THEN
        msg := ''value is smaller than ten'';
    ELSE
        msg := ''KO'';
END CASE'.
	self
		assert: node class equals: PSQLPlpgSQLASTSimpleCase;
		assert: node conditionToStatements size equals: 1;
		assert: node elseStatements size equals: 1
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPlpgsqlWhileLoop [
	| node |
	node := builder plpgsqlWhileLoop parse: 'WHILE amount_owed < 42 LOOP
    amount_owed := amount_owed + 1;
END LOOP'.
	self
		assert: node class equals: PSQLPlpgSQLASTWhileLoop;
		assert: node beginLabel isNil;
		assert: node endLabel isNil;
		assert: node condition class equals: PSQLASTBinaryOperator;
		assert: node statements size equals: 1
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testPositionalParameter [
	| node |
	node := builder positionalParameter parse: '$1'.
	
	self
		assert: node class equals: PSQLPlpgSQLASTPositionalParameter;
		assert: node index equals: 1
]

{ #category : #tests-accessing }
PSQLASTBuilderTest >> testSimpleStringConstant [
	| node |
	node := builder simpleStringConstant parse: '''test'''.
	
	self
		assert: node class equals: PSQLASTStringConstant;
		assert: node content equals: 'test'
]