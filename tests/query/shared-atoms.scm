
(use-modules (opencog))
(use-modules (opencog query))

(define (Tree1)
	(ListLink
		(UnorderedLink
			(ConceptNode "X")
		)
		(UnorderedLink
			(ConceptNode "A1")
			(ConceptNode "B1")
		)
		(ListLink
			(UnorderedLink
				(ConceptNode "X")
			)
			(UnorderedLink
				(ConceptNode "B1")
				(ConceptNode "A1")
			)
		)
	)
)

(define (Tree2)
	(ListLink
		(UnorderedLink
			(ConceptNode "X")
		)
		(UnorderedLink
			(ConceptNode "A2")
			(ConceptNode "B2")
		)
		(ListLink
			(UnorderedLink
				(ConceptNode "X")
			)
			(UnorderedLink
				(ConceptNode "B2")
				(ConceptNode "A2")
			)
		)
	)
)

(define (Tree3)
	(ListLink
		(UnorderedLink
			(ConceptNode "X")
		)
		(UnorderedLink
			(ConceptNode "A3")
			(ConceptNode "B3")
		)
		(ListLink
			(UnorderedLink
				(ConceptNode "X")
			)
			(UnorderedLink
				(ConceptNode "B3")
				(ConceptNode "A3")
			)
		)
	)
)

(Tree1)
(Tree2)
(Tree3)

(define (query1)
	(UnorderedLink
		(VariableNode "$a")
	)
)

(define (query2)
	(VariableNode "$a")
)

(define (tree-query input-query)
	(BindLink
		(VariableList
			(VariableNode "$a")
			(VariableNode "$b")
			(VariableNode "$c")
		)
		(AndLink
			(ListLink
				(input-query)
				(UnorderedLink
					(VariableNode "$b")
					(VariableNode "$c")
				)
				(ListLink
					(input-query)
					(UnorderedLink
						(VariableNode "$b")
						(VariableNode "$c")
					)
				)
			)
		)
		(ListLink
			(VariableNode "$a")
			(VariableNode "$b")
			(VariableNode "$c")
		)
	)
)

(cog-bind (tree-query query1))
(cog-bind (tree-query query2))
