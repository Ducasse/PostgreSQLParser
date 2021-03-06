"
I am FROM clause item of type 2. See PSQLGrammar>>#fromItems2.
"
Class {
	#name : #PSQLASTFromClauseItemType2,
	#superclass : #PSQLASTFromClauseItem,
	#instVars : [
		'hasLateral',
		'valuesOrSelect',
		'alias',
		'columnAliases'
	],
	#category : #'PostgreSQL-AST-SQL'
}

{ #category : #visiting }
PSQLASTFromClauseItemType2 >> acceptVisitor: aVisitor [
	^ aVisitor visitPSQLASTFromClauseItemType2: self
]

{ #category : #accessing }
PSQLASTFromClauseItemType2 >> alias [
	^ alias
]

{ #category : #accessing }
PSQLASTFromClauseItemType2 >> alias: anObject [
	alias := anObject
]

{ #category : #accessing }
PSQLASTFromClauseItemType2 >> columnAliases [
	^ columnAliases
]

{ #category : #accessing }
PSQLASTFromClauseItemType2 >> columnAliases: anObject [
	columnAliases := anObject
]

{ #category : #testing }
PSQLASTFromClauseItemType2 >> hasAlias [
	^ self alias isNotNil
]

{ #category : #testing }
PSQLASTFromClauseItemType2 >> hasColumnAliases [
	^ self columnAliases isNotNil
]

{ #category : #accessing }
PSQLASTFromClauseItemType2 >> hasLateral [
	^ hasLateral
]

{ #category : #accessing }
PSQLASTFromClauseItemType2 >> hasLateral: anObject [
	hasLateral := anObject
]

{ #category : #testing }
PSQLASTFromClauseItemType2 >> isFromClauseItemType2 [
	^ true
]

{ #category : #accessing }
PSQLASTFromClauseItemType2 >> valuesOrSelect [
	^ valuesOrSelect
]

{ #category : #accessing }
PSQLASTFromClauseItemType2 >> valuesOrSelect: anObject [
	valuesOrSelect := anObject
]
