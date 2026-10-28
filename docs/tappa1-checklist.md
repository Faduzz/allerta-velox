# Tappa 1: checklist di prova

Obiettivo: verificare la catena codice, build in cloud, installazione da Windows, GPS in background e notifica.
Se un criterio fallisce, la tappa si ferma: si scrive cosa è fallito e si decide insieme, senza passare alla tappa 2.

## 0. Metti il codice su GitHub

- [ ] Crea un repository **pubblico** vuoto su GitHub, senza README.
- [ ] Decomprimi `allerta-velox-tappa1.zip`: la cartella è già un repository Git, con la cronologia dei commit.
- [ ] Nella cartella: `git remote add origin https://github.com/<utente>/<repo>.git`, poi `git push -u origin tappa-1`.
- [ ] Apri la scheda **Actions** e guarda il run.

## 1. Cosa deve dire la CI

- [ ] Job `test` verde: `flutter analyze`, `flutter test` (11 test Dart), `pytest` (3 test Python).
- [ ] Job `build-ios` verde, con l'artifact `AllertaVelox-ipa` scaricabile.

Se è rosso, mandami le ultime 30 righe del passo che fallisce. I punti più a rischio, perché non ho potuto compilare qui:
- import di `package:flutter/material.dart` su Flutter 3.47;
- nomi dei parametri di `flutter_local_notifications` 21 (`initialize(settings:)`, `zonedSchedule(id:, ...)`);
- `AppleSettings` di `geolocator` 14.0.2;
- versione di `timezone` 0.10.1, presa a memoria;
- il passo «Controlla che flutter create non abbia sovrascritto il nostro codice».

## 2. Prova sul tuo iPhone

- [ ] **Prepara.** iPhone: attiva la Modalità sviluppatore (Impostazioni, Privacy e sicurezza). PC: installa iTunes e iCloud dal sito Apple (non dal Microsoft Store), poi Sideloadly. Rileggi i requisiti sul sito di Sideloadly.
- [ ] **Installa.** Scarica `AllertaVelox.ipa` dall'artifact (è dentro uno zip). Collega l'iPhone col cavo, trascina il file in Sideloadly, inserisci il tuo Apple ID, premi Start. Se Sideloadly rifiuta per il limite settimanale di App ID dell'account gratuito (da verificare), non cambiare bundle id a ogni prova.
- [ ] **Fidati e avvia.** iPhone: Impostazioni, Generali, VPN e gestione dispositivo, fidati del tuo Apple ID. Apri l'app, concedi «Sempre» e le notifiche, premi «Avvia tracciamento».
- [ ] **GPS in background.** Apri Google Maps in primo piano e cammina o guida per almeno 10 minuti. Non restare fermo: un buco può essere solo una sosta. Torna nell'app e scrivi qui sotto i valori. Successo: buco massimo ≤ 30 s (soglia iniziale, la rivediamo con i dati veri).
- [ ] **Notifica.** Premi «Notifica tra 10 s» e blocca lo schermo. Successo: il banner appare.

## Risultati

| Prova | Valore | Esito |
|---|---|---|
| CI test | | |
| CI build-ios | | |
| Installazione con Sideloadly | | |
| Fix ricevuti dopo 10 minuti | | |
| Buco massimo (s) | | |
| Banner con schermo bloccato | | |

Note:
