"
I am the UNION clause of a SELECT query.
"
Class {
	#name : #PSQLASTUnionClause,
	#superclass : #PSQLASTSetOperatorClause,
	#category : #'PostgreSQL-AST-SQL-Clauses'
}

{ #category : #visiting }
PSQLASTUnionClause >> acceptVisitor: aVisitor [
	^ aVisitor visitPSQLASTUnionClause: self
]

{ #category : #testing }
PSQLASTUnionClause >> isUnionClause [
	^ true
]
