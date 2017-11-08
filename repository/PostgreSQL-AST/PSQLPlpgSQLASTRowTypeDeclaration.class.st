"
I represent the declaration of a row variable.
"
Class {
	#name : #PSQLPlpgSQLASTRowTypeDeclaration,
	#superclass : #PSQLPlpgSQLASTDeclaration,
	#instVars : [
		'tableIdentifier'
	],
	#category : 'PostgreSQL-AST-Nodes'
}

{ #category : #accessing }
PSQLPlpgSQLASTRowTypeDeclaration >> tableIdentifier [
	^ tableIdentifier
]

{ #category : #accessing }
PSQLPlpgSQLASTRowTypeDeclaration >> tableIdentifier: anObject [
	tableIdentifier := anObject
]