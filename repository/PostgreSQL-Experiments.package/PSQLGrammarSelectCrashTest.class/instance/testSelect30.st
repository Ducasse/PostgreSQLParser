tests
testSelect30
	self
		parse: 'SELECT personne.cle, personne.nom, personne.prenom, support.fin, support.cle AS clesupport FROM personne, vue_support_le_plus_recent, support WHERE ((((support.cle = vue_support_le_plus_recent.clesupport) AND (support.fin IS NOT NULL)) AND (personne.cle = vue_support_le_plus_recent.clepersonne)) AND ((((support.fin)::timestamp with time zone - now()) < ''00:00:00''::interval) AND (((support.fin)::timestamp with time zone - now()) > ''-30 days''::interval))) GROUP BY personne.cle, personne.nom, personne.prenom, support.fin, support.cle' rule: #selectCommand