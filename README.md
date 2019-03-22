PW-Terraform Aufbau
---

### Generelles:

Die Infrastruktur sollte logisch und nach fachlichkeiten in Unterordner aufgeteilt werden. 
Hierbei sollte ein Ordner immer thematisch zusammenhängende Resourcen beinhalten.

Beispiele hierfür sind:

**Umgebung**  
(muss eig nie verändert werden, brauchen wir nicht lokal)
- vpc

**Compute**  
(muss selten verändert werden, brauchen wir nicht lokal)
- ec2
- autoscaling
- loadbalancer

**ssl**  
(muss eig nie verändert werden & dauert lange, brauchen wir nicht lokal)
- route53 etc

**Speicher**    
- S3

**Kommunikation**    
- SQS

**Datenbank**    
- Elasticache
- RDS

Jeder Ordner definiert für die enthaltenen Resourcen, ob es sich um welche handelt, die wir auch zur lokalen Entwicklung brauchen.  
Beispiele:
- SQS
- Lamdas

Soetwas wie das Dateisystem und die Datenbank sollten hierbei am besten lokal gehalten werden.

### Kennzeichnung der Resourcen
Die Resourcen sollten immer mit aussagekräftigen Namen bzw. Tags versehen werden.
Hierfür sollten immer die Tags `${var.environment}` und `${var.project}` genutzt werden

### Struktur
Die Ordnerstruktur orientiert sich an den verschiedenen Arten der Resourcen.

Es kann für jede "Gruppe" ein neuer Ordner mit den entsprechenden Terraform-Dateien angelegt werden.
Über die apply/destroy und init-skripte können diese Ordner dann ebenfalls integriert werden

### Allgemeiner Ablauf
Der allgemeine Ablauf sieht so aus, dass in den Terraform-Skripten die benötigten Ressourcen des 
Projektes definiert werden.
Durch das Ausführen des Apply-Skriptes werden dann die definierten Resourcen in der ernsprechenden Umgebung
angelegt. Hierbei wird zuerst gezeigt, welche Änderungen das Skript durchführen würde. Dies passiert auf Basis
des aktuellen States, welches wir global auf S3 halten.
Um die Resourcen wieder zu entfernen wird das Destroy-Skript ausgeführt. Der Ablauf ist hier dann analog.

### Skripte
**Allgemein**   
- Umgebungen: `live`, `staging`, `<Entwicklername>`(ist immer dev)
- Als Name des Entwicklers nutzen wir das selbe Kürzel wie in der Mailadresse nur mit einem `-` statt einem `.` (`j.doe@demv.de` => `j-doe`)

**Init**    
`./init.sh <Entwickler> <Ordername>`
- `./init.sh j-doe` führt das init in allen Ordnern aus
- `./init.sh j-doe user` führt das init im order `user` aus

**Apply**   
`./init.sh <Umgebung/Entwickler> <Ordername>`
- `./apply.sh j-doe` führt das Apply für die lokale Entwicklung aus (disposable)
- `./apply.sh j-doe user` führt das Apply für die lokale Entwicklung in dem Ordner `user` aus 
- `./apply.sh live` führt das Apply in der Liveumgebung aus
- `./apply.sh staging resources` führt das Apply in der Staging-Umgebung in dem Ordner `resources` aus

**Destroy**   
Analog zu `Apply`

### tfvars
Die benötigten Variablen können in der entsprechenden Environment-Datei *.tfvars angelegt werden damit diese nicht manuell bei der Ausführung angegeben werden müssen

### Setup bei neuen Projekten
1. Ordner in Projekt kopieren
2. `./setup.sh` ausführen und Projektnamen angeben
3. Arn der IAM-Roles in vars.tfvars hinterlegen
4. Ungenutzte Ordner entfernen (z.B. `vpc`) (Hiervon ausgenommen sind `tf-*`-Ordner)
5. Eigene Ordner mit Resourcen anlegen
6. `./init.sh <Mein Name>` ausführen
7. `apply` - `destroy` ausführen

### Anpassungsmöglichkeiten
**Neuen Ordner erstellen**
- Ordner anlegen
- Ausführungsreihenfolge festlegen. Die Reihenfolge ergibts sich aus den Namen der Ordner. Die Zahl des Prefixes gibt die Reihenfolge an. Das Apply wird von klein nach groß, das Destroy von groß nach gleich ausgeführt.   
Beispiel:   
Apply: 10-vpc --> 20-user --> 30-s3   
Destroy: 30-s3 --> 20-user --> 10-vpc   
- `main.tf.dist` kopieren
- Platzhalter in der neuen `main.tf` anpassen
- Wenn dieser Ordner für Resourcen genutzt wird, die wir für die lokale Entwicklung brauchen muss dies mit einer `.local` Datei in dem Ordner gekennzeichnet werden
