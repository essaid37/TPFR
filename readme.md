
**TP fil rouge - Terraform / Kubernetes / Ansible**

 1. **Créer les VM avec le Terraform**
	 On peut utiliser des ubuntu, micro car les prreflight cheks sont désactivés. Normalement, nécessite 2 cpu et 2 Go de RAM 
	 
 **2. Clé de chiffrement** 
	 copier la clé privée, lui donner les droits 400
	 
 **3. Ouvrir les VM en SSH au moins une fois manuellement**
 
 **4. Recopier les IP dans le fichier hosts.ini**
	Il est possible que l'Ip doit être formatée comme ceci  :
	` ec2-46-137-153-61.eu-west-1.compute.amazonaws.com`
	 Utiliser le user `ubuntu`
	 
 5. **Vérification de la disponibilité des VM** 
	 faire un ping des VM du host.ini :
	 `ansible -i hosts.ini all -m ping`
	 
 7. **Ansible :**
	 Lancer les playbook (playbook, master, join-workers)
	  
 **8. Vérification de la disponibilité des nodes k8s :**
	 Se connecter sur la vm master, faire un `kubectl get nodes`