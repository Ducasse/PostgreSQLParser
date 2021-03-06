"
I am a ORDER BY clause node from a SELECT query.
"
Class {
	#name : #PSQLASTOrderByClause,
	#superclass : #PSQLASTAbstractClause,
	#instVars : [
		'items'
	],
	#category : #'PostgreSQL-AST-SQL-Clauses'
}

{ #category : #visiting }
PSQLASTOrderByClause >> acceptVisitor: aVisitor [
	^ aVisitor visitPSQLASTOrderByClause: self
]

{ #category : #testing }
PSQLASTOrderByClause >> isOrderByClause [
	^ true
]

{ #category : #accessing }
PSQLASTOrderByClause >> items [
	^ items
]

{ #category : #accessing }
PSQLASTOrderByClause >> items: anObject [
	items := anObject
]
