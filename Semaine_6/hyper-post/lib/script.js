/**
 * Transaction affranchir
 * @param {org.hyperpost.affranchir} tx
 * @transaction
 */
async function affranchir(tx)
{
    var colis = getFactory().newResource('org.hyperpost', 'Colis', tx.numero_colis);
	colis.type = tx.type
	colis.etat = tx.etat
	colis.detenteur_courant = tx.bureau
	colis.prochain_detenteur = tx.bureau
	colis.emetteur = tx.emetteur
	colis.destinataire = tx.destinataire

	const registre = await getAssetRegistry('org.hyperpost.Colis')
	await registre.add(colis)
}

async function depart(tx)
{
	tx.colis.prochain_detenteur = tx.vers
	const registre = await getAssetRegistry('org.hyperpost.Colis')
	await registre.update(tx.colis)
}

/**
 * Transaction transport
 * @param {org.hyperpost.transport} tx
 * @transaction
 */
async function transport(tx)
{
	if (tx.vers.nom != tx.colis.destinataire.nom)
	{
		await depart(tx)
	}
}

/**
 * Transaction distribution
 * @param {org.hyperpost.distribution} tx
 * @transaction
 */
async function distribution(tx)
{
	if (tx.vers.nom == tx.colis.destinataire.nom)
	{
		await depart(tx)
		let event = getFactory().newEvent('org.hyperpost', 'pistage')
		event.colis = tx.colis
		emit(event)
	}
}

/**
 * Transaction livraison_impossible
 * @param {org.hyperpost.livraison_impossible} tx
 * @transaction
 */
async function livraison_impossible(tx)
{
	tx.colis.prochain_detenteur = tx.detenteur_courant
	const registre = await getAssetRegistry('org.hyperpost.Colis')
	await registre.update(tx.colis)

	let event = getFactory().newEvent('org.hyperpost', 'pistage')

	event.colis = tx.colis
	event.motif = tx.motif
	event.type = "PROBLEME"
	emit(event)
}

/**
 * Transaction livraison
 * @param {org.hyperpost.livraison} tx
 * @transaction
 */
async function livraison(tx)
{
	if (tx.accepteur.nom == tx.colis.prochain_detenteur.nom)
	{
		tx.colis.detenteur_courant = tx.accepteur
		const registre = await getAssetRegistry('org.hyperpost.Colis')
		await registre.update(tx.colis)

		let event = null

		if (tx.colis.detenteur_courant.nom == tx.colis.destinataire.nom)
		{
			event = getFactory().newEvent('org.hyperpost', 'distribue')
		}
		else
		{
			event = getFactory().newEvent('org.hyperpost', 'pistage')
			event.type = "DEPLACEMENT"
			event.motif = "deplacement"
		}

		event.colis = tx.colis
		emit(event)
	}
}

/**
 * Transaction degats
 * @param {org.hyperpost.degats} tx
 * @transaction
 */
async function degats(tx)
{
	tx.colis.etat = tx.etat
	const registre = await getAssetRegistry('org.hyperpost.Colis')
	await registre.update(tx.colis)

	event = getFactory().newEvent('org.hyperpost', 'pistage')
	event.type = "PROBLEME"
	event.motif = tx.motif
	event.colis = tx.colis
	emit(event)
}

/**
 * Transaction refus
 * @param {org.hyperpost.refus} tx
 * @transaction
 */
async function refus(tx)
{
	if (tx.refuseur.nom == tx.colis.prochain_detenteur.nom)
	{
		tx.colis.prochain_detenteur = tx.detenteur_courant
		tx.colis.etat = tx.etat
		const registre = await getAssetRegistry('org.hyperpost.Colis')
		await registre.update(tx.colis)

		let event = getFactory().newEvent('org.hyperpost', 'pistage')
		event.colis = tx.colis
		event.motif = tx.motif
		event.type = "PROBLEME"
		emit(event)
	}
}

/**
 * Transaction marquer_perdu
 * @param {org.hyperpost.marquer_perdu} tx
 * @transaction
 */
async function marquer_perdu(tx)
{
	if (tx.detenteur.nom == tx.colis.detenteur_courant.nom)
	{
		tx.colis.prochain_detenteur = tx.detenteur_courant
		tx.colis.etat = tx.etat
		const registre = await getAssetRegistry('org.hyperpost.Colis')
		await registre.update(tx.colis)

		let event = getFactory().newEvent('org.hyperpost', 'pistage')
		event.colis = tx.colis
		event.motif = "Colis perdu"
		event.type = "PROBLEME"
		emit(event)
	}
}

/**
 * Transaction renvoi
 * @param {org.hyperpost.renvoi} tx
 * @transaction
 */
async function renvoi(tx)
{
	tx.colis.destinataire = tx.colis.emetteur
	const registre = await getAssetRegistry('org.hyperpost.Colis')
	await registre.update(tx.colis)
}
