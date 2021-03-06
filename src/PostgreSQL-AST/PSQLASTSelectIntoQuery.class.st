"
I represent a SELECT INTO query.
"
Class {
	#name : #PSQLASTSelectIntoQuery,
	#superclass : #PSQLASTSelectQuery,
	#instVars : [
		'intoClause'
	],
	#category : #'PostgreSQL-AST-SQL-CRUD'
}

{ #category : #visiting }
PSQLASTSelectIntoQuery >> acceptVisitor: aVisitor [
	^ aVisitor visitPSQLASTSelectIntoQuery: self
]

{ #category : #accessing }
PSQLASTSelectIntoQuery >> intoClause [
	^ intoClause
]

{ #category : #accessing }
PSQLASTSelectIntoQuery >> intoClause: anObject [
	intoClause := anObject
]

{ #category : #testing }
PSQLASTSelectIntoQuery >> isSelectIntoQuery [
	^ true
]
