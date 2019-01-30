pragma solidity ^0.4.25;

contract SceneLibre
{
	uint constant MAX_CRENEAUX = 12;
	string[MAX_CRENEAUX] _passage_artistes;
	uint _nb_creneaux_libres = MAX_CRENEAUX;
	uint _artiste_courant = 0;

	function est_inscrit(string nom_artiste) public view returns(bool)
	{
		for (uint i = 0; i < MAX_CRENEAUX; ++i)
		{
			if (keccak256(bytes(_passage_artistes[i])) == keccak256(bytes(nom_artiste)))
			{
				return true;
			}
		}

		return false;
	}

	function inscrire(string nom_artiste) public
	{
		require(bytes(nom_artiste).length > 0, "Nom vide non valide.");
		require(false == est_inscrit(nom_artiste), "Un artiste est deja inscrit sous ce nom.");
		require(_nb_creneaux_libres > 0, "Tous les creneaux sont pris.");

		_passage_artistes[MAX_CRENEAUX - _nb_creneaux_libres] = nom_artiste;
		_nb_creneaux_libres -= 1;
	}

	function artiste_courant() public view returns(string nom_artiste)
	{
		return _passage_artistes[_artiste_courant];
	}

	function passer_prochain_artiste() public
	{
		_artiste_courant += 1;
	}
}
