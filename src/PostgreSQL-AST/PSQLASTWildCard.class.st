"
I represent the wildcard operator '*'.
"
Class {
	#name : #PSQLASTWildCard,
	#superclass : #PSQLASTNode,
	#category : #PostgreSQL-AST-SQL
}

{ #category : #visiting }
PSQLASTWildCard >> acceptVisitor: aPSQLASTVisitor [
	^ self visitPSQLASTWildCard: self
]